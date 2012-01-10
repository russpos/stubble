req  = require
vm   = req 'vm'
path = req 'path'
cs   = req 'coffee-script'
fs   = req 'fs'

###
Copyright (C) 2012 Russ Posluszny

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Private methods, defined in closure to hide from the public interface
###

###
@function
@memberOf Stubble.prototype
@access private

@description Creates a context object for code to be executed in based on
  the provided attributes
@param {String} base The base dir of the file this context is meanted to
  represent.  Will be used as the `__dirname` global
@param {Function} require The modified require function
@return {Object} Object to be used as the global context for the vm to
  run in.
###
generateContext = (base, require)->
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

###
@function
@memberOf Stubble.prototype

@description Creates a modified function to be used in place of the native
  require function
@param {String} base The base dir of the context of this require function,
  used for relative path requires
@return {Function} Modified require function
###
generateRequire = (base)->
  (module)=>
    @incrementRequire module
    return @stubs[module] if @stubs[module]

    # Relative
    if module.charAt(0) == '.'
      module = path.join base, module
    req module


###
@class Stubble
@description Create a Stubble object, which can be used to require and execute
  JSON, JavaScript, and CoffeeScript code in a modified sandbox environment.
###
class Stubble

  ###
  @constructor
  @description Creates a new Stubble instance with a given set of stubs
  ###
  constructor: (@stubs)->

    # Create accessor methods directly on the instance, rather than the
    # prototype.  _requires should *only* exist within this closure and
    # not be directly accessible from the outside world.
    _requires = {}
    @required = (mod)->  _requires[mod] or 0
    @resetRequires = ->  _requires = {}
    @incrementRequire = (module)->
      _requires[module] ?= 0
      _requires[module]++

  ###
  @function
  @memberOf Stubble.prototype
  @access public

  @description Sets the internal collection of mock modules to the given
    object
  @params {Object} Set of key value pairs of mock modules.  Key names will
    be the String that is used to require the module.  Values will be the
    objects returned by the require statement
  ###
  setStubs: (stubs)->
    @stubs

  ###
  @function
  @memberOf Stubble.prototype
  @access public

  @description Resets internal state, unsetting all stubs and require
    counters
  ###
  reset: ->
    @stubs     = {}
    @resetRequires()

  ###
  @function
  @memberOf Stubble.prototype
  @access public

  @description Requires a given module, with any `require` calls within
    that module passed through our modified `require` function.
  @param {String} mod The name of the module to require.
  @return {mixed} The exported variable from the loaded module
  ###
  require: (mod)->

    modPath = req.resolve mod
    base    = path.dirname modPath
    ext     = modPath.split('.')[1]

    # 'require'
    require = generateRequire.call @, base

    # Load the module and parse it
    source = fs.readFileSync(modPath).toString()
    if ext == 'coffee' then source = cs.compile source

    context = generateContext.call @, base, require

    # Create a global circular reference
    context.global = context
    vm.runInNewContext source, context, modPath
    context.module.exports

module.exports = Stubble


