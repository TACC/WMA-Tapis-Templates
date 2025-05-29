# About
Material Point Method (MPM) is a particle based method that represents the material as a collection of material points, 
and their deformations are determined by Newton’s laws of motion. The MPM is a hybrid Eulerian-Lagrangian approach, 
which uses moving material points and computational nodes on a background mesh.

## App build details
When you launch MPM, the ZIP is unpacked, modules are loaded, environment vars set, and the MPM binary invoked under SLURM with the right MPI wrapper.

## Usage
Inputs include mesh, particles, material models, and boundary conditions.
When the analysis is complete, the outputs are VTK and HDF5 files. These can be further analyzed in ParaView (for example).

## Inputs
Input taken from Community Data ([/corral/tacc/aci/CEP/community/app_examples/mpm/uniaxial_stress](https://cep.tacc.utexas.edu/workbench/data/tapis/community/cloud.data/corral/tacc/aci/CEP/community/app_examples/mpm/uniaxial_stress/))

1. Input Directory: tapis://cloud.data/corral/tacc/aci/CEP/community/app_examples/mpm/uniaxial_stress
2. Input Script (appArgs): mpm.json
3. Submit Job

## Outputs

Go to the output file, go to InputDirectory --> results --> uniaxial-stress-2d-usf
This folder will have a collection .vtp, .h5, and .txt files

There is also a results.ipynb file, you can run it and verify you get the same results.
    I had to pip install tables
    I had to adjust the file path, and make sure the final .h5 file is valid (syntax)

## Details on how this app is launched
1. Tapis fetches and unzips mpm.zip into your job’s working directory on Frontera.
2. Then binds your chosen Tapis storage directory into $inputDirectory (also set as the inputDirectory env var).
3. Injects hidden flags (--tapis-profile mpm, --job-name $JobName) so the SLURM job uses the correct profile and name.
4. Requests reservation resources 
5. Runs module load (intel/19.1.1 impi/19.0.9 boost hdf5 swr/20.0.5)
6. Exports LD_LIBRARY_PATH=$TACC_SWR_LIB:$LD_LIBRARY_PATH so the SWR I/O libraries are found.
7. Launches the Material Point Method solver via MPI wrapper
8. Archives all output files (VTK, HDF5, logs)

## Note