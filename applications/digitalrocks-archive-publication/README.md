# About
This app bundles a published project directory (`${projectId}`) into a single ZIP and places it under an `archive/` subfolder alongside the publication. It also creates a SHA-512 manifest for the published files and adds the manifest and JSON metadata file to the top level of that ZIP for distribution or long-term storage, plus a SHA-256 manifest the portal reads to publish per-file checksums (Croissant only accepts md5/sha256) and a manifest of CSV/TSV header rows it reads to publish each table's columns. This app is launched in 
the backend when the curator clicks "Publish Dataset".

## App details
From `tapisjobapp.sh`:
1. cd into `$(publishedRootDir)`
2. Ensure the publication is readable (`chmod -R 755 ${projectId}`)
3. Create archive location (`mkdir -p archive/${projectId}`)
4. Create the SHA-256 manifest the portal reads for Croissant file checksums (`manifest-sha256.txt`): hashed in parallel, sorted by path, and only written if every file hashes successfully
5. Write the CSV/TSV header manifest the portal reads for Croissant `recordSet` columns (`manifest-columns.txt`, 0.0.4+): each `.csv`/`.tsv` file's first line, only written if every file is read
6. If `checksumOnly=true`, hash the existing ZIP when `hashArchive=true`, then stop here
7. Create the SHA-512 checksum manifest (`find ${projectId} -type f -print0 | xargs -0 sha512sum > archive/${projectId}/manifest-sha512.txt`)
8. Create/update the ZIP (`zip -r archive/${projectId}/${projectId}_archive.zip ${projectId}`)
9. Add `manifest-sha512.txt` and `${projectId}_metadata.json` at the top level of the ZIP
10. Set ZIP permissions to 755
11. If every ZIP step succeeded, write the ZIP's SHA-256 (`${projectId}_archive.zip.sha256`)
12. Submit a Tapis transfer to Ranch when transfer settings are provided

## Input
- publishedRootDir: Root directory for publications. Archives will be saved in ${publishedRootDir}/archive
- projectId: Project ID, e.g. DRP-1234. The data to be archived should be at ${publishedRootDir}/${projectId}
- ranchSystemId: Optional Tapis storage system ID for Ranch. If omitted, Ranch transfer is skipped.
- ranchDestinationDir: Optional full destination directory on Ranch, e.g. /scoutfs/projects/OTH21076/archive/DRP-1234
- ranchArchiveRootDir: Optional Ranch archive root. Used to build ${ranchArchiveRootDir}/archive/${projectId} when ranchDestinationDir is omitted.
- corralSystemId: Optional Tapis storage system ID for the Corral source. Defaults to cloud.data.
- tapisBaseUrl: Optional Tapis API base URL. Defaults to https://portals.tapis.io.
- checksumOnly: Optional, defaults to `false`. When `true`, only `manifest-sha256.txt` and `manifest-columns.txt` are written (no SHA-512 manifest, no ZIP, no Ranch transfer), reading each file once. Use it to backfill the SHA-256 manifest for publications archived by v0.0.2 or earlier; the portal's `compute_publication_checksums` management command submits these jobs.
- hashArchive: Optional, defaults to `false`. With `checksumOnly=true`, also writes `${projectId}_archive.zip.sha256` for the publication's existing ZIP, reading it once more. A full run always hashes the ZIP it builds. The portal's `compute_publication_checksums` command sets it.
- checksumParallelism: Optional (not an app parameter; script default 16). Number of files hashed concurrently for the SHA-256 manifest.

## Output
ZIP file: ${publishedRootDir}/archive/${projectId}/${projectId}_archive.zip
Manifest file: ${publishedRootDir}/archive/${projectId}/manifest-sha512.txt
SHA-256 manifest: ${publishedRootDir}/archive/${projectId}/manifest-sha256.txt
ZIP SHA-256: ${publishedRootDir}/archive/${projectId}/${projectId}_archive.zip.sha256
CSV/TSV header manifest: ${publishedRootDir}/archive/${projectId}/manifest-columns.txt

Both manifests use `sha*sum` format: `<hex digest>  ${projectId}/<path>`, one line per file. The portal removes the leading `${projectId}/` to match each line to the file's path on its published Tapis system. GNU `sha*sum` starts a line with `\` and escapes the path when a filename contains a backslash or newline; the portal's parser handles that.

`manifest-sha256.txt` is written to a temporary file and renamed into place only if every file hashed, so if it exists it's complete. The portal reads it once the job ends, whatever the job's final status.

`manifest-columns.txt` has one line per `.csv`/`.tsv` file (case-insensitive extension), sorted by path: `<base64 of ${projectId}/<path>> <base64 of the file's first line>`, with the line's CR/LF removed and at most 64 KiB read. Base64 keeps any filename or header on one line. The portal parses each header as CSV (TSV for `.tsv`) and stores the column names, which give the file a Croissant `recordSet`. It's written to a temporary file and renamed into place, like the SHA-256 manifest.

`${projectId}_archive.zip.sha256` is one `sha256sum` line for the finished ZIP: `<hex digest>  ${projectId}_archive.zip`. It's written the same way, and only when every step building the ZIP succeeded (a `zip -u` with nothing to update, exit 12, counts as success; a missing `manifest-sha512.txt` or metadata JSON counts as failure). A full run deletes any earlier one before rebuilding the ZIP. The portal stores it with the publication and lists the ZIP, with this checksum, as a download in the landing page's Croissant/schema.org `distribution`.

## Ranch transfer
When `ranchSystemId` and a destination are provided, the script submits a Tapis transfer after the ZIP, its checksum and the checksum manifests are complete:

- Source URI: tapis://${corralSystemId}${publishedRootDir}/archive/${projectId}
- Destination URI: tapis://${ranchSystemId}${ranchDestinationDir}

The Tapis bearer token is not passed as a job parameter. The script sources `${HOME}/.digitalrocks-archive-publication.env` with command tracing disabled, then reads `TAPIS_ACCESS_TOKEN`.

Example env file:

```bash
export TAPIS_ACCESS_TOKEN="..."
```
