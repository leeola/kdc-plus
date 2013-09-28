# 
# # Node Transport
#
# # Our node transport, which uses exec.
#
{exec}  = require 'child_process'




module.exports = (args, opts={}, callback) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  command = args.join ' '
  exec command, opts, callback
