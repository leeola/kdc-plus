# 
# # Main
#
# Our main bit of logic. CLI basically just calls this file, as a function.
#
# Again, i want to make it clear that while it may look like we have an
# almost API, we don't. We've focused on keeping the same error handling
# as KDC. If we end up replacing KDC in the future, we'll include a
# better API oriented setup.
#
kdc   = require './_kdc'



# ## Check deps
checkDeps = (manifest, callback=->) ->
  if not manifest.dependencies? then return callback



# ## Check devDeps
checkDevDeps = (manifest) ->
  if not manifest.devDependencies? then return runKdc(manifest)

  resolveDeps
    devDeps: manifest.devDependencies
    (err) ->
      if err?
        # I don't like this method of handling errors, but it's what KDC
        # so we will follow suit to produce consistent behavior.
        console.log "Error resolving devDependencies. error:#{err.name}, "+
          "message:#{err.message}"
        return process.exit 1



# ## Run KDC
runKdc = (manifest) ->
  kdc()
  # KDC throws process exit errors on everything. So, if this code is still
  # running, kdc succeeded and we can continue with our runtime deps
  # injection.
  checkDeps()




module.exports = checkDebs

