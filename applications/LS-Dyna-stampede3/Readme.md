# Overview
LS-DYNA is also known as ANSYS. It is owned and licensed by Ansys. In order to allow users access to it on DesignSafe, we have to verify with Ansys that their department's license is valid. Then the user must be added to the correct unix group. For more details on these steps, follow the steps in [Confluence](https://tacc-main.atlassian.net/wiki/spaces/UP/pages/6652192#efc41bd9-8d96-4286-8093-7fdb01d62e39). This is a Simulation app that runs on Designsafe and Stampede3.


# Testing
1. Submit a job with either the [parallel](tapis://designsafe.storage.community/app_examples/ls-dyna/parallel) or [serial](tapis://designsafe.storage.community/app_examples/ls-dyna/serial) inputs directories.
2. In parallel, use the input file "myfilename.txt". In serial, use the file "constrained.linear.plate1.k"
3. Select "S" precision.

## Outputs
The output is written into the "inputDirectory" directory, in a directory titled "simulation_${name_of_input_file}". For example, in the testcase input for a serial job, the output would be "simulation_constrained.linear.plate1".
