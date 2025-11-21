# About
ADCIRC is a system of computer programs for solving time dependent, free surface circulation and transport problems in two and three dimensions. These programs utilize the finite element method in space allowing the use of highly flexible, unstructured grids. PADCIRC is the Parallel version of the ADCIRC application, which uses multiple compute nodes and is ideal for larger simulations. The tightly coupled SWAN + ADCIRC paradigm allows both wave and circulation interactions to be solved on the same unstructured mesh resulting in a more accurate and efficient solution technique.

## App build details
No container needed — this app is built natively on Stampede3.

## Usage
In DesignSafe, it is under 'Simulation'. It runs on Stampede3.

## Inputs
Testing Steps:
- For the Case Directory go to 'Community Data' and navigate to [Community Data/app_examples/adcirc/padcirc](https://www.designsafe-ci.org/data/browser/tapis/designsafe.storage.community/%2Fapp_examples%2Fadcirc%2Fpadcirc)

- For developers, run the test job on the skx-dev queue for a maximum run time of 60 minutes.

## Outputs

- Once the job is finished, the results should be in the 'padcirc' directory inside your archived output dir (for the above input example) (i.e. the Output Location under Job History)


## Details on how this app is launched
Wrapper script from ZIP template runs padcirc module with required dependencies.

## Note