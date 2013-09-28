# 
# # Install Dependencies
#
# Our little dependency resolving module.
#
path            = require 'path'
autoTransport   = require '../transports/auto'




# ## Private: Install Node
#
# Since the API is identical for node, we're defining an internal single
# function to handle the bulk of the code.
_installNode = (dir, opts={}, callback=->) ->
  opts.transport  ?= autoTransport

  transport = opts.transport

  args = opts.command.split ' '
  args.push dir
  transport args, (err, stdout, stderr) ->
    if err?
      switch err.code
        when 34 then callback new Error 'package.json not found'
        else callback err
      return
    if !!stderr then return callback new Error "Unknown NPM Response #{stderr}"
    callback null


# ## Install Node Dev
installNodeDev = (dir, opts={}, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  opts.command    ?= 'npm install --silent'
  _installNode dir, opts, callback


# ## Install Node Production
installNodeProd = (dir, opts={}, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  opts.command    ?= 'npm install --production --silent'
  _installNode dir, opts, callback




exports.installNodeDev    = installNodeDev
exports.installNodeProd   = installNodeProd
