#!/bin/bash

set -x

zip -r ${publishedRootDir}/archive/${projectId}_archive.zip \
       ${publishedRootDir}/archive/${projectId}_metadata.json \
       ${publishedRootDir}/${projectId}
