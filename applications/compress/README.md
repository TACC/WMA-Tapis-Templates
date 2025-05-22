# About
This is the Compress app. It compresses a file or directory into a .tar.gz or .zip archive for download.

## App build details


## Usage
App is used is used in all our portals. It lives in the 'Utilities' section.

## Inputs
The user selects a single directory or file to be compressed. 

## Outputs
The output is a compressed file (zip or tar.gz).
The original file remains intact. 

## Details on how this app is launched


## Note

Core Portal has an option to compress in the Data Files section. However this does not work. 


### 07/28/2023
- The current fix utilizes the regex validator in the `app.json` to limit inputs of special characters.
- The first input of `run.sh` file is the compression type. The rest of the arguments (with the use of `"$*"`) is taken as the archive file name.
- Special characters are replaced by underscores.
- Most of the special characters works fine if they are inside single quotes in the input field.
- Some characters do not work when they are not inside quotes such as `& ;` since these characters have unique meaning in command line.
