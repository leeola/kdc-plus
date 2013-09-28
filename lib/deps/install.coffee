# 
# # Install Dependencies
#
# Our little dependency resolving module.
#
path            = require 'path'
autoTransport   = require '../transports/auto'




installNodeDev = (dir, opts={}, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  opts.transport  ?= autoTransport
  opts.command    ?= 'npm install --silent'

  transport = opts.transport

  args = opts.command.split ' '
  args.push dir
  transport args, (err, stdout, stderr) ->
    if err? then return callback err
    if !!stderr then return callback new Error "Unknown NPM Response #{stderr}"
    callback null




exports.installNodeDev    = installNodeDev
