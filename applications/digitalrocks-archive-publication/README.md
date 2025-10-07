# About
This app bundles a published project directory (`${projectId}`) into a single ZIP and places it under an `archive/` subfolder alongside the publication. It also adds a JSON metadata file to the top level of that ZIP for distribution or long-term storage. This app is launched in 
the backend when the curator clicks "Publish Dataset".

## App details
From `tapisjobapp.sh`:
1. cd into `$(publishedRootDir)`
2. Ensure the publication is readable (`chmod -R 755 ${projectId}`)
3. Create archive location (`mkdir -p archive/${projectId}`)
4. Create/update the ZIP (`zip -r archive/${projectId}/${projectId}_archive.zip ${projectId}`)
5. Add `${projectId}_metadata.json` at the top level of the ZIP
6. Set ZIP permissions to 755

## Input
- publishedRootDir: Root directory for publications. Archives will be saved in ${publishedRootDir}/archive
- projectId: Project ID, e.g. DRP-1234. The data to be archived should be at ${publishedRootDir}/${projectId}

## Output
ZIP file: ${publishedRootDir}/archive/${projectId}/${projectId}_archive.zip

