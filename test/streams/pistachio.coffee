# 
# # Pistachio Related Stream Tests
#
{PassThrough} = require 'stream'
should        = require 'should'





describe 'PistachioThis()', ->
  PistachioThis = null
  before -> {PistachioThis}   = require '../../lib/streams/pistachio'


  it 'should not modify the data if there is no match', (done) ->
    source_data = 'my {{source}} string'
    d = ''
    s = new PistachioThis()
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      d.should.equal source_data
      done()
    # By looping through the source data we ensure that our stream is
    # buffering properly
    s.write chunk for chunk in source_data
    s.end()

  it 'should replace `@` with `this.`', (done) ->
    source_data = 'my {{> @foo}} string'
    d = ''
    s = new PistachioThis()
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      d.should.equal source_data
      done()
    # By looping through the source data we ensure that our stream is
    # buffering properly
    s.write chunk for chunk in source_data
    s.end()

