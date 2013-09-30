# 
# # Node Transport
#
# # Our node transport, which uses exec.
#
{exec}  = require 'child_process'



# ## Node Transport
#
# Our Node transport is basically just exec. The API was sort of built
# to reflect Node's exec API anyway. 
module.exports = (command, opts={}, callback) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]
  execOpts      = {}
  execOpts.cwd  = opts.cwd if opts.cwd?
  exec command, execOpts, callback
