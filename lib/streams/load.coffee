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
    @opts.compileCoffee   ?= true
    super()

    @__readNext()

  __readNext: =>
    file = @files.pop()
    if not file? then return @push null

    if @opts.compileCoffee and path.extname(file) is '.coffee'
      @fread = new CoffeeFile file
    else
      @fread = fs.createReadStream file, encoding: 'utf-8'

    @fread.on 'end', @__readNext
    @fread.on 'data', (chunk) =>
      if not @push chunk
        @fread.pause()

  _read: -> @fread.resume()
    



exports.LoadStream = LoadStream
