#!/bin/bash

set -x

pushd ${publishedRootDir}
mkdir -p archive/${projectId}
zip -r archive/${projectId}/${projectId}_archive.zip ${projectId}

# Move to archive folder to add metadata JSON at the top level of the archive
pushd archive/${projectId}
zip -u ${projectId}_archive.zip ${projectId}_metadata.json \

popd
popd
