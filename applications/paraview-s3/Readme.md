ParaView-S3 is an interactive open-source, multi-platform data analysis and visualization application, on Stampede3. It is used in DesignSafe.

The module loads a ssh library that is out of date, and so there is a script `paraview.sh` that must be run to load the module after the interactive session is started.

The module is unable to curl back to the portal's interative session webhook, and so there is a script `paraview.sh` that must be run to load the module after the interactive session is started.

#Testing
1. Begin a session
2. Navigate to Source -> wavelet
3. Click apply -> contour
4. The wavelet should be displayed.
