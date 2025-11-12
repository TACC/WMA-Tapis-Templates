# About
Launch an interactive RStudio Desktop session on TACC's Lonestar6 system. The Rocker RStudio container runs under Apptainer, and a TAP-managed reverse proxy exposes the desktop securely back to the requesting portal.

## App build details
- Container image: `docker://rocker/rstudio:4.3`, executed with the `SINGULARITY_RUN` option.
- Resources: 1 Lonestar6 node, 128 CPU cores, 256 GB RAM, 120 minutes on the `development` queue.

## Usage
You will find this app under Data Processing in the CEP(Frontera) and PTDataX(LS6) portals.

## Inputs
1. Launch the job; once the SLURM allocation is ready, the portal sends a session-ready notification with the URL.
2. Follow that link and the RStudio Desktop UI loads in your browser.
3. Work within your project directory, run R scripts, or notebooks.
4. When finished, close the RStudio session and stop the job from the portal to release the Lonestar6 resources.

## Outputs
- Files saved through RStudio land in the job working directory and are archived to `${WORK}/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}` when the job completes.
- Wrapper and container logs are included in the archived output for debugging.
