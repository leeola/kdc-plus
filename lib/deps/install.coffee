# 
# # Install Dependencies
#
# Our little dependency resolving module.
#
fs                      = require 'fs'
path                    = require 'path'
{exec}                  = require 'child_process'
{_npmErrCodeHumanizer}  = require './outdated'




# ## Private: Install Node
#
# Since the API is identical for node, we're defining an internal single
# function to handle the bulk of the code.
_installNode = (dir, opts={}, callback=->) ->
  fs.exists path.join(dir, 'package.json'), (exists) ->
    if not exists then return callback new Error 'package.json not found'
    exec opts.command, cwd:dir, (err, stdout, stderr) ->
      if err? then return callback _npmErrCodeHumanizer err
      if stderr isnt ''
        return callback new Error "Unknown NPM Response #{stderr}"

      # Remove the last character, as npm tends to add a additional line
      # end character, so we want to trim that.
      stdout = stdout[...-1]

      # Split the response from npm, which is a list of outdated packages.
      packages  = if stdout is '' then [] else stdout.split('\n')
      installed = packages.length > 0

      callback null, installed, packages


# ## Install Node Dev
installNodeDev = (dir, opts={}, callback=->) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]
  opts.command    ?= 'npm install --silent'
  _installNode dir, opts, callback


# ## Install Node Production
installNodeProd = (dir, opts={}, callback=->) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]
  opts.command    ?= 'npm install --production --silent'
  _installNode dir, opts, callback




exports.installNodeDev    = installNodeDev
exports.installNodeProd   = installNodeProd
