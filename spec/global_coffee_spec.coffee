Stubble = require '../lib/stubble'

stub = fs = undefined
test = (expect, mod)->
  mod = stub.require __dirname+'/samples/'+mod
  expect(fs.readFileSync).toHaveBeenCalledWith '/usr/share/dict/words'
  expect(mod).toEqual ['a', 'b', 'c']

describe 'requiring with stubble', ->
  beforeEach ->
    fs =
      closeSync:     jasmine.createSpy 'fs.closeSync'
      readFileSync:  jasmine.createSpy('fs.readFileSync').andReturn "a\nb\nc\nd\ne\nf\ng"
      writeFileSync: jasmine.createSpy 'fs.writeFile'
      writeFileSync: jasmine.createSpy 'fs.writeFile'
    stub = new Stubble fs: fs

  it 'should stub fs', ->
    test expect, 'global'

  it 'should stub fs, but not path', ->
    test expect, 'multi_globals'

  it 'should require relative paths', ->
    test expect, 'relative'

  it 'should require paths with __dirname', ->
    test expect, 'dirname'

  it 'should not interfere with require in submodules', ->
    test expect, 'multi_require'

  it 'should be able to load JSON submodules', ->
    test expect, 'json'

  it 'should have access to the global context', ->
    test expect, 'has_context'

  it 'should have all the correct globals', ->
    runs ->
      process.env.PASS_THE_ENV = ['a', 'b', 'c']
      test expect, 'uses_globals'
    waits 2
    runs ->
      expect(fs.writeFileSync).toHaveBeenCalled()
      expect(fs.closeSync).toHaveBeenCalled()

  describe 'tracking requires', ->

    beforeEach ->
      stub.require __dirname+'/samples/multi_globals'

    it 'should have require counts', ->
      expect(stub.required('path')).toEqual 1
      expect(stub.required('fs')).toEqual 1
      expect(stub.required('foo')).toEqual 0

    it 'should allow you to reset counters', ->
      stub.reset()
      expect(stub.required('path')).toEqual 0
      expect(stub.required('fs')).toEqual   0
      expect(stub.required('foo')).toEqual  0
