# 
# # Manifest Utilities
#
# Just a simple utils library, focused around the manifest file.
fs      = require 'fs'
path    = require 'path'




# ## Load
#
# Load a manifest file, with options to automatically parse and validate.
load = (appPath, opts={}, callback=->) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]

  if not appPath? then return callback new Error 'appPath is required'
  opts.validate ?= false
  opts.name     ?= 'manifest.json'

  fs.readFile path.join(appPath, opts.name), (err, data) ->
    if err? then return callback err

    try
      data = JSON.parse data
    catch err
      return callback err

    validate data, (err, failures, warnings) ->
      if err? then return callback "Validation Error: #{err.message}"
      callback null, data, failures, warnings




validate = (manifest, opts={}, callback=->) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]

  if not manifest? then return callback new Error 'Manifest object required'
  
  failures  = []
  warnings  = []

  if not manifest.name? then warning.push "Warning: Name is missing"
  if not manifest.path? then warning.push "Warning: Path is missing"

  if not manifest.source?.blocks?.app?.files?
    failures.push "Failure: 'source.blocks.app.files' must be defined"
  else if manifest.source.blocks.app.files instanceof Array
    failures.push "Failure: 'source.blocks.app.files' must be an array"

  if failures.length is 0 then failures = null
  if warnings.length is 0 then warnings = null
  callback null, failures, warnings




exports.load      = load
exports.validate  = validate
