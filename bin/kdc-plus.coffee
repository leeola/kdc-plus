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
{PistachioThis}   = require '../lib/streams/pistachio'
{ReadPiper}       = require '../lib/streams/utils'
{
  installDev
  installProd
}                 = require '../lib/deps/install'

{
  outdatedDev
  outdatedProd
}                 = require '../lib/deps/outdated'




# The following variable is replaced by Grunt with the version found
# in package.json
VERSION = '@@version'



# ## Load Manifest
#
# Since many of the commands load the manifest, and have to deal with
# failures/etc in the same manner, this is a little convenience function
# which handles the grunt work and returns the manifest.
_loadManifest = (appPath, log, callback) ->
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

    callback manifest



# ## Opt Finder
#
# Since our options cascade from File -> CLI -> General -> Default
# we have a function for handling this rather large and specific type of code
_fopt_finder = (file, manifest, copts) ->
  popts = manifest.plus
  fopts = manifest.plus.files?[file] ? {}

  defaultOpt = (optName, optDef) ->
    fopts[optName] ? copts[optName] ? popts[optName] ? optDef

  bare          : defaultOpt 'bare', false
  coffee        : defaultOpt 'coffee', false
  commonjs      : defaultOpt 'commonjs', false
  pistachioThis : defaultOpt 'pistachioThis', false





# ## Compile
#
# The function called when `kdc-plus compile` is used.
compile = (appPath, unknownArgs..., copts={}, log=console.error) ->
  if typeof appPath is 'object' then [copts, appPath] = [appPath, undefined]

  appPath ?= process.cwd()
  appPath = path.resolve appPath

  _loadManifest appPath, log, (manifest) ->
    # ## CLI & Manifest Defaults
    # Now that we have a manifest loaded, assign our defaults, letting the
    # CLI opts override everything.

    # If they declared pipe and file, warn that file is ignored.
    if copts.file? and copts.pipe
      log 'Warning: --pipe and --file are both defined, file will be ignored.'

    # Since pipe desn't make sense as a manifest option, lets warn it.
    if manifest.pipe is true
      log 'Warning: "pipe" is not supported in the manifest'

    copts.file = copts.file ? manifest.file ? 'index.js'

    compileStream = null
    # Take all of our files and make them relative to our appPath if
    # they are relative.
    files = manifest.source.blocks.app.files
    for file in files then do ->
      # Get the file opts, and make sure to do it before we resolve the file
      # path
      fopts = _fopt_finder file, manifest, copts
      file  = path.resolve path.join appPath, file if file[0] isnt path.sep

      if fopts.commonjs
        cjsopts = extensions: []
        cjsopts.extensions.push '.coffee' if fopts.coffee
        loader    = new Commonjs [file], cjsopts
      else
        loader    = new LoadMulti [file]

      # Add our coffee transform
      if fopts.coffee
        loader.transform (file, ext) ->
          if ext is '.coffee' then return new CoffeeTransform bare: fopts.bare

      if fopts.pistachioThis
        loader.transform -> new PistachioThis()

      # note that use of copts, *not fopts*. This is because it is purely a
      # command line option, but we still need to add the transforms here.
      if copts.transform?
        # Currently we only support a single user transform, so until we figure
        # out the transform cli syntax, lets pretend it was multiple results so
        # that we can later easily support multiple transforms.
        transforms  = [copts.transform]
        transExts   = [copts.transExt]
        for transform, i in transforms
          transExt = transExts[i]
          loader.transform StdioTransform.Filter transform, transExt

      # Now that we have added our transforms to our loader, wrap it in a
      # ReadPiper so that we can pipe consectutive streams together.. 
      # Essentially concat the streams
      if compileStream?
        compileStream = compileStream.pipe new ReadPiper loader
      else
        compileStream = loader

    # Now we finally pipe the output out of our program. We either pipe it to
    # a file, or STDOUT (if defined)
    if copts.pipe
      outer   = process.stdout

      # For pipe, there is nothing we need to end. So when our loader is done,
      # make sure to add our closure-close, and log success
      compileStream.on 'end', ->
        outer.write "\n})();"
        log "KDApp Compiled Successfully!"
    else
      outer   = fs.createWriteStream path.join appPath, copts.file

      # When our loader is done, close our closure and end the file stream
      compileStream.on 'end', -> outer.end "\n})();"
      # We wait till the file stream ends fully to ensure we don't prematurely
      # call success if an error occurs.. it just looks bad when you do that.
      outer.on 'finish', ->
        log "KDApp Compiled Successfully!"

    compileStream.on 'error', (err) ->
      log "Error Compiling KDApp: #{err.message}"
      process.exit 1

    outer.on 'error', (err) ->
      log "Error Saving Compiled KDApp: #{err.message}"
      process.exit 1

    # First, write our closure start to the outer
    outer.write "/* Compiled by kdc-plus v#{VERSION} */\n(function(){\n"

    # On data, write it to our outer
    compileStream.on 'data', (chunk) -> outer.write chunk



# ## Exec
#
# The main function called when `kdc-plus` is executed. This mainly just
# calculates options and ensures a manifest loads.
exec = (argv, log=console.error) ->
  program = require 'commander'
  program.version VERSION

  # Compile command and opts
  compileCmd  = program.command 'compile'
  compileCmd.usage '[options] <kdapp directory>'
  compileCmd.description 'Compile a KDApp'
  compileCmd.option '-c, --coffee', 'CoffeeScript support'
  compileCmd.option '-n, --commonjs', 'Commonjs support'
  compileCmd.option '-b, --bare', 'For languages that support it, no closure'
  compileCmd.option '-t, --transform <bin>', 'Add a Stream Transform Binary'
  compileCmd.option '-e, --trans-ext <ext>', 'A file extension filter '+
    'for the previous transform'
  compileCmd.option '-p, --pipe', 'Pipe to STDOUT instead of to a file'
  compileCmd.option '-f, --file <file>', 'Choose the output file'
  compileCmd.option '--pistachio-this', 'Convert @ to this in your pistachio'
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

  # See below defaults
  validArgs = [
    'command'
    'install'
    'outdated'
  ]

  # Our legacy options, used for the legacy calls below
  legacyOptions =
    coffee        : true
    bare          : true
    pistachioThis : true

  # ### No Options Default, Legacy
  #
  # If there are no args, run compile with legacy kdc args
  # Note: We're using `rawArgs` instead of `args` due to inconsistent
  # behavior with args with the following two commands:
  #   kdc-plus outdated --production
  #   kdc-plus outdated --production ./
  # `args.length == 2` for the first command, `args.length == 0` for the
  # second command.. which seems odd. So, i am using rawArgs instead.
  # I really don't like this whole following section of code, really want to
  # find a way to handle this neatly
  if program.rawArgs.length is 2
    # If `kdc-plus` was called with no args, compile
    compile process.cwd(), [], legacyOptions, log
  else if (program.rawArgs.length is 3 and
      validArgs.indexOf(program.rawArgs[2]) < 0)
    # If `kdc-plus unknown-arg` was called, assume it is a directory, compile
    compile program.rawArgs[2], [], legacyOptions, log



# ## Install
#
# Install any of the dependencies specified in the manifest, and also the
# corrisponding dependency files *(package.json, bower.json, etc)*.
install = (appPath, unknownArgs..., opts={}, log=console.error) ->
  if typeof appPath is 'object' then [opts, appPath] = [appPath, undefined]

  appPath ?= process.cwd()
  appPath = path.resolve appPath

  _loadManifest appPath, log, (manifest) ->
    # Get a the package managers that we should tell to install from the
    # manifest. For an examplanation as to why we use this method of
    # identifying which packages to install, see <INSERT LINK HERE..>
    if opts.production is true
      packageManagers = manifest.packageManagers    ? {}
      installer       = installProd
    else
      packageManagers = manifest.devPackageManagers ? {}
      installer       = installDev

    # To avoid unintended behavior, we'll copy just the packages we support,
    # to ensure accidental "install options" don't leak in from the manifest
    installOpts = {}
    installOpts.node  = packageManagers.node

    installer appPath, installOpts, (err, packages) ->
      if err?
        log "Error encountered during install: #{err.message}"
        return process.exit 1

      log pack for pack in packages

      log 'Install completed successfully!'
      process.exit 0



    

    


# ## Outdated
#
# outdated checks if any of the dependencies specified in the manifest, and
# also the corrisponding dependency files *(package.json, bower.json, etc)*.
outdated = (appPath, unknownArgs..., opts={}, log=console.error) ->
  if typeof appPath is 'object' then [opts, appPath] = [appPath, undefined]

  appPath ?= process.cwd()
  appPath = path.resolve appPath

  _loadManifest appPath, log, (manifest) ->
    # Get a the package managers that we should tell to install from the
    # manifest. For an examplanation as to why we use this method of
    # identifying which packages to install, see <INSERT LINK HERE..>
    if opts.production is true
      packageManagers = manifest.packageManagers    ? {}
      outdater        = outdatedProd
    else
      packageManagers = manifest.devPackageManagers ? {}
      outdater        = outdatedDev

    outdaterOpts = {}
    outdaterOpts.node  = packageManagers.node

    outdater appPath, outdaterOpts, (err, outdated, packages) ->
      if err?
        log "Error encountered during outdated: #{err.message}"
        return process.exit 1

      log pack for pack in packages

      if outdated is false
        log 'No defined packages our outdated!'
        process.exit 0





exports.compile   = compile
exports.exec      = exec
exports.install   = install
exports.outdated  = outdated
if require.main is module then exec process.argv
