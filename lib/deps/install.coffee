# 
# # Install Dependencies
#
# Our little dependency resolving module.
#
path                    = require 'path'
{_npmErrCodeHumanizer}  = require './outdated'
autoTransport           = require '../transports/auto'




# ## Private: Install Node
#
# Since the API is identical for node, we're defining an internal single
# function to handle the bulk of the code.
_installNode = (dir, opts={}, callback=->) ->
  opts.transport  ?= autoTransport

  transport = opts.transport

  # npm requires the cwd be the location of our installation directory.
  transportOpts =
    cwd: dir

  args = opts.command.split ' '
  args.push dir
  transport args, transportOpts, (err, stdout, stderr) ->
    if err? then return callback _npmErrCodeHumanizer err
    if stderr isnt ''
      return callback new Error "Unknown NPM Response #{stderr}"

    # Split the response from npm, which is a list of packages installed.
    # Note that removal of the last result, as npm tends to add a additional
    # line end character, so we want to trim that.
    packages = stdout.split('\n')[...-1]
    installed = packages.length > 0
    callback null, installed, packages


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
