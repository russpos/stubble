req  = require
vm   = req 'vm'
path = req 'path'
cs   = req 'coffee-script'
fs   = req 'fs'

class Stubble

  constructor: (@stubs)->
    @_requires = {}

  required: (mod)->
    @_requires[mod] or 0

  _generateContext: (base, require)->
    sandbox =
      __dirname: base
      require: require
      module: exports: {}

    globals = [
      'Buffer'
      'clearInterval'
      'clearTimeout'
      'console'
      'process'
      'setInterval'
      'setTimeout'
    ]
    for item in globals
      sandbox[item] = global[item]

    vm.createContext sandbox

  _generateRequire: (base)->
    (module)=>
      @_requires[module] ?= 0
      @_requires[module]++
      return @stubs[module] if @stubs[module]

      # Relative
      if module.charAt(0) == '.'
        module = path.join base, module
      req module

  setStubs: (stubs)->
    @stubs

  reset: ->
    @stubs     = {}
    @_requires = {}

  require: (mod)->

    modPath = req.resolve mod
    base    = path.dirname modPath
    ext     = modPath.split('.')[1]

    # 'require'
    require = @_generateRequire base

    # Load the module and parse it
    source = fs.readFileSync(modPath).toString()
    if ext == 'coffee'
      source = cs.compile source

    context = @_generateContext base, require

    # Create a global circular reference
    context.global = context
    vm.runInNewContext source, context, modPath
    context.module.exports


module.exports = Stubble
