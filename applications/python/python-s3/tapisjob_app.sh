#!/bin/bash
set -euo pipefail
set -x

# python-s3: general-purpose Python app for DesignSafe (TACC Stampede3)
#
# Lifecycle:  setup (unzip, modules, pip) -> PRE_SCRIPT -> main (BINARY, default python3) -> POST_SCRIPT
#
# Failure semantics:
#   - setup or PRE_SCRIPT failure aborts before the main run (no wasted SUs)
#   - main-script failure skips POST_SCRIPT and fails the job
#   - POST_SCRIPT failure warns only, unless POST_SCRIPT_REQUIRED=True
#
# A machine-readable job-summary.json (stage exit codes and timings) is always
# written next to tapisjob.out, on success and on failure.

export APP_ID="python-s3"
export APP_VERSION="1.0.0"

INPUTSCRIPT="${1:?missing input script}"
shift

# Strip path — script must be in inputDirectory
INPUTSCRIPT="${INPUTSCRIPT##*/}"
export SUMMARY_INPUTSCRIPT="$INPUTSCRIPT"

ROOT_DIR="$(pwd)"
export SUMMARY_PATH="${ROOT_DIR}/job-summary.json"
export STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
JOB_START=$(date +%s)

# Live output in tapisjob.out instead of buffered chunks
export PYTHONUNBUFFERED=1

# Stage bookkeeping for the summary writer (empty = stage did not run)
export SETUP_SEC="" PRE_RC="" PRE_SEC="" MAIN_RC="" MAIN_SEC="" POST_RC="" POST_SEC=""
export SUMMARY_CMD="" SUMMARY_PYTHON="" SUMMARY_MODULES="" SUMMARY_BINARY="" SUMMARY_VENV="" SUMMARY_VENV_TEMP="" OVERALL_RC="" TOTAL_SEC="" ENDED_AT=""

write_summary() {
  rc=$?
  export OVERALL_RC=$rc
  export ENDED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  export TOTAL_SEC=$(( $(date +%s) - JOB_START ))
  python3 - <<'PYEOF' || echo "WARNING: could not write job-summary.json" >&2
import json
import os


def num(name):
    value = os.environ.get(name, "").strip()
    return int(value) if value else None


def script_stage(script_var, rc_var, sec_var):
    return {
        "script": os.environ.get(script_var) or None,
        "exit_code": num(rc_var),
        "seconds": num(sec_var),
    }


summary = {
    "app_id": os.environ["APP_ID"],
    "app_version": os.environ["APP_VERSION"],
    "job_uuid": os.environ.get("_tapisJobUUID") or None,
    "hostname": os.uname().nodename,
    "started": os.environ.get("STARTED_AT"),
    "ended": os.environ.get("ENDED_AT"),
    "input_script": os.environ.get("SUMMARY_INPUTSCRIPT"),
    "binary": os.environ.get("SUMMARY_BINARY") or None,
    "python_env": os.environ.get("SUMMARY_VENV") or None,
    "command": os.environ.get("SUMMARY_CMD") or None,
    "python_version": os.environ.get("SUMMARY_PYTHON") or None,
    "loaded_modules": os.environ.get("SUMMARY_MODULES") or None,
    "stages": {
        "setup": {"seconds": num("SETUP_SEC")},
        "pre_script": script_stage("PRE_SCRIPT", "PRE_RC", "PRE_SEC"),
        "main": {"exit_code": num("MAIN_RC"), "seconds": num("MAIN_SEC")},
        "post_script": script_stage("POST_SCRIPT", "POST_RC", "POST_SEC"),
    },
    "exit_code": num("OVERALL_RC"),
    "total_seconds": num("TOTAL_SEC"),
}

path = os.environ["SUMMARY_PATH"]
with open(path, "w") as f:
    json.dump(summary, f, indent=2)
    f.write("\n")
print(f"Wrote {path}")
PYEOF
  # Remove the temp per-job venv so it is never archived (summary is written
  # first). User-provided PYTHON_ENV environments are kept.
  if [[ "${SUMMARY_VENV_TEMP:-}" == "1" && -n "${SUMMARY_VENV:-}" && -d "${SUMMARY_VENV}" ]]; then
    rm -rf -- "${SUMMARY_VENV}" || true
    echo "Removed temp job venv: ${SUMMARY_VENV}"
  fi
}
trap write_summary EXIT

is_true() {
  [[ "${1:-}" =~ ^([Tt][Rr][Uu][Ee]|1)$ ]]
}

# Run a user-supplied script: .py via python3, executables directly, else bash
run_user_script() {
  local script="$1"
  if [[ "$script" != /* ]]; then
    script="./${script}"
  fi
  if [[ ! -f "$script" ]]; then
    echo "ERROR: script not found: $script" >&2
    return 127
  fi
  case "$script" in
    *.py)
      python3 "$script"
      ;;
    *)
      if [[ -x "$script" ]]; then
        "$script"
      else
        bash "$script"
      fi
      ;;
  esac
}

cd "${inputDirectory:?inputDirectory not set}"
echo "Working directory: $(pwd)"

# ---------------------------------------------------------------- setup ----
SETUP_START=$(date +%s)

# --- Expand input bundles first ---
# Tapis stages each file of a directory input as its own transfer task
# (~40s/file under tenant load), so many-small-file inputs should be shipped
# as one ZIP. This runs before everything else because the pre-script,
# requirements file, and main script may all live inside the bundle.
if [[ -n "${UNZIP_INPUTS:-}" ]]; then
  IFS=',' read -ra ZIPS <<< "$UNZIP_INPUTS"
  for z in "${ZIPS[@]}"; do
    z="$(echo "$z" | xargs)"
    if [[ -z "$z" ]]; then
      continue
    fi
    if [[ "$z" != *.zip ]]; then
      z="${z}.zip"
    fi
    if [[ ! -f "$z" ]]; then
      echo "ERROR: UNZIP_INPUTS entry not found: $z" >&2
      exit 66
    fi
    unzip -o -q "$z"
    echo "Unzipped: $z"
  done
fi

# --- Extra TACC modules (if any) ---
if [[ -n "${EXTRA_MODULES:-}" ]]; then
  IFS=',' read -ra MODS <<< "$EXTRA_MODULES"
  for mod in "${MODS[@]}"; do
    mod="$(echo "$mod" | xargs)"
    if [[ -n "$mod" ]]; then
      module load "$mod"
    fi
  done
fi

# --- PyLauncher (always available for Python) ---
module load pylauncher || true

# --- Python environment ---
# PYTHON_ENV set: use that environment (created with --system-site-packages if
#   missing) and KEEP it after the job, so repeat jobs skip reinstalls.
# PYTHON_ENV unset: create a temp per-job venv only when pip installs are
#   requested, and remove it on exit so nothing leaks into $HOME or the archive.
ENV_DIR=""
if [[ -n "${PYTHON_ENV:-}" ]]; then
  ENV_DIR="${PYTHON_ENV}"
  if [[ "$ENV_DIR" != /* ]]; then
    ENV_DIR="$(pwd)/${ENV_DIR#./}"
  fi
  if [[ ! -x "${ENV_DIR}/bin/python3" ]]; then
    if [[ -e "$ENV_DIR" ]]; then
      echo "ERROR: PYTHON_ENV '${ENV_DIR}' exists but is not a Python environment (no bin/python3)." >&2
      exit 65
    fi
    echo "PYTHON_ENV not found; creating persistent environment: ${ENV_DIR}"
    python3 -m venv --system-site-packages "$ENV_DIR"
  else
    echo "Reusing Python environment: ${ENV_DIR}"
  fi
elif [[ -n "${PIP_REQUIREMENTS:-}" || -n "${PIP_PACKAGES:-}" ]]; then
  ENV_DIR="${ROOT_DIR}/.job-venv"
  python3 -m venv --system-site-packages "$ENV_DIR"
  export SUMMARY_VENV_TEMP="1"
  echo "Created temp job venv: ${ENV_DIR}"
fi
if [[ -n "$ENV_DIR" ]]; then
  export VIRTUAL_ENV="$ENV_DIR"
  export PATH="${ENV_DIR}/bin:${PATH}"
  export SUMMARY_VENV="$ENV_DIR"
fi

# --- Pip: requirements file (if any) ---
if [[ -n "${PIP_REQUIREMENTS:-}" ]]; then
  REQ="${PIP_REQUIREMENTS}"
  if [[ "$REQ" != /* ]]; then
    REQ="./${REQ}"
  fi
  if [[ ! -f "$REQ" ]]; then
    echo "ERROR: PIP_REQUIREMENTS file not found: $REQ" >&2
    exit 66
  fi
  pip3 install -r "$REQ"
fi

# --- Pip: package list (if any) ---
if [[ -n "${PIP_PACKAGES:-}" ]]; then
  IFS=',' read -ra PKGS <<< "$PIP_PACKAGES"
  CLEAN_PKGS=()
  for pkg in "${PKGS[@]}"; do
    pkg="$(echo "$pkg" | xargs)"
    if [[ -n "$pkg" ]]; then
      CLEAN_PKGS+=("$pkg")
    fi
  done
  if [[ ${#CLEAN_PKGS[@]} -gt 0 ]]; then
    pip3 install "${CLEAN_PKGS[@]}"
  fi
fi

export SUMMARY_PYTHON="$(python3 -V 2>&1 || true)"
export SUMMARY_MODULES="$(module list 2>&1 | tr '\n' ' ' || true)"
export SETUP_SEC=$(( $(date +%s) - SETUP_START ))

# ----------------------------------------------------------- pre-script ----
if [[ -n "${PRE_SCRIPT:-}" ]]; then
  T0=$(date +%s)
  if run_user_script "$PRE_SCRIPT"; then
    export PRE_RC=0
  else
    export PRE_RC=$?
  fi
  export PRE_SEC=$(( $(date +%s) - T0 ))
  if [[ "$PRE_RC" -ne 0 ]]; then
    echo "ERROR: PRE_SCRIPT '${PRE_SCRIPT}' failed (exit ${PRE_RC}); aborting before main run." >&2
    exit "$PRE_RC"
  fi
fi

# ---------------------------------------------------------- main binary ----
# Resolved after PRE_SCRIPT so a pre-script may stage or build the binary.
BINARY="${BINARY:-python3}"
case "$BINARY" in
  python|Python|Python3) BINARY="python3" ;;
esac

RESOLVED_BINARY=""
if [[ "$BINARY" == */* ]]; then
  # Path form: absolute, or relative to the Input Directory
  CAND="$BINARY"
  if [[ "$CAND" != /* ]]; then
    CAND="$(pwd)/${CAND#./}"
  fi
  if [[ -f "$CAND" && ! -x "$CAND" ]]; then
    echo "NOTE: adding execute permission to ${CAND} (staging can drop exec bits)"
    chmod +x "$CAND" || true
  fi
  if [[ -x "$CAND" ]]; then
    RESOLVED_BINARY="$CAND"
  fi
else
  # Name form: resolve on PATH (as set by the profile and EXTRA_MODULES)
  RESOLVED_BINARY="$(command -v "$BINARY" || true)"
fi

if [[ -z "$RESOLVED_BINARY" ]]; then
  echo "ERROR: BINARY '${BINARY}' not found or not executable." >&2
  echo "HINT: use a module-provided name (add its module to EXTRA_MODULES)," >&2
  echo "      './name' for a program inside the Input Directory," >&2
  echo "      or an absolute path such as \$WORK/apps/solver." >&2
  exit 127
fi
export SUMMARY_BINARY="$RESOLVED_BINARY"

# ------------------------------------------------------------------ run ----
MAIN_CMD=("$RESOLVED_BINARY" "$INPUTSCRIPT" "$@")
if is_true "${USE_MPI:-False}"; then
  MAIN_CMD=("${MPI_LAUNCHER:-ibrun}" "${MAIN_CMD[@]}")
fi
export SUMMARY_CMD="${MAIN_CMD[*]}"

T0=$(date +%s)
if "${MAIN_CMD[@]}"; then
  export MAIN_RC=0
else
  export MAIN_RC=$?
fi
export MAIN_SEC=$(( $(date +%s) - T0 ))

if [[ "$MAIN_RC" -ne 0 ]]; then
  echo "ERROR: main script exited with status ${MAIN_RC}; skipping POST_SCRIPT." >&2
  exit "$MAIN_RC"
fi

# ---------------------------------------------------------- post-script ----
if [[ -n "${POST_SCRIPT:-}" ]]; then
  T0=$(date +%s)
  if run_user_script "$POST_SCRIPT"; then
    export POST_RC=0
  else
    export POST_RC=$?
  fi
  export POST_SEC=$(( $(date +%s) - T0 ))
  if [[ "$POST_RC" -ne 0 ]]; then
    if is_true "${POST_SCRIPT_REQUIRED:-False}"; then
      echo "ERROR: POST_SCRIPT '${POST_SCRIPT}' failed (exit ${POST_RC}) and POST_SCRIPT_REQUIRED=True." >&2
      exit "$POST_RC"
    fi
    echo "WARNING: POST_SCRIPT '${POST_SCRIPT}' failed (exit ${POST_RC}); main results are unaffected." >&2
  fi
fi

echo "Done."
