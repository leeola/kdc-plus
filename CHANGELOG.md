# 0.2.0 /

 - CLI Transforms: `kdc-plus --transform <bin>` accepts an executable which
  can be used to pipe each file into it and read the response. Basically making
  CLI-able transforms.
 - CLI Transform Extensions: `kdc-plus --trans-ext <ext>` accepts a file
  extension for the `--transform` argument. Any files not matching this
  extension will not be passed to the transform. Regex is also accepted.
 - Commands: `kdc-plus` now supports three commands: compile, install, and
  outdated. For help in each, see `kdc-plus <command> -h`

# 0.1.1 / 2013-09-27

 - Corrected Repo/Issues URL

# 0.1.0 / 2013-09-27

 - Initial Release, Feature Compatible with KDC
