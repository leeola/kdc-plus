# 
# # KDC Plus Bin
#
# Our main bin code, called when executing the `kdc-plus` command.
#
fs                = require 'fs'
path              = require 'path'
{CoffeeTransform} = require '../lib/streams/coffee'
{Commonjs}        = require '../lib/streams/commonjs'
{LoadMulti}       = require '../lib/streams/load'
maniutils         = require '../lib/maniutils'




exec = exports.exec = (argv, log=console.error) ->
  opts = require 'commander'

  # Define our opts
  opts.version '@@version'
  opts.usage '[options] <kdapp directory>'
  opts.option '-p, --pipe', 'Pipe to STDOUT instead of to a file'
  opts.option '-f, --file <file>', 'Choose the output file'
  opts.option '--no-coffee', 'No coffee-script support'
  opts.option '-c, --commonjs', 'Support commonjs'
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

  maniutils.load appPath, loadOpts, (err, manifest, vfails, vwarns) ->
    if err?
      log "Error Loading Manifest: #{err.message}"
      return process.exit 1

    # ## CLI & Manifest Defaults
    # Now that we have a manifest loaded, assign our defaults, letting the
    # CLI opts override everything.

    # If they declared pipe and file, warn that file is ignored.
    if opts.file? and opts.pipe
      log 'Warning: --pipe and --file are both defined, file will be ignored.'

    # Since pipe desn't make sense as a manifest option, lets warn it.
    if manifest.pipe is true
      log 'Warning: "pipe" is not supported in the manifest'

    if opts.file? or manifest.file?
      opts.file = opts.file ? manifest.file
    else
      opts.file = 'index.js'

    if opts.commonjs? or manifest.commonjs?
      opts.commonjs = opts.commonjs ? manifest.commonjs
    else
      opts.commonjs = false

    # Remember, coffee defaults to on. So we allow the option of turning it off
    if opts.coffee is false
      opts.coffee = opts.coffee
    else if manifest.coffee is false
      opts.coffee = manifest.coffee


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

    # Now we finally pipe the output out of our program. We either pipe it to
    # a file, or STDOUT (if defined)
    if opts.pipe
      outer   = process.stdout
      loader.on 'end', -> log "KDApp Compiled Successfully!"
    else
      outer   = fs.createWriteStream path.join appPath, opts.file
      outer.on 'finish', -> log "KDApp Compiled Successfully!"

    loader.on 'error', (err) ->
      log "Error Compiling KDApp: #{err.message}"
      process.exit 1

    outer.on 'error', (err) ->
      log "Error Saving Compiled KDApp: #{err.message}"
      process.exit 1

    loader.pipe outer




if require.main is module then exec process.argv
