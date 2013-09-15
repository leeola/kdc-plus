#
# # Calculate Transport
#
# A simple function for calculating which transport the `./auto`
# module uses.
#
# This used to be located in `./auto` but it was moved so that we can
# test it, and not have to modify the output of auto.
#




module.exports = ->
  # As you can see, we're not really worrying too much about kdf at
  # the moment lol.
  return 'node'
