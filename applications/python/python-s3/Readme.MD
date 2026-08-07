# python — Stampede3

General-purpose app for DesignSafe. Runs Python scripts by default or any executable via `BINARY` with optional PyLauncher and MPI support, user-supplied pre/post scripts, and a machine-readable run summary.

Contact: Krishna Kumar (UT Austin)

## Lifecycle

```
setup (modules, pip)  →  PRE_SCRIPT  →  main (BINARY, default python3)  →  POST_SCRIPT
```

Failure semantics:

- **setup or PRE_SCRIPT fails → job aborts** before the main run (no wasted SUs)
- **main script fails → job fails**, POST_SCRIPT is skipped
- **POST_SCRIPT fails → warning only**, unless `POST_SCRIPT_REQUIRED=True`

Every job writes `job-summary.json` next to `tapisjob.out` — on success and on failure — with per-stage exit codes and timings, the exact command run, the Python version, and the loaded modules. Downstream tools (e.g., provenance manifests) can consume it directly.

## Defaults

- Python 3.12 on Stampede3 SKX nodes
- Serial execution (no MPI)
- PyLauncher module loaded automatically
- No pip installs, extra modules, or pre/post scripts unless requested
- Archives to the submitting user's DesignSafe storage

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `BINARY` | `python3` | Executable for the main run (name on PATH, `./name` in the Input Directory, or absolute path) |
| `USE_MPI` | `False` | Launch the main script with the MPI launcher |
| `MPI_LAUNCHER` | `ibrun` | MPI launch command when `USE_MPI=True` (`srun`/`mpirun` on other systems) |
| `EXTRA_MODULES` | (empty) | Comma-separated TACC modules to load |
| `PYTHON_ENV` | (empty) | Path to a persistent virtual environment to use (created if missing, kept after the job) |
| `PIP_PACKAGES` | (empty) | Comma-separated packages to pip install into the job's Python environment |
| `PIP_REQUIREMENTS` | (empty) | requirements.txt-style file installed into the job's Python environment; job fails if missing |
| `PRE_SCRIPT` | (empty) | Script to run before the main script; missing or failing aborts the job |
| `POST_SCRIPT` | (empty) | Script to run after the main script |
| `POST_SCRIPT_REQUIRED` | `False` | If `True`, a failing post-script fails the job |

All optional. Empty values are skipped entirely.

## Python environment

Two modes, both created with `--system-site-packages` so the module-provided numpy/scipy/mpi4py stack is inherited:

- **Default (temporary):** when `PIP_PACKAGES` or `PIP_REQUIREMENTS` is set, a throwaway venv (`.job-venv`) is created in the job working directory and deleted on exit — nothing leaks into `$HOME`, no packages carry over between jobs, the archive stays small. No environment is created when neither variable is set.
- **Persistent (`PYTHON_ENV`):** point at a path such as `$WORK/envs/myproject` to reuse an environment across jobs and skip repeated pip installs. It is created if missing, never deleted, and pip installs (if any) go into it. Prefer `$WORK`/`$SCRATCH` paths; an environment inside the Input Directory would be archived with your results.

Either way the environment is *activated* for the whole job — its `bin/` is prepended to PATH and `VIRTUAL_ENV` is set — so the pre/post scripts, `pip3`, and the main run all resolve into it, and the default `BINARY=python3` resolves to the environment's interpreter by absolute path (which is what each MPI rank under `ibrun` executes). The path used is recorded as `python_env` in `job-summary.json`.

**Caveat:** pip installs pair with the app's default `python3`. If you override `BINARY` to a different Python interpreter by absolute path, it bypasses the environment and will not see the installed packages.

## Pre/post scripts

`PRE_SCRIPT` and `POST_SCRIPT` name a file in the Input Directory (or an absolute path on the execution system). How it runs is chosen by extension:

- `*.py` → `python3 script.py`
- executable file → run directly
- anything else → `bash script.sh`

Use the pre-script for domain setup the wrapper deliberately does not bake in (file staging, unzipping bundles, building inputs or binaries). Use the post-script for post-processing and cleanup. Set `POST_SCRIPT_REQUIRED=True` when the post-processing output *is* the deliverable (e.g., aggregating a parameter sweep).

**Scope note:** pre/post scripts run as child processes, so `module load` inside them does **not** carry into the main run. Modules the main run needs (libraries, executables) must go in `EXTRA_MODULES`.

## Custom binaries

`BINARY` accepts three forms, resolved *after* the pre-script (so a pre-script may build or stage the binary), and the job fails before the main run if it can't be found:

- **Name** (no `/`): looked up on PATH after `EXTRA_MODULES` are loaded — e.g. `BINARY=OpenSeesMP` with `EXTRA_MODULES=opensees,hdf5/1.14.4`
- **`./name`**: a program shipped inside the Input Directory; the exec bit is restored automatically if staging dropped it
- **Absolute path**: e.g. `$WORK/apps/mysolver` for your own compiled code

The main run is always `[MPI_LAUNCHER] BINARY INPUTSCRIPT ARGS...`, and the resolved absolute path is recorded in `job-summary.json`.

Example — OpenSeesMP (Tcl), 2 nodes:

```
BINARY=OpenSeesMP  EXTRA_MODULES=opensees,hdf5/1.14.4  USE_MPI=True
Input Script: model.tcl
```

## OpenSeesPy

Not built in. Load the runtime modules via `EXTRA_MODULES` and copy the TACC build in a `PRE_SCRIPT`:

```
EXTRA_MODULES=opensees,hdf5/1.14.4   # runtime libraries for the main run
PRE_SCRIPT=setup.sh
```

```bash
# setup.sh
cp ${TACC_OPENSEES_BIN}/OpenSeesPy.so ./opensees.so
```

Then `import opensees as ops` in your main script. (`TACC_OPENSEES_BIN` is set by the opensees module, which `EXTRA_MODULES` loads before the pre-script runs.)

## job-summary.json

```json
{
  "app_id": "python-s3",
  "app_version": "1.0.0",
  "job_uuid": "…",
  "started": "2026-08-07T10:00:00-05:00",
  "ended": "2026-08-07T10:12:34-05:00",
  "input_script": "run_analysis.py",
  "binary": "/opt/apps/python3_12/bin/python3",
  "python_env": null,
  "command": "/opt/apps/python3_12/bin/python3 run_analysis.py --npts 2000",
  "python_version": "Python 3.12.11",
  "loaded_modules": "…",
  "stages": {
    "setup": {"seconds": 41},
    "pre_script": {"script": "setup.sh", "exit_code": 0, "seconds": 3},
    "main": {"exit_code": 0, "seconds": 702},
    "post_script": {"script": null, "exit_code": null, "seconds": null}
  },
  "exit_code": 0,
  "total_seconds": 754
}
```

`null` means the stage did not run.

## Porting to other systems

The wrapper is system-agnostic: only `app.json` (execution system, queue, archive) and `profile.json` (base modules) change per system, plus the `MPI_LAUNCHER` default. To add e.g. `python-ls6`, copy this directory alongside as `applications/python/python-ls6/` and adjust those two files.

## Deploying

```
python3 initialize_tenant.py --tenants=DESIGNSAFE --systems=stampede3 --apps=python/python-s3
```
