# About
LS-PrePost is capable of importing, editing and exporting LS-DYNA keyword files for generating LS-DYNA input files. The new graphical interface of LS-PrePost can be operated intuitively by the icons and tool bars. It supports the latest Open-GL standards to provide fast rendering for fringe plots and animation results.

## App build details
Runs on: Stampede3
Interactive desktop: NICE DCV 
Container/runtime: Tapis v3 ZIP runtime using `interactive-template/interactive.zip`

## Usage
In Designsafe, it's under 'Simulation' --> LS-DYNA
It is optional to supply a folder of models/results to work on. 

## Inputs
1. Example Input: tapis://cloud.data/corral/tacc/aci/CEP/community/app_examples/ls-prepost/
2. Submit to start the interactive job.
3. Open, view, and edit your LS-DYNA models/results

## Outputs
Anything you save/export furin the session will be in the archive file.

## Details on how this app is launched
Exec system: Stampede3 (execSystemId: stampede3, queue: skx-dev)
Interactive desktop: NICE DCV (via TACC interactive template)
Container/runtime: Tapis v3 ZIP runtime using `interactive-template/interactive.zip`
Launch command: `_XTERM_CMD` runs the site-installed LS-PrePost binary
    `/home1/apps/ANSYS/2024R1/v241/ansys/bin/lsprepost4.10_common/lsprepost`
Libraries/paths: `APPEND_PATH=$PATH`, `LD_LIBRARY_PATH` extended for LS-PrePost lib
Resources: 1 node, 48 cores, 192000 MB (~187.5 GB) RAM, 120 max time
Archiving: Outputs archived to `$WORK/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}` 

## Note
2-hour limit: The session ends at 120 min.