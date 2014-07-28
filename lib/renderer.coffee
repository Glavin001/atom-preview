path = require 'path'
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
      render: (text, filepath, cb) ->
        coffeescript = require 'coffee-script'
        result = coffeescript.compile text
        cb null, result
      exts: /^.*\.(coffee)$/
      lang: -> 'js'
    'CoffeeScript (Literate)':
      render: (text, filepath, cb) ->
        coffeescript = require 'coffee-script'
        result = coffeescript.compile text, literate: true
        cb null, result
      exts: /^.*\.(litcoffee)$/
      lang: -> 'js'
    'TypeScript':
      render: (text, filepath, cb) ->
        console.log "TypeScript"
        ts = allowUnsafeNewFunction -> allowUnsafeEval -> require 'typestring'
        console.log "ts", ts
        result = allowUnsafeEval -> ts.compile(text)
        cb null, result
      lang: -> 'js'
      exts: /^.*\.(ts)$/
    'LESS':
      render: (text, filepath, cb) ->
        less = require 'less'
        # Get Resource Path
        resourcePath = atom.themes.resourcePath;
        # Atom UI Variables is under `./static/variables/`
        atomVariablesPath = path.resolve resourcePath, 'static', 'variables'
        console.log atomVariablesPath
        
        parser = new(less.Parser)({
          paths: [ # Specify search paths for @import directives
            '.',
            atomVariablesPath
            ],
          filename: filepath # Specify a filename, for better error messages
        })

        parser.parse(text, (e, tree) ->
          console.log e, tree
          if e?
            return cb e, null
          else
            output = tree.toCSS({
              # Do Not Minify CSS output
              compress: false
            })
            console.log output
            cb null, output
        )
      lang: -> 'css'
      exts: /^.*\.(css)$/
    'Jade':
      render: (text, filepath, cb) ->
        jade = require 'jade'
        options = {
          pretty: true
        }
        fn = allowUnsafeNewFunction -> jade.compile text, options
        result = fn()
        cb null, result
      lang: -> 'html'
      exts: /^.*\.(jade)$/
    'Dogescript':
      render: (text, filepath, cb) ->
        dogescript = require "dogescript"
        beautify = true
        result = dogescript text, beautify
        cb null, result
      exts: /^.*\.(djs)$/
      lang: -> 'js'
    'DSON':
      render: (text, filepath, cb) ->
        DSON = require "dogeon"
        try
          console.log text
          d = DSON.parse text
          result = JSON.stringify d
          return cb null, result
        catch e
          return cb e, null
      exts: /^.*\.(dson)$/
      lang: -> 'json'
    'Stylus':
      render: (text, filepath, cb) ->
        stylus = require "stylus"
        # TODO: Set filename, see #23
        stylus(text)
        .set('filename', filepath)
        .render (err, css) ->
          cb err, css
      exts: /^.*\.(styl)$/
      lang: -> 'css'
