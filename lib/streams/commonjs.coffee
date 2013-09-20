#
# # Commonjs Streams
#
# Our commonjs Streams.
#
path              = require 'path'
{
  Readable
  Transform
}                 = require 'stream'
browserify        = require 'browserify'
{CoffeeTransform} = require './coffee'




# ## Commonjs
#
# Take in a filename and output it's content with loaded required modules.
# Require import functionality currently implemented by Browserify.
class Commonjs extends Readable
  constructor: (files=[], opts={}) ->
    files = [files] if typeof files is 'string'
    opts.transforms   ?= []
    opts.extensions   ?= []
    super()
    @_browserify  = browserify
      entries: files
      extensions: opts.extensions

    # Add our transforms
    @transform trfn for trfn in opts.transforms

  _bundle: ->
    # Create our internal stream
    @_source      = @_browserify.bundle()
    @_source.on 'data', (chunk) =>
      if not @push chunk
        @_source.pause()
    @_source.on 'end', => @push null

  _read: -> if @_source? then @_source.resume() else @_bundle()

  # ### #transform()
  # Our transform method is a bit weird. It's similar to the MultiLoader
  # transform, however it wraps Browserify's function so that we can also
  # provide the file extension. Basically, i want the same interface fir
  # both Streams.
  transform: (transformProvider) -> @_browserify.transform (file) ->
    console.log "Common transform", file
    ext = path.extname file

    transform = transformProvider file, ext
    if not transform? then return new PassTransform()
    transform


# ## PassTransform
class PassTransform extends Transform
  constructor: -> super
  _transform: (chunk) -> @push chunk


# ## coffeeifyTransform
#
# Our Coffee Streams implement a Coffee Transform, but our current
# usage of Browserify requires a slightly odd function transformer.
# So, this function can be supplied as a transformer to implement a
# Coffee transform for any Coffee files found.
coffeeifyTransform  = (file, ext) ->
  if ext isnt '.coffee' then return null
  new CoffeeTransform()


exports.Commonjs            = Commonjs
exports.coffeeifyTransform  = coffeeifyTransform
