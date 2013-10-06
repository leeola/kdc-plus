# 
# # Test Utilities
#
# Some general test utilities.
#
{execFile}  = require 'child_process'
path        = require 'path'
{
  Transform
}           = require 'stream'




# # LowerCaseTransform
#
# Our lowercase transform class powers our lowercase executable,
# which will convert an incoming stream and pass it through as all lower
# case.
#
# **"This is madness! Why would you do such a thing?!"** You say, well we
# need a simple transform to ensure our transform args are working, so we
# use this as a way to transform our data in a meaningful way. The upper
# case transform is the same deal. So calm down man, quit taking things so
# seriously.. it's bad for your blood pressure. :)
class LowerCaseTransform extends Transform
  constructor: -> super
  _transform: (chunk, enc, next) ->
    @push chunk.toString().toLowerCase()
    next()



# ## UpperCaseTransform
#
# Our uppercase transform class powers our upper case executable. For more
# information see the LowerCase comment doc.
class UpperCaseTransform extends Transform
  constructor: -> super
  _transform: (chunk, enc, next) ->
    @push chunk.toString().toUpperCase()
    next()


# Our binGen is a wrapper function around execFile which returns a function
# with the bin file as a closure. Just a little utility function for our tests.
# This is sort of itense i suppose, but it makes the test cleaner dag'nabit
binGen = (binName, _args=[], _opts={}) ->
  if not (_args instanceof Array) then [_opts, _args] = [_args, []]
  _opts.addBinPath       ?= true
  _opts.autoExtension    ?= true
  _opts.includeBinExec   ?= true

  # Add the extension of this file to the binName, if binName is missing an
  # extension.
  if _opts.autoExtension and path.extname(binName) is ''
    binName += path.extname __filename
  
  # If our bin is just the name, we add the proper bin path for our
  # kdc-plus bins
  if _opts.addBinPath and binName.indexOf('/') < 0
    binName = path.resolve path.join __dirname, '..', '..', 'bin', binName

  # If our bin name needs an executable to run it (such as coffee files),
  # this will auto add that exec and shuffle the args around accordingly.
  if _opts.includeBinExec
    switch path.extname binName
      when '.coffee'
        bin = path.join(
          require.resolve 'coffee-script'
          '..', '..', '..'
          'bin', 'coffee'
        )
      else
        bin = 'node'
    _args.unshift binName
  else
    bin = binName

  (usrargs=[], opts={}, callback=->) ->
    if opts instanceof Function
      callback = opts
      opts = {}

    # Combine the usrargs with the default args
    args = _args.concat usrargs

    execFile bin, args, opts, callback




exports.LowerCaseTransform  = LowerCaseTransform
exports.UpperCaseTransform  = UpperCaseTransform
exports.binGen              = binGen
