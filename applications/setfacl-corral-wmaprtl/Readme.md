### Overview
This app runs a shell script to change FACLs on a given filepath, typically used by the portal backend to define access for users on a shared workspace path.

### Usage
The app takes the following parameters:
- `usernames`: A list of comma-separated usernames to run setfacl for
- `directory`: The path to run setfacl against
- `action`: Either "add" or "remove" to update access for the user against the path
- `role`: "reader" for `ro`, "writer" for `rw`, or "none" for `-`

### Components
- `tapisjob_app.sh`: the main shell script running setfacl
- `getUID.sh`: a script to return a user's uid from TAS given a username
- `tas.env`: secrets file containing tas credentials to access TAS by `getUID.sh`
- `JSON.sh`: used by `getUID.sh` to return results as json
