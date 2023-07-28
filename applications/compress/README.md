## Compress app

# 07/28/2023
- The current fix utilizes the regex validator in the `app.json` to limit inputs of special characters.
- The first input of `run.sh` file is the compression type. The rest of the arguments (with the use of `"$*"`) is taken as the archive file name.
- Special characters are replaced by underscores.
- Most of the special characters works fine if they are inside single quotes in the input field.
- Some characters do not work when they are not inside quotes such as `& ;` since these characters have unique meaning in command line.
