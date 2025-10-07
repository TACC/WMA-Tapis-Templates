# OpenSees Express

This app uses opensees tacc module in a docker container on a VM (wma-exec-01). The container is built and installs the latest OpenSees from its [Github repository](https://github.com/OpenSees/OpenSees.git).

Contact: Wenyang Zhang (TACC)

## Details

NOTE: If a version upgrade is made, make sure to check with POC that the default module opensees points to the latest build.

The application is non-interactive. Once a job using this app has been submitted, the input files
provided in the job submission body are automatically staged and processing is done.
The output can be found in the directory specified in the application definition (*execSystemOutputDir*).

Outputs for OpenSees are generally in .out files. This also dependens on how the input tcl script executes and
redirects output.

Deploying changes: python3 initialize_tenant.py --tenants=DESIGNSAFE --apps=opensees-express
