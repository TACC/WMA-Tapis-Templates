# About
MATLAB (matrix laboratory) is a multi-paradigm numerical computing environment and proprietary programming language developed by MathWorks.

MATLAB allows computing mathematical equations, matrix manipulations, plotting of functions and data, implementation of algorithms, creation of user interfaces, and interfacing with programs written in other languages, including C, C++, C#, Java, Fortran and Python.

Users need to submit an RT ticket in order to get a license approved before they may use MATLAB.

## App build details
Runs on: wma-exec-01<br>
Container/runtime: Tapis v3 ZIP runtime using `matlab-batch-express/matlab-batch-express.zip`

## Usage
This app is not public<br>
It is required to supply a folder of models/results to work on.

## Inputs
1. Example Working Directory: tapis://cloud.data/corral/tacc/aci/CEP/community/app_examples/matlab-batch/
2. Example MATLAB Script:matlab_test.m
3. Submit job and run

## Outputs
Once the job is finished, the results should be in the 'workingDirectory' directory inside your archived output dir (for the above input example) (i.e. the Output Location under Job History)

## Details on how this app is launched
Exec system: VM (execSystemId: wma-exec-01, queue: development)<br>
Container/runtime: Tapis v3 ZIP runtime using `matlab-batch-express/matlab-batch-express.zip`<br>
Launch command: `tapisjob_app.sh` runs the site-installed MATLAB module
    `docker://mathworks/matlab:latest /bin/sh -c "cd /data; matlab -batch ${formattedInputFile}`<br>
Resources: 1 node, 48 cores, 192000 MB (~187.5 GB) RAM, 120 max time<br>
Archiving: Outputs archived to `$WORK/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}`

## Note
After a user has requested a license, user support follows [these steps](https://tacc-main.atlassian.net/wiki/spaces/UP/pages/6652192/Managing+RT+Tickets#MATLAB-Licenses-(Any-portal)%3A).They must be added to the correct unix group to run this application.<br>
2-hour limit: The session ends at 120 min.
