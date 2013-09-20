# 
# # Load Stream
#
# Load a given list of files and stream them back.
#
fs              = require 'fs'
path            = require 'path'
{Readable}      = require 'stream'
{CoffeeFile}    = require './coffee'




class LoadStream extends Readable
  constructor: (files=[], @opts={}) ->
    @files                = files[..] # Copy
    # A list of functions that we will call with each file, offering the
    # ability for the file to transform our incoming file stream if they
    # want.
    @_transformers        = []
    super()

  __readNext: =>
    file = @files.shift()
    if not file? then return @push null
    ext = path.extname file

    @fread = fs.createReadStream file, encoding: 'utf-8'

    # Apply our transformers to this read stream. Note that we basically pipe
    # all returned transformers one onto the next, resulting in:
    # `source -> trans -> trans -> trans -> ourOutput`
    # This means that the transformers are able to do whatever they want
    # with our incoming stream, before we output the data.
    for transProvider in @_transformers
      transformer = transProvider file, ext
      # Give the transformers an easy option to decline transforming this
      # stream. By returning `null`, it declines.
      if not transformer? then continue
      @fread = @fread.pipe transformer

    @fread.on 'end', @__readNext
    @fread.on 'data', (chunk) =>
      if not @push chunk
        @fread.pause()


  # ### _read()
  # Our _read() method calls resume if there is a stream, or goes to the
  # next file otherwise.
  _read: -> if @fread? then @fread.resume() else @__readNext()


  # ### transform()
  # Our transform function is given a callback which we will store
  # internally, with each file we open we call `callback(file, ext)` and
  # the transformer either returns `null` or a Transformer instance. If
  # null, nothing happens for that file stream. If it is a transformer, the
  # transformer is piped our incoming data and is expected to output the
  # transformed data.
  transform: (callback) ->
    if not callback? then return throw new Error 'Transform callback required'
    @_transformers.push callback
    



exports.LoadStream = LoadStream
