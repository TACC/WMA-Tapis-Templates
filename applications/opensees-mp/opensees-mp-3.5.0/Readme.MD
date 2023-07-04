# OpenSees-MP version 3.5.0

This is a docker container for [OpenSeesMP](https://github.com/OpenSees/OpenSees)

## Details

The application is non-interactive. Once a job using this app has been submitted, the input files
provided in the job submission body are automatically staged and processing is done.
The output can be found in the output directory specified in the application definition (*execSystemOutputDir*).

## Using the OpenSees-MP application

Use the _app.json_ file as a reference for creating the OpenSeesMP application. Simply download the file
or copy its contents and [create the app](https://tapis.readthedocs.io/en/latest/technical/apps.html#creating-an-application).

Note that an application id must be unique, so in general it is a good idea to use a naming scheme likely to result
in a unique id. For example, it is common to include a username as part of the id.

To run the application on a specific system instead of a publicly shared one, users can add the *execSystemId*
attribute under the *jobAttributes* section in the app definition:

```
{
    ...,
    "containerImage": "docker://taccaci/opensees-mp:3.5.0",
    "jobAttributes": {
        "execSystemId": <SYSTEM_NAME_HERE>,
        "execSystemExecDir": "${JobWorkingDir}/jobs/${JobUUID}",
        
        ...
}
```

If using the job definition template, be sure to replace the *execSystemId* with a specific system
(or remove it entirely), update *appId* with the Id of the application you created and change the "--account" in
*appArgs* to your specific account allocation.

### TACC system notes

The binary built by the container is similar to the one in Frontera and LoneStar 6. The only difference
is vectorization. The container image is not using any specific vectorization. Where as, Frontera and LoneStar 6 are using avx 512(512 bit) and avx 2 (256 bit) . There is no performance impact to OpenSees without this vectorization setting in building binary.

## Handling input files

Underneath the *jobAttributes* field in the job definition, there is a subfield called *parameterSet*.
Within *parameterSet* is yet another subfield called *appArgs* where the user can pass in url to be classifed
using two args: an "input1" flag and the path to the TCL file.

```
{
    ...,
    "parameterSet": {
        "appArgs": [
            {
                "arg": "input1"
            },
            {
                "arg": "/TapisInput/input_dir/Example.tcl"
            }
        ]
    
    ...
```