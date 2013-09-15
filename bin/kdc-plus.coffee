# 
# # KDC Plus Bin
#
# Our main bin code, called when executing the `kdc-plus` command.
#




exec = exports.exec = (argv) ->
  opts = require 'commander'

  # Define our opts
  opts.version '@@version'
  opts.usage '[options] [kdapp directory]'
  opts.parse argv




if require.main is module then exec process.argv
