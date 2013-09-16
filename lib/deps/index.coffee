# 
# # Deps Index
#
# Our deps section defines our dependency resolution code.
#
# ## ISOMORPHIC WARNING
#
# This code runs in both server and browser, but still needs to communicate
# with the server in both cases. We use the `../transports` library to
# create a standard interface for Node and the KDFramework.
#



exports.check   = require './check'
exports.resolve = require './resolve'
