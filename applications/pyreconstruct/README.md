# PyReconstruct Tapis V3 app

## Details on how this app is launched

1. Docker image is used from tiffhuff/pyreconstruct:0.0.1
2. To launch PyReconstruct, a wrapper.sh file is used to specific path to the loader. 
   This mechanism is needed due to GLIBC version mismatch between host(LoneStar 6) and the debian 11 container running PyReconstruct.
   The loader from host is always used and it cannot load version 2.29 and above libraries needed by QT used within PyReconstruct. 
   So, the loader path from container is used to launch PyReconstruct.
3. To allow for visibility of QT version needed by PyReconstruct and remaining libraries needed, LD_LIBRARY_PATH is set in the wrapper script.