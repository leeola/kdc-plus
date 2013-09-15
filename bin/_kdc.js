#!/usr/bin/env node
// 
// # _kdc, the ninja
//
// This is a bin for direct access to the *original*, unmodified
// compiler. The main file of course runs our modifications and
// junk. This file runs the plain kdc code, no wrapper. It is
// mainly used in the unit tests to ensure our compiling is
// acting as we expect.
//




if (require.main === module) require('../lib/_kdc')()
