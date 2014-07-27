{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
_ = require 'underscore-plus'

module.exports =
  findByGrammar: (grammar) ->
    @grammars[grammar]
  findAllByExtention: (extension) ->
    gs = []
    # Map each renderer into an array
    for r of @grammars
      gs.push(@grammars[r])
    # Filter renderers
    _.filter(gs, (renderer) ->
      exts = renderer.exts
      # Check for manual extensions
      if not exts?
        # Default is false
        return false
      else
        return exts.test(extension)
      )
  findRenderer: (grammar, extension) ->
    # First check by Grammar
    renderer = @findByGrammar(grammar)
    if not renderer?
      # Next check for any renderers by extension
      renderers = @findAllByExtention(extension)
      if renderers.length > 0
        # by default, return the first renderer
        return renderers[0]
      else
        return null
    else
      return renderer
  grammars:
    'CoffeeScript':
      render: (text, cb) ->
        coffeescript = require 'coffee-script'
        result = coffeescript.compile text
        cb null, result
      exts: /.coffee/
      lang: -> 'js'
    'CoffeeScript (Literate)':
      render: (text, cb) ->
        coffeescript = require 'coffee-script'
        result = coffeescript.compile text, literate: true
        cb null, result
      exts: /.litcoffee/
      lang: -> 'js'
    'TypeScript':
      render: (text, cb) ->
        console.log "TypeScript"
        ts = allowUnsafeNewFunction -> allowUnsafeEval -> require 'typestring'
        console.log "ts", ts
        result = allowUnsafeEval -> ts.compile(text)
        cb null, result
      lang: -> 'js'
      exts: /.ts/
    'LESS':
      render: (text, cb) ->
        less = require 'less'
        less.render text, (e, css) ->
          cb e, css
      lang: -> 'css'
    'Jade':
      render: (text, cb) ->
        jade = require 'jade'
        options = {
          pretty: true
        }
        fn = allowUnsafeNewFunction -> jade.compile text, options
        result = fn()
        cb null, result
      lang: -> 'html'
    'Dogescript':
      render: (text, cb) ->
        dogescript = require "dogescript"
        beautify = true
        result = dogescript text, beautify
        cb null, result
      exts: /.djs/
      lang: -> 'js'
