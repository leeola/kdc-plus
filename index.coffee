# 
# # kdc Index
# 
# Since kdc is not really a library oriented file, we're exposing
# the whole package as a module. If someone installs it and imports
# `kdc`, they will import this file.
#



exports.bin     = require './bin'
exports.lib     = require './lib'
exports.runtime = require './runtime'
exports.test    = require './test'
