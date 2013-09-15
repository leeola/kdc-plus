# 
# # CLI
#
# Our tiny cli.
#
# ## NOT API FRIENDLY
#
# A rather large warning, this CLI file exits the process on errors. This is
# due to how KDC responds to failures, and the fact that we want to
# respond with similar behavior for the time being.
#
# This will change in the future when/if we implement our own compiler core.
# 
fs    = require 'fs'
path  = require 'path'
kdc   = require './_kdc'
main  = require './main'




# ## Exec
#
# Our main executable code. Note that we are only *adding* functionality to
# KDC calls. If there is an error that doesn't explicitly involve our
# additions, we pass it through to kdc and let kdc print the normal errors.
# We only add functionality, not replace.
#
# In the future, if we end up replacing KDC with our own implementation, we
# can focus on a more natural API, rather than this process oriented
# thing.
exports.exec = (argv) ->
  appPath = argv[2]
  
  # If no appPath, let kdc throw it.
  if not appPath? then return kdc()

  # Load the manifest. If there is an error, let KDC throw it.
  try
    manifest = fs.readFileSync path.join appPath, 'manifest.json'
    manifest = JSON.parse manifest
  catch err
    return kdc()

  # Call the main logic with our manifest object
  main manifest

