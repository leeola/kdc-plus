# 
# Utility Stream Tests
#
{
  Readable
  Writeable
}             = require 'stream'
should        = require 'should'




describe 'ReadPiper()', ->
  ReadPiper = null
  before -> {ReadPiper} = require '../../lib/streams/utils'

  it 'should preserve data order', (done) ->
    source  = new Readable()
    source1 = new Readable()
    source2 = new Readable()

    piper1  = new ReadPiper source1
    piper2  = new ReadPiper source2

    dest    = new Writeable()

    # now that we have all of our streams created, hook them up
    source.pipe(piper1).pipe(piper2).pipe(dest)

    # Write to our source streams *out of order*
    source1.write 'b'
    source2.write 'c'
    source.write  'a'

    # And finally watch our writeable for data
    d = ''
    dest.on 'data', (chunk) -> d += chunk
    dest.on 'end',  ->
      d.should.equal 'abc'
      done()

