# 
# # Utility Oriented Streams
#
# Generic utility streams.
#
{Duplex}    = require 'stream'
{Readable}    = require 'stream'
{Writable}    = require 'stream'




# ## ReadPiper
#
# The read piper is a little utility class to allow a readstream to be
# "piped into". Technically the read stream given to this class never gets
# piped into, but this class simply allows the usage. So, if you have a 
# read stream, give it to this class, and now you can pipe streams together.
class ReadPiper extends Duplex
  constructor: (@_readStream, @name) ->
    super()

  _read: -> if @_writableState.ended then @_readStream.resume()

  _write: (chunk, enc, next) ->
    @push chunk
    next()

  # End signifies the end of the write stream. When that occurs, start our
  # read stream.
  end: ->
    super
    @_readStream.on 'data', (chunk) =>
      if not @push chunk then @_readStream.pause()
    @_readStream.on 'end', => @push null




exports.ReadPiper = ReadPiper
