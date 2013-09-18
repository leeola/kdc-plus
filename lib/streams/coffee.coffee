# 
# # Our little Coffee Stream
#
path          = require 'path'
{spawn}       = require 'child_process'
{Readable}    = require 'stream'




class CoffeeFile extends Readable
  constructor: (file, @opts={}) ->
    # A bit ugly, but by defining our own bin we can depend on whatever
    # version we want.
    @opts.coffeeBin    ?= path.resolve path.join __dirname,
      '..', '..', 'node_modules', 'coffee-script', 'bin', 'coffee'
    super()

    @coffee = spawn @opts.coffeeBin, ['-p', file]
    @coffee.stdout.on 'end', => @push null
    @coffee.stdout.on 'data', (chunk) =>
      if not @push chunk
        @coffee.stdout.pause()

  _read: -> @coffee.stdout.resume()




exports.CoffeeFile  = CoffeeFile
