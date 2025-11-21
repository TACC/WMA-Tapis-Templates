# About
Convert pointclouds to Potree format. Output will be placed in the archive path of the job.

## App details
- Runtime: ZIP bundle at `tapis://cloud.data/corral/tacc/aci/CEP/applications/v3/potree-converter/potree-converter.zip`; runs on exec system `wma-exec-01`
- Script: see `tapisjob_app.sh`. Executes `/opt/PotreeConverter/build/PotreeConverter ${converterInput} -o ${_tapisExecSystemOutputDir} --generate-page index ${addArgs}`.
- Output directory: `${JobWorkingDir}/converter-output` (`_tapisExecSystemOutputDir`), archived to `cloud.data:/tmp/${JobOwner}/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}`.

## Input
- `converterInput` (required): File or folder to convert.
- `addArgs` (optional): Extra arguments forwarded to PotreeConverter, e.g. `-p index --outdir OUTPUT_DIR_NAME --material ELEVATION`. Include `-p index` if you plan to view with the PotreeViewer app.

## Output
- Potree tiles plus a generated `index.html` viewer placed under `${JobWorkingDir}/converter-output`, then archived to the configured archive path on completion.

## Details on how this app is launched
- Execution: Tapis submits a FORK job to `wma-exec-01`, running from `${JobWorkingDir}` with outputs directed to `${JobWorkingDir}/converter-output`.
- Command: `/opt/PotreeConverter/build/PotreeConverter ${converterInput} -o ${_tapisExecSystemOutputDir} --generate-page index ${addArgs}` (from `tapisjob_app.sh`).
- Inputs: `converterInput` auto-mounted into the job directory; optional `addArgs` passed through to PotreeConverter.
- Queue/resources: `development` queue, 1 node, 1 core, 256 GB RAM, up to 1440 minutes.
- Archival: All outputs (including generated page) archived to `cloud.data:/tmp/${JobOwner}/tapis-jobs-archive/${JobCreateDate}/${JobName}-${JobUUID}` with app errors also archived.