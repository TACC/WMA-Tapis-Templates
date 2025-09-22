# About
ADCIRC is a system of computer programs for solving time dependent, free surface circulation and transport problems in two and three dimensions. These programs utilize the finite element method in space allowing the use of highly flexible, unstructured grids.

## App build details
No container needed — this app is built natively on Frontera.

## Usage
In DesignSafe, it is under 'Simulation'. It runs on Frontera.

## Inputs
Testing Steps:
- For the Case Directory go to 'Community Data' and navigate to [Community Data/app_examples/adcirc/adcirc_inputs](https://www.designsafe-ci.org/data/browser/tapis/designsafe.storage.community/%2Fapp_examples%2Fadcirc%2Fadcirc_inputs)

- For developers, run the test job on the development queue for a maximum run time of 60 minutes.

## Outputs

- Once the job is finished, the results should be in the 'adcirc-inputs' directory inside your archived output dir (for the above input example) (i.e. the Output Location under Job History)

 Note: For an output example navigate to 
 [Community Data/app_examples/adcirc_outputs](https://www.designsafe-ci.org/data/browser/projects/PRJ-1305/workdir/%2Fapp_examples%2Fadcirc_outputs)

## Details on how this app is launched
Wrapper script from ZIP template runs adcirc module with required dependencies.

## Note