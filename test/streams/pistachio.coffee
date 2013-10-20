# 
# # Pistachio Related Stream Tests
#
{PassThrough} = require 'stream'
should        = require 'should'





describe 'PistachioThis()', ->
  PistachioThis = null
  before -> {PistachioThis}   = require '../../lib/stream/pistachio'


  it 'should not modify the data if there is no match'

  it 'should replace `@` with `this.`'
