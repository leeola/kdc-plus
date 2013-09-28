# 
# # Install Deps Tests
#
path          = require 'path'
should        = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'installNodeDev()', ->
  installNodeDev  = null
  before -> {installNodeDev} = require '../../lib/deps/install'

  describe 'on stubs/nodeps', ->
    it 'should return an error'

  describe 'on stubs/devdeps', ->
    it 'should install the dev deps'

  describe 'on stubs/installdeps', ->
    it 'should install the deps'
