# 0.2.1 / 

# 0.2.0 / 2013-10-29

 - Legacy Support: With the heavy changes to the command line interface,
  legacy support now gets it's own special section. The commands now get
  to be first class and all have defaults which are consistent, and legacy
  can simply set whatever options make sense for legacy mode. Legacy is
  currently invokved by `kdc` or `kdc-plus` with no options. In the future,
  this will likely be changed to be *just* the `kdc` command, since that is
  the only thing that would need legacy support.
 - CLI Transforms: `kdc-plus --transform <bin>` accepts an executable which
  can be used to pipe each file into it and read the response. Basically making
  CLI-able transforms.
 - CLI Transform Extensions: `kdc-plus --trans-ext <ext>` accepts a file
  extension for the `--transform` argument. Any files not matching this
  extension will not be passed to the transform. Regex is also accepted.
 - Commands: `kdc-plus` now supports three commands: compile, install, and
  outdated. For help in each, see `kdc-plus <command> -h`
 - --bare: Added bare as an option for coffee output. This may change in the
  near future, as it is mainly here to satisfy legacy requirements.
 - Manifest Option Change. Manifest options are now defined under the "plus"
  as an object. This is due to the growing number of options, and not wanting
  to cause any unknown overlaps in meaning or context.
 - File Specific Options. File options can now override default manifest and
  cli options. The reason that they ovrride cli options is because cli options,
  like manifest options, are "global". File specific options imply a higher
  order of importance, and thusly should be more important. 

# 0.1.1 / 2013-09-27

 - Corrected Repo/Issues URL

# 0.1.0 / 2013-09-27

 - Initial Release, Feature Compatible with KDC
