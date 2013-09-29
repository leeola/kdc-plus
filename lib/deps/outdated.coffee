# 
# # Check Dependencies
#
# A simple module as a function to check the dependencies of a directory.
# 
path            = require 'path'
verexp          = require 'verbal-expressions'
autoTransport   = require '../transports/auto'




check = (opts, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts={}
  
  # Define our default options
  opts.devDeps     ?= true
  opts.prodDeps    ?= true

  checkFns        = [
    [checkNode, 'node']
  ]
  result = false
  results = {}

  do next = (index=0) ->
    if index >= checkFns.length then return callback null, result, results

    [checkFn, checkName] = checkFns[index]

    # If the check() caller didnt specify this type, go next()
    if opts[checkName] isnt true then return next ++index

    checkFn opts, (err, _result, items) ->
      if err? then return callback err

      if _result then result = _result
      results[type] =
        result: result
        items : items

      next ++index



# ## npm Error Code Humanizer
#
# The error responses from npm can be a bit cryptic when dealing with the
# process itself (as we are), so this simply returns new errors based on
# known code responses.
_npmErrCodeHumanizer = (err) ->
  switch err.code
    when 34 then return new Error 'package.json not found'
    else return err


# ## Node Development Outdated
#
# Check the given directory for Node Dev deps.
#
# **HUGE WARNING:** This is a false as hell function. Node dev dependency
# checks are done with `npm outdated`, but it doesn't work at all. Hasn't
# for the better part of a year. This has been fixed, but i believe it will
# not be available until npm version `1.3.11`. So until that is more reliably
# on installed systems.. or for that matter, even out, we are defaulting
# Node Dev to always saying outdated.
# See https://github.com/isaacs/npm/pull/3863 for reference.
#
outdatedNodeDev = (dir, opts={}, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  opts.command    ?= 'npm outdated'
  opts.transport  ?= autoTransport

  #transport = opts.transport
  #transport opts.command, (err, stdout, stderr) ->
  callback null, true, []



# ## Node Production Outdated
outdatedNodeProd = (dir, opts={}, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  opts.command    ?= 'npm outdated' # should use --production once the npm
                                    # update goes live.
  opts.transport  ?= autoTransport

  transportOpts =
    cwd: dir
  
  args = opts.command.split ' '
  transport args, transportOpts, (err, stdout, stderr) ->
    if err? then return callback _npmErrCodeHumanizer err
    if stderr isnt ''
      return callback new Error "Unknown NPM Response '#{stderr}'"

    # Split the response from npm, which is a list of outdated packages.
    # Note that removal of the last result, as npm tends to add a additional
    # line end character, so we want to trim that.
    packages    = stdout.split('\n')[...-1]
    outdated   = packages.length > 0
    callback null, outdated, packages




exports._npmErrCodeHumanizer  = _npmErrCodeHumanizer
exports.outdatedNodeDev       = outdatedNodeDev
exports.outdatedNodeProd      = outdatedNodeProd
