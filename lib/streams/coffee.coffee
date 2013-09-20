# 
# # Our little Coffee Stream
#
path      = require 'path'
{spawn}   = require 'child_process'
{
  Readable
  Transform
}         = require 'stream'




# Since all of our Coffee Streams will require a default Coffee Bin,
# lets supply that in one place.
COFFEEBIN   = path.resolve path.join(
  require.resolve('coffee-script'),
  '..', '..', '..',
  'bin', 'coffee'
)



# ## CoffeeFile
#
# A simple Readable stream implementation that compiles the given Coffee file
# path into JavaScript.
class CoffeeFile extends Readable
  constructor: (file, @opts={}) ->
    @opts.coffeeBin   ?= COFFEEBIN
    @opts.bare        ?= false
    super()

    coffee_args = ['-p', file]
    if @opts.bare then coffee_args.push '--bare'

    @coffee = spawn @opts.coffeeBin, coffee_args
    @coffee.stdout.on 'end', => @push null
    @coffee.stdout.on 'data', (chunk) =>
      if not @push chunk
        @coffee.stdout.pause()

  _read: -> @coffee.stdout.resume()



# ## CoffeeTransform
#
# Our `CoffeeTransform` class extends `stream.Transform` to implement a
# streaming coffee compiling transformer.
class CoffeeTransform extends Transform
  constructor: (opts={}) ->
    opts.coffeeBin    ?= COFFEEBIN
    opts.bare         ?= false
    super()

    coffee_args = ['-sc']
    if opts.bare then coffee_args.push '--bare'

    @coffee = spawn opts.coffeeBin, coffee_args
    @coffee.stdout.on 'data', (chunk) => @push chunk
    @coffee.stdout.on 'end', => @push null

  _transform: (chunk, enc, next) ->
    @coffee.stdin.write chunk
    next()

  _flush: -> @coffee.stdin.end()




exports.CoffeeFile      = CoffeeFile
exports.CoffeeTransform = CoffeeTransform
