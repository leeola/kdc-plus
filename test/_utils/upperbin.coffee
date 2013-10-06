# 
# # UpperCase Bin
#
# This is a transform bin used to test transform streams of kdc.
# For more information, see the UpperCaseTransform comment doc
# found in ./index.coffee
#
{UpperCaseTransform}  = require './index.coffee'




if require.main is module
  lct = new UpperCaseTransform()
  process.stdin.pipe(lct).pipe(process.stdout)
