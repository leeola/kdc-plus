# 
# # Runtime
#
# Our runtime folder holds the KDFramework files that we will use to include
# the installer. The files in this directory, excluding this file, are
# hand picked by a grunt task and compiled, join, and included into
# the compile target of `kdc`.
#




exports.main = require './main'
