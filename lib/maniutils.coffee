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

  readPath          = path.join appPath, opts.name
  readFileOpts  = encoding: 'utf-8'

  fs.readFile readPath, readFileOpts, (err, data) ->
    if err?.code is 'ENOENT'
      return callback new Error "File #{readPath} does not exist"
    if err? then return callback err

    try
      data = JSON.parse data
    catch err
      return callback err

    validate data, (err, failures, warnings) ->
      if err? then return callback "Validation Error: #{err.message}"

      # I'm not sure how i want to handle this, but for the time being lets
      # assign a default plus object to ensure our namespace always exists.
      data.plus ?= {}

      callback null, data, failures, warnings



# ## Validate
#
# Ensure that the passed in manifest object is valid to the KDC standards.
validate = (manifest, opts={}, callback=->) ->
  if opts instanceof Function then [callback, opts] = [opts, {}]

  if not manifest? then return callback new Error 'Manifest object required'
  
  failures  = []
  warnings  = []

  if not manifest.name? then warnings.push "Warning: Name is missing"
  if not manifest.path? then warnings.push "Warning: Path is missing"

  if not manifest.source?.blocks?.app?.files?
    failures.push "Failure: 'source.blocks.app.files' must be defined"
  else if not (manifest.source.blocks.app.files instanceof Array)
    failures.push "Failure: 'source.blocks.app.files' must be an array"

  if failures.length is 0 then failures = null
  if warnings.length is 0 then warnings = null
  callback null, failures, warnings




exports.load      = load
exports.validate  = validate
