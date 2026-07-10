# About
This app uses opensees tacc module with tapis zip runtime.

Contact: Wenyang Zhang (TACC)

## App build details
No container needed — this app is built natively on Stampede3.

## Usage
In DesignSafe, it is under 'Simulation'. It runs on Stampede3.

## Inputs
Testing Steps:
- For the Input Directory go to 'Community Data' and navigate to [Community Data/app_examples/opensees/OpenSeesMP](tapis://designsafe.storage.community/app_examples/opensees/OpenSeesMP)
- For the 'Main Script' parameter type Example.tcl
- For the 'Cores Per Node' type 2

- For developers, run the test job on the skx-dev queue for a maximum run time of 60 minutes

## Outputs

The application is non-interactive. Once a job using this app has been submitted, the input files
provided in the job submission body are automatically staged and processing is done.
The output can be found in the directory specified in the application definition (*execSystemOutputDir*).

Outputs for OpenSees are generally in .out files. This also dependens on how the input tcl script executes and
redirects output.

## Details on how this app is launched
Deploying changes: python3 initialize_tenant.py --tenants=PORTALS,DESIGNSAFE --systems=stampede3 --apps=opensees-mp/opensees-mp-s3

## Note
If a version upgrade is made, make sure to check with POC that the default module opensees points to the latest build.
