#
# # Commonjs Streams
#
# Our commonjs Streams.
#
path              = require 'path'
{Readable}        = require 'stream'
browserify        = require 'browserify'
{CoffeeTransform} = require './coffee'




# ## Commonjs
#
# Take in a filename and output it's content with loaded required modules.
# Require import functionality currently implemented by Browserify.
class Commonjs extends Readable
  constructor: (file, opts={}) ->
    opts.transforms   ?= []
    opts.extensions   ?= []
    super()
    @_browserify  = browserify
      entries: [file]
      extensions: opts.extensions

    # Add our transforms
    @_browserify.transform trfn for trfn in opts.transforms

    # Create our internal stream
    @_source      = @_browserify.bundle()
    @_source.on 'data', (chunk) =>
      if not @push chunk
        @_source.pause()
    @_source.on 'end', => @push null

  _read: -> @_source.resume()


# ## coffeeifyTransform
#
# Our Coffee Streams implement a Coffee Transform, but our current
# usage of Browserify requires a slightly odd function transformer.
# So, this function can be supplied as a transformer to implement a
# Coffee transform for any Coffee files found.
coffeeifyTransform  = (file) ->
  # Returning null might be bad.. Might want to return an empty Transformer
  if path.extname(file) isnt '.coffee' then return null
  return new CoffeeTransform()


exports.Commonjs            = Commonjs
exports.coffeeifyTransform  = coffeeifyTransform
