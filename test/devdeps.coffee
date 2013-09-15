# 
# # devDeps Tests
#
# Our devDep tests focus on ensuring dependency resolution is met
# before app compilation takes place, as well as ensuring all devDeps are
# met.
#
{execFile}  = require 'child_process'
fs          = require 'fs'
path        = require 'path'
md5         = require 'MD5'
should      = require 'should'
verexp      = require 'verbal-expressions'




describe 'devDeps()', ->
  kdc_path  = path.join __dirname, '..', 'bin', 'kdc.js'

  describe 'a devdeps project', ->
    stub_path = path.join __dirname, 'stubs', 'devdeps'

    it 'should compile without failing', (done) ->
      execFile 'node', [kdc_path, stub_path], (err, stdout, stderr) ->
        # We're ignoring the Unicode LF
        stdout[...-1].should.equal 'Application has been compiled!'
        should.not.exist err
        stderr.should.equal ''
        done()


    target_md5 = 'foo'
    it "should compile and match md5 #{target_md5}", ->
      index = fs.readFileSync path.join(stub_path, 'index.js'),
        encoding: 'utf-8'
      
      # Remove some of the dynamic bits that will cause the md5 to fail.
      index = verexp()
        .beginCapture()
        .find('Compiled by kdc on ')
        .endCapture()
        .anythingBut('*/')
        .replace(index, '$1')

      index = verexp()
        .beginCapture()
        .find('BLOCK STARTS: ')
        .endCapture()
        .anything()
        .then('*/')
        .replace(index, '$1*/')

      md5(index).should.equal target_md5

