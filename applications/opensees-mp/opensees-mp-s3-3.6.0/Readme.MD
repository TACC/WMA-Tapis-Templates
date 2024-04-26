# OpenSees-MP Stampede3 version 3.6.0

This app uses OpenSees/3.6.0 tacc module with tapis zip runtime.

Contact: Ian Wang (TACC)

## Details

The application is non-interactive. Once a job using this app has been submitted, the input files
provided in the job submission body are automatically staged and processing is done.
The output can be found in the directory specified in the application definition (*execSystemOutputDir*).

Outputs for OpenSees are generally in .out files. This also dependens on how the input tcl script executes and
redirects output.

Deploying changes: python3 initialize_tenant.py --tenants=PORTALS --systems=stampede3 --apps=opensees-mp/opensees-mp-s3-3.6.0