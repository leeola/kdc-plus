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


# ## checkNodeDev()
#
# Check the given directory for Node Dev deps.
#
# **HUGE WARNING:** This is a false as hell function. Node dev dependency
# checks are done with `npm outdated`, but it doesn't work at all. Hasn't
# for the better part of a year. This has been fixed, but i believe it will
# not be available until npm version `1.3.11`. So until that is more reliably
# on installed systems.. or for that matter, even out, we are defaulting
# Node Dev to always failing the check.
#
# See https://github.com/isaacs/npm/pull/3863 for reference.
#
checkNodeDev = (dir, opts={}, callback=->) ->
  if opts instanceof Function
    callback = opts
    opts = {}
  opts.command    ?= 'npm'
  opts.transport  ?= autoTransport

  #transport = opts.transport
  #transport opts.command, (err, stdout, stderr) ->
  callback null, false, []

  




exports.check           = check
exports.checkNodeDev    = checkNodeDev
