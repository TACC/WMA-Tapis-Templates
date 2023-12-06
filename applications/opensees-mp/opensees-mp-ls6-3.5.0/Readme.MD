# OpenSees-MP LoneStar6 version 3.5.0

This app uses OpenSees/3.5.0 tacc module. The app uses a base image and mounts the necessary paths to run OpenSees.

Contact: Ian Wang (TACC)

## Details

The application is non-interactive. Once a job using this app has been submitted, the input files
provided in the job submission body are automatically staged and processing is done.
The output can be found in the directory specified in the application definition (*execSystemOutputDir*).

Outputs for OpenSees are generally in .out files. This also dependens on how the input tcl script executes and
redirects output.

Deploying changes: python3 initialize_tenant.py --tenants=PORTALS --systems=ls6 --apps=opensees-mp/opensees-mp-ls6-3.5.0