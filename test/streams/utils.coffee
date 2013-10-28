# 
# Utility Stream Tests
#
{
  PassThrough
}             = require 'stream'
should        = require 'should'




describe 'ReadPiper()', ->
  ReadPiper = null
  before -> {ReadPiper} = require '../../lib/streams/utils'

  it 'should preserve data order', (done) ->
    source  = new PassThrough()
    source1 = new PassThrough()
    source2 = new PassThrough()

    piper1  = new ReadPiper source1
    piper2  = new ReadPiper source2

    dest    = new PassThrough()

    # now that we have all of our streams created, hook them up
    source.pipe(piper1).pipe(piper2).pipe(dest)

    # Write to our source streams *out of order*
    source1.write 'c'
    source.write  'a'
    source2.write 'e'
    source1.write 'd'
    source.write  'b'
    source2.write 'f'

    source.end()
    source1.end()
    source2.end()

    # And finally watch our writeable for data
    d = ''
    dest.on 'data', (chunk) -> d += chunk
    dest.on 'end',  ->
      d.should.equal 'abcdef'
      done()

