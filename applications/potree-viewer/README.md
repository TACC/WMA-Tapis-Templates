# About
Launch an interactive Potree viewer to browse point clouds converted to Potree format. 

## App details
- Runtime: ZIP bundle at `tapis://cloud.data/corral/tacc/aci/CEP/applications/v3/potree-viewer/potree-viewer.zip`; runs on exec system `wma-exec-01` 
- Container: `docker://taccaci/potree-viewer:1.8.2` launched via Apptainer with `--writable-tmpfs`, 1 GB container memory, and binds for input data (`${_tapisExecSystemInputDir}:/data`), Potree assets, and TLS certs.
- Archive: Job working directory archived to `cloud.data:/tmp/${JobOwner}/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}`; `build` and `libs` are excluded.
- Interactivity: Sends a webhook to `${_INTERACTIVE_WEBHOOK_URL}` with the connection URL, username, and password when the session is ready.

## Inputs
- `viewerInput` (required): File or folder to view. Should contain a Potree bundle (tiles plus `index.html`). 

## Outputs
- Reads input. Renders large 3D point cloud datasets, allowing users to explore, analyze, and make measurements directly in a browser.

## Details on how this app is launched
- Launch: Starts an Apptainer instance running the Potree viewer container, copies Potree `build` and `libs` into `/data`, renders `default.template` to an Nginx config with the chosen port, and starts Nginx in the foreground.
- Notification: Issues a callback to `${_INTERACTIVE_WEBHOOK_URL}` announcing `interactive_session_ready` with the HTTPS URL, job owner, job UUID, and credentials; also echoes the URL to stdout.
- Session lifecycle: Keeps the session alive for `(_tapisMaxMinutes - 2)` minutes, then stops the Apptainer instance and frees the chosen port before job completion and archival.
