#!/bin/bash

set -x

pushd ${publishedRootDir}

# Ensure that the published files are world-readable
chmod -R 755 ${projectId}

mkdir -p archive/${projectId}

# SHA-256 manifest for the portal: the published landing page's Croissant JSON-LD only accepts
# md5/sha256 file checksums (SHA-512 is rejected), so the portal reads per-file hashes from here
# instead of downloading every file to hash it.
#  - One file per sha256sum call (-n 1), in parallel (-P) across the node's cores: each call then
#    writes one short line to the pipe, which the kernel keeps whole, so parallel output can't
#    interleave mid-line. sort makes the manifest's order stable across runs.
#  - -r: with no files, xargs would otherwise still run sha256sum once and hash its empty stdin,
#    adding a bogus "<hash>  -" line.
#  - pipefail + a .tmp file: if any file fails to hash, no manifest is written at all, so the
#    portal never reads a partial one; it just leaves the publication's files unhashed.
sha256Manifest=archive/${projectId}/manifest-sha256.txt
if ( set -o pipefail
     find ${projectId} -type f -print0 \
         | xargs -0 -r -n 1 -P "${checksumParallelism:-16}" sha256sum \
         | LC_ALL=C sort -k2 > ${sha256Manifest}.tmp ); then
    mv ${sha256Manifest}.tmp ${sha256Manifest}
    chmod 755 ${sha256Manifest}
else
    echo "ERROR: sha256sum failed for one or more files in ${projectId}; ${sha256Manifest} not written."
    rm -f ${sha256Manifest}.tmp
fi

zipFile=${projectId}_archive.zip

# SHA-256 of the finished ZIP, for the portal's Croissant/Google `distribution` entry for it. Run
# from archive/${projectId}. Written to a .tmp file and renamed into place, so the portal never
# reads a partial hash.
hash_archive() {
    if sha256sum ${zipFile} > ${zipFile}.sha256.tmp; then
        mv ${zipFile}.sha256.tmp ${zipFile}.sha256
        chmod 755 ${zipFile}.sha256
    else
        echo "ERROR: sha256sum failed for ${zipFile}; ${zipFile}.sha256 not written."
        rm -f ${zipFile}.sha256.tmp
    fi
}

# Backfill mode: existing publications already have their SHA-512 manifest, ZIP (DRP-1149's is
# 89 GB) and Ranch copy, so only the SHA-256 manifest is generated -- one read of the data. With
# hashArchive=true the existing ZIP is hashed too, which reads it once more.
if [ "${checksumOnly}" = "true" ]; then
    echo "checksumOnly=true: skipping SHA-512 manifest, ZIP archive and Ranch transfer."
    if [ "${hashArchive}" = "true" ] && [ -f archive/${projectId}/${zipFile} ]; then
        pushd archive/${projectId}
        hash_archive
        popd
    fi
    popd
    exit 0
fi

find ${projectId} -type f -print0 | xargs -0 sha512sum > archive/${projectId}/manifest-sha512.txt
# A hash from an earlier run would no longer match once the ZIP is rebuilt below.
rm -f archive/${projectId}/${zipFile}.sha256
zipStatus=0
zip -r archive/${projectId}/${zipFile} ${projectId} || zipStatus=$?

# Move to archive folder to add manifest and metadata JSON at the top level of the archive
pushd archive/${projectId}
# zip -u exits 12 when there's nothing to update (a re-run of an unchanged archive): not a failure.
# It also exits 12 for a file that doesn't exist, so a missing file is checked for separately.
for extraFile in manifest-sha512.txt ${projectId}_metadata.json; do
    if [ ! -f ${extraFile} ]; then
        echo "ERROR: ${extraFile} not found; it can't be added to ${zipFile}."
        zipStatus=1
        continue
    fi
    zip -u ${zipFile} ${extraFile}
    rc=$?
    if [ ${rc} -ne 0 ] && [ ${rc} -ne 12 ]; then
        zipStatus=${rc}
    fi
done
chmod -R 755 ${zipFile}

# Only a ZIP every step succeeded on is hashed, so the portal never publishes a broken archive.
if [ ${zipStatus} -eq 0 ]; then
    hash_archive
else
    echo "ERROR: building ${zipFile} failed (zip exit ${zipStatus}); ${zipFile}.sha256 not written."
fi

popd

# Transfer the completed archive directory to Ranch when transfer settings are provided.
# Preserve and disable xtrace so the token-bearing cURL command is not printed in job logs.
xtrace_was_enabled=0
case "$-" in
    *x*) xtrace_was_enabled=1 ;;
esac
set +x

tapisEnvFile="${TAPIS_ENV_FILE:-${HOME}/.digitalrocks-archive-publication.env}"
if [ -f "${tapisEnvFile}" ]; then
    . "${tapisEnvFile}"
else
    echo "Tapis env file not found at ${tapisEnvFile}; Ranch transfer may be skipped."
fi

tapisTransferToken="${TAPIS_ACCESS_TOKEN:-}"
tapisBaseUrl="${tapisBaseUrl:-https://portals.tapis.io}"
corralSystemId="${corralSystemId:-cloud.data}"

if [ -z "${ranchDestinationDir}" ] && [ -n "${ranchArchiveRootDir}" ]; then
    ranchDestinationDir="${ranchArchiveRootDir%/}/archive/${projectId}"
fi

if [ -n "${tapisTransferToken}" ] && [ -n "${ranchSystemId}" ] && [ -n "${ranchDestinationDir}" ]; then
    echo "Submitting Tapis transfer for ${projectId} archive to Ranch"
    curl --fail --show-error --silent \
        -X POST "${tapisBaseUrl}/v3/files/transfers" \
        -H "X-Tapis-Token: ${tapisTransferToken}" \
        -H "Content-Type: application/json" \
        --data "{
            \"tag\": \"digitalrocks-archive-publication-${projectId}\",
            \"elements\": [
                {
                    \"sourceURI\": \"tapis://${corralSystemId}${publishedRootDir}/archive/${projectId}\",
                    \"destinationURI\": \"tapis://${ranchSystemId}${ranchDestinationDir}\"
                }
            ]
        }"
else
    echo "Skipping Ranch transfer; TAPIS_ACCESS_TOKEN from ${tapisEnvFile}, ranchSystemId, and ranchDestinationDir or ranchArchiveRootDir are required."
fi

if [ "${xtrace_was_enabled}" -eq 1 ]; then
    set -x
fi

popd
