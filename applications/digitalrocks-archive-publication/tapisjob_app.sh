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
popd
