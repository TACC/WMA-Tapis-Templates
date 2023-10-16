# AlignEM Swift Dev

## App build details

1. This app uses app from https://github.com/mcellteam/swift-ir.git in the development_ng branch.
2. An example file is available here https://github.com/mcellteam/swift-ir/blob/development_ng/docs/user/alignem_swift/AlignEM_SWiFT_Quick_Example.rst.

## Details on how this app is launched

1. This app is runs on tapis v3, and the app runs from a wrapper script instead of docker container.
2. The wrapper script is invoked via cmdPrefix attribute in app.json.
3. The docker container is a no-op with just an echo statement.
4. The runner script is mostly similar to AlignEM tapis v2 runner script.