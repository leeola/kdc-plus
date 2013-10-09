# 
# # Check Dependencies
#
# A simple module as a function to check the dependencies of a directory.
# 
path            = require 'path'
verexp          = require 'verbal-expressions'
autoTransport   = require '../transports/auto'





# ## Private: Outdated
_outdated = (dir, opts={}, callback=(->), production) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]
  opts.node ?= false

  # Next, get a list of all outdated functions we are going to call
  outdaters = []
  if production
    outdaters.push outdatedNodeProd if opts.node is true
  else
    outdaters.push outdatedNodeDev  if opts.node is true

  # Our list of outdated functions from all outdaters
  packages = []

  # and immediately iterate our outdated functions
  do iterOutdaters = ->
    outdater = outdaters.pop()
    if not outdater? then return callback null, packages.length > 0, packages
    outdater dir, opts, (err, _packages) ->
      packages = packages.concat _packages
      if err? then return callback err, packages.length > 0, packages
      iterOutdaters()



# ## Public Outdated Functions
outdatedDev   = (d, o, c) -> _outdated d, o, c, false
outdatedProd  = (d, o, c) -> _outdated d, o, c, true



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
  opts.command    ?= 'npm outdated --silent'

  callback null, true, []



# ## Node Production Outdated
#
# This function is a bit "overly complex" due to the double-async calls,
# but this is due to the desire to make outdated checks **as fast as
# possible**. Why? Read the module description.
outdatedNodeProd = (dir, opts={}, callback=->) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]
  transport = opts.transport ?= autoTransport
  # should use --production as well once the npm update goes live.
  opts.command    ?= 'npm outdated --silent'

  # We're storing our results in this scope so that each asynchronous function
  # can check the results of the other functions.
  err       = null
  exists    = null
  packages  = null
  outdated  = null
  

  # We use test -e, which checks for the existance of a file/dir.
  # For more info see `info test`
  transport "test -e #{path.join(dir, 'package.json')}", (_err) ->
    exists = not _err?
    if err? then return # exec already handled it
    # If exists calls back first, and it's false bail right away.
    if not exists then return callback new Error 'package.json not found'
    # If outdated beat us, it would not callback. So we need to do it
    if outdated? then return callback null, outdated, packages


  transport opts.command, cwd:dir, (_err, stdout, stderr) ->
    err = _err
    if exists is false then return # exists already called back
    if err? then return callback _npmErrCodeHumanizer err
    if stderr isnt ''
      return callback new Error "Unknown NPM Response '#{stderr}'"

    # Remove the last character, as npm tends to add a additional line
    # end character, so we want to trim that.
    stdout = stdout[...-1]

    # Split the response from npm, which is a list of outdated packages.
    packages  = if stdout is '' then [] else stdout.split('\n')
    outdated  = packages.length > 0

    # Only callback if exists already called back true
    if exists? then callback null, outdated, packages




exports._npmErrCodeHumanizer  = _npmErrCodeHumanizer
exports._outdated             = _outdated
exports.outdatedDev           = outdatedDev
exports.outdatedProd          = outdatedProd
exports.outdatedNodeDev       = outdatedNodeDev
exports.outdatedNodeProd      = outdatedNodeProd
