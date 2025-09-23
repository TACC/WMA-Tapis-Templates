# About
The Quantified Uncertainty with Optimization for the Finite Element Method (quoFEM) application facilitates Uncertainty Quantification (UQ) for various simulation models. It offers a user-friendly interface with OpenSees and other tools, and provides access to advanced probabilistic analysis algorithms. quoFEM supports global sensitivity analysis, reliability analysis, Bayesian calibration, surrogate modeling, Monte Carlo-type forward propagation, and deterministic optimization techniques. It makes robust and practical UQ algorithms more accessible to researchers and practitioners in the natural hazards engineering community.

This application was developed by the NHERI SimCenter.

## App build details
Runs on: Stampede3-SimCenter
Interactive desktop: NICE DCV 
Container/runtime: Tapis v3 ZIP runtime using `interactive-template/interactive.zip`

## Usage
In DesignSafe, it's under 'Simulation' --> quoFEM  --> quoFEM (Web Portal) or quoFEM (Download)
quoFEM (Download) is a link to download the app and run locally.

## Inputs
- No required inputs at launch.
- You can open or generate models/data within quoFEM during the session.
- For testing purposes, there's a list of examples in the Menu under Examples. 
  Choose one, click 'Run', view the results.

## Outputs
Anything you save/export furin the session will be in the archive file.

## Details on how this app is launched
Resources: 1 node, 48 cores, 128000 MB (~125 GB) RAM, 120 min max wall time
Archiving: To My Data: `${JobOwner}/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}` 
Submits a Tapis v3 interactive batch job to stampede3-simcenter with the TACC Apptainer profile
(`--tapis-profile tacc-apptainer`) and a DCV-friendly job name (`-dcvserver`).
Creates a Work directory and launches Apptainer with: `--cleanenv --containall --writable-tmpfs`
    Binds:
        `--bind $PWD:$HOME` → inside the container, the path corresponding to your host `$HOME` points to the job working directory.
        `--bind ${STOCKYARD}:$HOME/Work` → inside the container, `~/Work` maps to your $STOCKYARD (persistent storage).
    Display: `DISPLAY=:0` for DCV GUI rendering.
Executes the app in the image: `/simcenter/quoFEM/build/quoFEM`.

## Notes