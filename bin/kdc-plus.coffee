# 
# # KDC Plus Bin
#
# Our main bin code, called when executing the `kdc-plus` command.
#
fs          = require 'fs'
path        = require 'path'
compilers   = require '../lib/compilers'
maniutils   = require '../lib/maniutils'




exec = exports.exec = (argv, log=console.error) ->
  opts = require 'commander'

  # Define our opts
  opts.version '@@version'
  opts.usage '[options] [kdapp directory]'
  opts.parse argv

  [appPath, unhandledArgs] = opts.args

  if not appPath?
    log 'Invalid KDApp Path'
    return process.exit 1

  if unhandledArgs?
    log "Unknown Arguments: #{JSON.stringify unhandledArgs}"
    return process.exit 1

  appPath = path.resolve appPath
  loadOpts =
    validate: true

  manitools.load appPath, loadOpts, (err, manifest) ->
    if err?
      log "Error Loading Manifest: #{err.message}"
      return process.exit 1

    files = manifest.source.blocks.app.files

    compiler = compilers[manifest.compiler]

    compiler files, (err, out) ->
      if err?
        log "Error Compiling KDApp: #{err.message}"
        return process.exit 1

      fs.writeFile path.join(appPath, 'indexj.js'), out, (err) ->
        if err?
          log "Error Saving Compiled KDApp: #{err.message}"
          return process.exit 1




if require.main is module then exec process.argv
