# 
# # Pistachio Related Streams
#
# This pistachio stream module mainly (entirely?) involves the Pistachio
# replace as seen in the original kdc compiler.
#
{Transform}     = require 'stream'



# Copied from the original kdc source. It needs to be split up for my
# sanity
pistachio_matcher = /\{(\w*)?(\#\w*)?((?:\.\w*)*)(\[(?:\b\w*\b)(?:\=[\"|\']?.*[\"|\']?)\])*\{([^{}]*)\}\s*\}/g



# # PistachioThis
#
# This simple stream implements the feature seen in the main kdc
# compiler where it searches for a specific chunk of Pistachio, namely the
# `{{> @foo}}` line and replaces `@` with `this.`. I'm not too familiar with
# the need for this, but it apparently has to do with the fact that the `@` in
# coffee is not converted to `this.` for javascript. Not susprising, just a
# mild convenience.
#
# We'll disable this stream by default, but still offer the flag, so we can
# add it during normal compile *(for compatibility)*
class PistachioThis extends Transform
  constructor: ->
    super()
    @_data = ''

  _transform: (chunk, enc, next) ->
    @_data += chunk
    next()

  # We wait for flush to be called to implicitly know the end of the incoming,
  # and then apply the replace.
  _flush: ->
    @_data.replace pistachio_matcher, (pist) -> pist.replace /\@/g, 'this.'
    # Now that we have replaced what we expect, push out our data
    @push @_data
    # And then null to end the stream
    @push null






exports.PistachioThis   = PistachioThis
