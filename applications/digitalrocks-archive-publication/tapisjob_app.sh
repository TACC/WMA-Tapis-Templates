#!/bin/bash

set -x

pushd ${publishedRootDir}
zip -r archive/${projectId}_archive.zip ${projectId}

# Move to archive folder to add metadata JSON at the top level of the archive
pushd archive
zip -u ${projectId}_archive.zip ${projectId}_metadata.json \

popd
popd
