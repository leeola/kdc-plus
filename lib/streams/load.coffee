# 
# # Load Stream
#
# Load a given list of files and stream them back.
#
{spawn}       = require 'child_process'
fs            = require 'fs'
path          = require 'path'
{
  Readable
  Transform
}             = require 'stream'
{CoffeeFile}  = require './coffee'




class LoadMulti extends Readable
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
    



# ## StdioTransform
#
# Our Stdio Transform stream will take the file path of a binary to
# transform our incoming stream with. It's basically just an interface
# for an executable transform, such as `coffee -i`.
class StdioTransform extends Transform
  # ### Static Method: Filter
  #
  # Our static filter method returns a function which will return a new
  # StdioTransform instance each time it is called, if the given regex
  # pattern matches. A string is also accepted as the 2nd argument, which is
  # used to match the file extension. If no match is found, `null` is returned
  @Filter: (stdioPath, fileMatcher) ->
    if typeof fileMatcher is 'string'
      fileMatcher = new RegExp "\\.#{fileMatcher}$"
    (filename) =>
      if not fileMatcher? or not fileMatcher.test filename then return null
      new @ stdioPath

  constructor: (stdioPath, stdout=true, stderr=false) ->
    super
    args = stdioPath.split ' '
    bin = args.shift()
    @_process = spawn bin, args

    if stdout
      @_process.stdout.on 'data', (chunk) =>
        console.log 'Stdout Data:', chunk
        @push chunk

    if stderr
      @_process.stderr.on 'data', (chunk) =>
        console.log 'Stdout Data:', chunk
      @push chunk

    @_process.on 'close', => @push null

  _transform: (chunk, enc, next) ->
    @_process.stdin.write chunk
    next()

  _flush: -> @_process.disconnect()








exports.LoadMulti       = LoadMulti
exports.StdioTransform  = StdioTransform
