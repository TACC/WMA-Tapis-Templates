#!/bin/bash

set -x

pushd ${publishedRootDir}

# Ensure that the published files are world-readable
chmod -R 755 ${projectId}

mkdir -p archive/${projectId}
find ${projectId} -type f -print0 | xargs -0 sha512sum > archive/${projectId}/manifest-sha512.txt
zip -r archive/${projectId}/${projectId}_archive.zip ${projectId}

# Move to archive folder to add manifest and metadata JSON at the top level of the archive
pushd archive/${projectId}
zip -u ${projectId}_archive.zip manifest-sha512.txt
zip -u ${projectId}_archive.zip ${projectId}_metadata.json
chmod -R 755 ${projectId}_archive.zip

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
        -H "Authorization: Bearer ${tapisTransferToken}" \
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
