# About

Interactive is provided as a base image available at `taccaci/interactive-base:1.1.0`.  
This image includes helper scripts, DCV (Desktop Cloud Visualization) support, and common TACC modules to facilitate building interactive applications.

## App build details

## Usage

To use this image as a base for your own interactive application, add the following line to your Dockerfile:

```
FROM taccaci/interactive-base:1.1.0
```

Alternatively, you can use the image directly by specifying the following container image reference in your application's configuration:

```
"containerImage": "docker://taccaci/interactive-base:1.1.0"
```

## Inputs

Inputs are defined in the application that extends from this base image. This base image does not declare any inputs itself; refer to your specific application's documentation for input parameters.

## Outputs

Outputs are defined in the application that extends from this base image. This base image does not declare any ouputs itself; refer to your specific application's documentation for output parameters.

## Details on how this app is launched

This base image serves as a foundation for building interactive applications and is not intended to be launched directly. Applications that extend from this image define their own launch mechanisms.

## Note