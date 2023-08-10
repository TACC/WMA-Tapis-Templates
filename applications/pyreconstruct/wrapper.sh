#!/bin/bash
set -x
#uncomment below line to debug
#export LD_DEBUG=files
export LD_LIBRARY_PATH="/usr/local/lib/:/usr/local/lib/python3.9/site-packages/PySide6/Qt/lib:$LD_LIBRARY_PATH"
/usr/local/lib/ld-linux-x86-64.so.2 /usr/local/bin/python /app/pyReconstruct/src/PyReconstruct.py