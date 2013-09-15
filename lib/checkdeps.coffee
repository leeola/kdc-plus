# 
# # Check Dependencies
#
# A simple module as a function to check the dependencies of a directory.
# 
{execFile}  = require 'child_process'
fs          = require 'fs'
path        = require 'path'
verexp      = require 'verbal-expressions'




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
    if index >= checkFns.length return callback null, result, results

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


checkNode = (opts={}, callback=->) ->
  




module.exports      = check
exports.check       = check
exports.checkNode   = checkNode
