# 
# # KDC Plus Bin
#
# Our main bin code, called when executing the `kdc-plus` command.
#
fs                = require 'fs'
path              = require 'path'
{CoffeeTransform} = require '../lib/streams/coffee'
{Commojs}         = require '../lib/streams/commonjs'
{LoadMulti}       = require '../lib/streams/load'
maniutils         = require '../lib/maniutils'




exec = exports.exec = (argv, log=console.error) ->
  opts = require 'commander'

  # Define our opts
  opts.version '@@version'
  opts.usage '[options] [kdapp directory]'
  opts.parse argv

  #Hack for now
  opts.coffee ?= true

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

  maniutils.load appPath, loadOpts, (err, manifest, vfails, vwarns) ->
    if err?
      log "Error Loading Manifest: #{err.message}"
      return process.exit 1

    if vwarns? then log warning for warning in vwarns
    if vfails?
      log failure for failure in vfails
      return process.exit 1

    cwd = process.cwd()
    files = manifest.source.blocks.app.files
    files[i] = path.join(appPath, file) for file,i in files

    if opts.commonjs
      cjsopts = extensions: []
      cjsopts.extensions.push '.coffee' if opts.coffee
      loader    = new Commonjs files, cjsopts
    else
      loader    = new LoadMulti files

    if opts.coffee
      loader.transform (file, ext) ->
        if ext is '.coffee' then return new CoffeeTransform()

    loader.on 'error', (err) ->
      log "Error Compiling KDApp: #{err.message}"
      process.exit 1

    destination = fs.createWriteStream path.join appPath, 'index.js'
    destination.on 'error', (err) ->
      log "Error Saving Compiled KDApp: #{err.message}"
      process.exit 1

    destination.on 'end', ->
      log "KDApp Compiled Successfully!"

    loader.pipe destination




if require.main is module then exec process.argv
