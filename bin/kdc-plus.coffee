# 
# # KDC Plus Bin
#
# Our main bin code, called when executing the `kdc-plus` command.
#
fs                = require 'fs'
path              = require 'path'
{CoffeeTransform} = require '../lib/streams/coffee'
{Commonjs}        = require '../lib/streams/commonjs'
{
  LoadMulti
  StdioTransform
}                 = require '../lib/streams/load'
maniutils         = require '../lib/maniutils'




# ## Compile
#
# The function called when `kdc-plus compile` is used.
compile = (appPath, unknownArgs..., opts={}, log=console.error) ->
  if typeof appPath is 'object' then [opts, appPath] = [appPath, undefined]

  appPath ?= process.cwd()
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

    if opts.coffee? or manifest.coffee?
      opts.coffee = opts.coffee ? manifest.coffee
    else
      opts.coffee = false

    if vwarns? then log warning for warning in vwarns
    if vfails?
      log failure for failure in vfails
      return process.exit 1

    # Take all of our files and make them relative to our appPath if
    # they are relative.
    files = manifest.source.blocks.app.files
    for file,i in files
      # Skip this file if it's an /absolute/path
      if file[0] is path.sep then continue
      files[i] = path.resolve path.join appPath, file

    # Our cjs is a multi-file loader, so allow it to load if the caller wants
    # cjs, otherwise use our default loader
    if opts.commonjs
      cjsopts = extensions: []
      cjsopts.extensions.push '.coffee' if opts.coffee
      loader    = new Commonjs files, cjsopts
    else
      loader    = new LoadMulti files

    # Add our coffee transform
    if opts.coffee
      loader.transform (file, ext) ->
        if ext is '.coffee' then return new CoffeeTransform bare: true

    if opts.transform?
      # Currently we only support a single user transform, so until we figure
      # out the transform cli syntax, lets pretend it was multiple results so
      # that we can later easily support multiple transforms.
      opts.transform  = [opts.transform]
      opts.transExt   = [opts.transExt]
      for transform, i in opts.transform
        transExt = opts.transExt[i]
        loader.transform StdioTransform.Filter transform, transExt



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

    # Now that we've declared everything, pipe our loader to our "outer",
    # which is the final destination for our stream.

    # First, write our closure start to the outer
    outer.write "/* Compiled by kdc-plus v#{opts.version} */\n(function(){\n"

    # On data, write it to our outer
    loader.on 'data', (chunk) -> outer.write chunk

    # And finally, when the data ends, close our app closure
    loader.on 'end', -> outer.write "\n})()"



# ## Exec
#
# The main function called when `kdc-plus` is executed. This mainly just
# calculates options and ensures a manifest loads.
exec = (argv, log=console.error) ->
  program = require 'commander'
  program.version '@@version'

  # Compile command and opts
  compileCmd  = program.command 'compile'
  compileCmd.usage '[options] <kdapp directory>'
  compileCmd.description 'Compile a KDApp'
  compileCmd.option '-c, --coffee', 'CoffeeScript support'
  compileCmd.option '-n, --commonjs', 'Commonjs support'
  compileCmd.option '-t, --transform <bin>', 'Add a Stream Transform Binary'
  compileCmd.option '-e, --trans-ext <ext>', 'A file extension filter '+
    'for the previous transform'
  compileCmd.option '-p, --pipe', 'Pipe to STDOUT instead of to a file'
  compileCmd.option '-f, --file <file>', 'Choose the output file'
  compileCmd.action -> compile arguments..., log


  # Install command and opts
  installCmd  = program.command 'install'
  installCmd.description 'Install the KDApp dependencies, if any.'
  installCmd.option '--production', 'Install production dependencies only'
  installCmd.action -> install arguments..., log

  # Outdated command and opts
  outdatedCmd = program.command 'outdated'
  outdatedCmd.description 'List dependencies that are not met, if any.'
  outdatedCmd.option '--production', 'Outdated production dependencies only'
  outdatedCmd.action -> outdated arguments..., log

  # Add a helper warning that compile is the default command
  program.on '--help', ->
    # I belive commandjs uses consolelog, so we're going to use the same
    # for now
    _log = console.log
    _log '  Legacy Support:'
    _log ''
    _log '    If this bin is called with no arguments it will run the compile'
    _log '    command with options matching that of the original kdc compiler.'
    _log '    This is done to support legacy kdc usage.'
    _log '    For additional options, see `kdc-plus compile --help`'
    _log ''

  # And finally, parse the args
  program.parse argv

  # If there are no args, run compile with legacy kdc args
  # Note: We're using `rawArgs` instead of `args` due to inconsistent
  # behavior with args with the following two commands:
  #   kdc-plus outdated --production
  #   kdc-plus outdated --production ./
  # `args.length == 2` for the first command, `args.length == 0` for the
  # second command.. which seems odd. So, i am using rawArgs instead.
  if program.rawArgs.length == 2
    compile process.cwd(), [], coffee: true, log



# ## Install
#
# Install any of the dependencies specified in the manifest, and also the
# corrisponding dependency files *(package.json, bower.json, etc)*.
install = (appPath, unknownArgs..., opts={}, log=console.error) ->
  if typeof appPath is 'object' then [opts, appPath] = [appPath, undefined]
  log 'Error: Not Implemented'
  process.exit 1



# ## Outdated
#
# outdated checks if any of the dependencies specified in the manifest, and
# also the corrisponding dependency files *(package.json, bower.json, etc)*.
outdated = (appPath, unknownArgs..., opts={}, log=console.error) ->
  if typeof appPath is 'object' then [opts, appPath] = [appPath, undefined]
  log 'Error: Not Implemented'
  process.exit 1





exports.exec      = exec
exports.install   = install
exports.outdated  = outdated
if require.main is module then exec process.argv
