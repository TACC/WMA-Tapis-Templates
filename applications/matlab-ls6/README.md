# About
MATLAB (matrix laboratory) is a multi-paradigm numerical computing environment and proprietary programming language developed by MathWorks.

MATLAB allows computing mathematical equations, matrix manipulations, plotting of functions and data, implementation of algorithms, creation of user interfaces, and interfacing with programs written in other languages, including C, C++, C#, Java, Fortran and Python.

Users need to submit an RT ticket in order to get a license approved before they may use MATLAB.

## App build details
Runs on: LoneStar6<br>
Interactive desktop: NICE DCV<br>
Container/runtime: Tapis v3 ZIP runtime using `interactive-template/interactive.zip`

## Usage
In Core Portals, it's under 'Data Processing' -->  MATLAB R2022b Interactive (LoneStar6)<br>
It is optional to supply a folder of models/results to work on.

## Inputs
1. Example Input: tapis://cloud.data/corral/tacc/aci/CEP/community/app_examples/matlab-batch/
2. Submit to start the interactive job.
3. Open, view, and run matlab_test.m

## Outputs
Anything you save/export in the session will be in the archive file.

## Details on how this app is launched
Exec system: LoneStar6 (execSystemId: ls6, queue: development)<br>
Interactive desktop: NICE DCV (via TACC interactive template)<br>
Container/runtime: Tapis v3 ZIP runtime using `interactive-template/interactive.zip`<br>
Launch command: `_XTERM_CMD` runs the site-installed MATLAB module
    `matlab -desktop`<br>
Libraries/paths: `APPEND_PATH=$PATH`<br>
Resources: 1 node, 128 cores, 256000 MB (~256 GB) RAM, 120 max time<br>
Archiving: Outputs archived to `$WORK/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}`

## Note
After a user has requested a license, user support follows [these steps](https://tacc-main.atlassian.net/wiki/spaces/UP/pages/6652192/Managing+RT+Tickets#MATLAB-Licenses-(Any-portal)%3A).They must be added to the correct unix group to run this application.<br>
2-hour limit: The session ends at 120 min.
