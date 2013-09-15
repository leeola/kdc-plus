# 
# # Auto Transport
#
# Sick and tired of trying to figure which transport to use? Import
# this directly and it just works!
#
calculate = require './calculate'



transport = calculate()
switch transport
  when 'node' then module.exports = require './node'
  when 'kdf'  then module.exports = require './kdf'
  else then throw new Error "Unknown Transport #{transport}"
