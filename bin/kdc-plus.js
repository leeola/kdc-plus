#!/usr/bin/env node
// 
// # kdc Wrap
//
// Our kdc bin is a wrapper around the real kdc executable. Allowing us to
// run our dependency resolution code first, then compile.
// 




if (require.main === module) require('../lib/cli').exec(process.argv)
