{$} = require 'atom'
path = require 'path'
temp = require("temp").track()
fs = require 'fs'
{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
_ = require 'underscore-plus'
# Speed up repetitive requiring renderers
rCache = {}

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
        ts = allowUnsafeNewFunction -> allowUnsafeEval -> require 'typestring'
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
        parser = new(less.Parser) ({
          paths: [ # Specify search paths for @import directives
            '.',
            atomVariablesPath
            ],
          filename: filepath # Specify a filename, for better error messages
        } )
        parser.parse(text, (e, tree) ->
          # console.log e, tree
          if e?
            return cb e, null
          else
            output = tree.toCSS({
              # Do Not Minify CSS output
              compress: false
            } )
            cb null, output
        )
      lang: -> 'css'
      exts: /^.*\.(less)$/
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
        stylus(text)
        .set('filename', filepath)
        .render (err, css) ->
          cb err, css
      exts: /^.*\.(styl)$/
      lang: -> 'css'
    'JavaScript (JSX)':
      render: (text, filepath, cb) ->
        reactTools = require 'react-tools'
        options = {}
        result = reactTools.transform text, options
        cb null, result
      exts: /^.*\.(jsx)$/
      lang: -> 'js'
    'EmberScript':
      render: (text, filepath, cb) ->
        em = require 'ember-script'
        options = {
          bare: no
          raw: no
          sourceMap: no
        }
        csAst = em.parse text,
          bare: options.bare
          raw: options.raw or options.sourceMap
        # console.log csAst
        jsAst = em.compile csAst,
          bare: options.bare
        # console.log jsAst
        jsContent = em.js jsAst
        # console.log jsContent
        cb null, jsContent
      exts: /^.*\.(em)$/
      lang: -> 'js'
    'SpacePen':
      render: (text, filepath, cb) ->
        try
          console.log "File Path:", filepath
          extension = path.extname(filepath)
          temp.open {suffix: extension}, (err, info) ->
            if err?
              return cb(err, null)
            fs.write info.fd, text or "", (err) ->
              if err?
                return cb(err, null)
              fs.close info.fd, (err) ->
                if err?
                  return cb(err, null)
                # Get the View class module
                console.log info.path
                # Patch the NODE_PATH
                cd = path.dirname(filepath)
                nodePath = process.env.NODE_PATH
                deli = ":"
                newNodePath = "#{nodePath}#{deli}#{cd}"
                console.log newNodePath
                process.env.NODE_PATH = newNodePath
                module.paths.push cd
                console.log module.paths
                mFilename = module.filename
                module.filename = cd
                require('module').Module._initPaths();
                View = null
                try
                  View = require(info.path) # Get the View module
                catch e
                  # Revert NODE_PATH
                  process.env.NODE_PATH = nodePath
                  module.filename = mFilename
                  require('module').Module._initPaths();
                  return cb(e, null)
                # Revert NODE_PATH
                process.env.NODE_PATH = nodePath
                module.filename = mFilename
                require('module').Module._initPaths();
                view = new View() # Create new View
                # Check if it is an instance of a Space-pen View
                if view instanceof $
                  # Is Space-pen view
                  cb(null, view)
                else
                  cb(new Error("Is not a SpacePen View"), null)
        catch e
          return cb(e, null)
      exts: /^.*\.(coffee|js)$/
