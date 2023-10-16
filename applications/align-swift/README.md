# AlignEM Swift Dev

## App build details

1. This app uses app from https://github.com/mcellteam/swift-ir.git and development_ng branch.

## Details on how this app is launched

1. This app is runs on tapis v3, and the app runs from a wrapper script instead of docker container.
2. The wrapper script is invoked via cmdPrefix attribute in app.json.
3. The docker container is a no-op with just an echo statement.
4. The runner script is mostly similar to AlignEM tapis v2 runner script.

## Note
Using container with AlignEM Swift app resulted in conflicts with dcv libraries and mounted paths. This is the reason for using a 
run script with no-op container.

The no-op container is debian based. Other alternative is to use alpine, but it resulted in errors starting up container.