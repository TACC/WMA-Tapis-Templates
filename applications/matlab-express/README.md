# About
Runs a containerized interactive matlab Docker app via apptainer on wma-dcv-01, made interactive by DCV.

## App build details

* Go to https://matlab.mathworks.com
* create an account with tacc email
* Accept university license
* Download linux version of zip file
* copy the zip file to wma-dcv-01
* unzip file in a temp location
* Use DCV and do the remaining steps in DCV session.
* xhost +SI:localuser:root. sudo -H ./install. xhost -SI:localuser:root
* Set install location to /opt/MATLAB
* After install is done, in the install folder in /opt, delete licenses folder.
* Launch the app using command with this argument -c 10280@matlab.shared.utexas.edu, which is license for unix group in TACC.

### How to install add-ons
* See details in internal wiki for WMA Apps

## Usage
This app is used by DesignSafe users to run Matlab in a lower-computationally-intensive environment that bypasses the HPC queues.

## Inputs / Outputs
Users will have all DesignSafe data sources available mounted into the container, and can select and save new files as needed.
