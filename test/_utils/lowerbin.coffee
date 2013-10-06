# 
# # LowerCase Bin
#
# This is a transform bin used to test transform streams of kdc.
# For more information, see the LowerCaseTransform comment doc
# found in ./index.coffee
#
{LowerCaseTransform}  = require './index'




if require.main is module
  lct = new LowerCaseTransform()
  process.stdin.pipe(lct).pipe(process.stdout)
