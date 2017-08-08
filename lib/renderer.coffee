{$, View} = require 'atom-space-pen-views'
path = require 'path'
temp = require("temp").track()
fs = require 'fs'
{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
_ = require 'underscore-plus'
# Speed up repetitive requiring renderers
rCache = {}

module.exports =
  allRenderers: ->
    gs = []
    # Map each renderer into an array
    for r of @grammars
      gs.push(@grammars[r])
    return gs
  findByGrammar: (grammar) ->
    @grammars[grammar]
  findAllByExtention: (extension) ->
    gs = @allRenderers()
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
      exts: /\.(coffee)$/i
      lang: -> 'js'
    'CoffeeScript (Literate)':
      render: (text, filepath, cb) ->
        coffeescript = require 'coffee-script'
        result = coffeescript.compile text, literate: true
        cb null, result
      exts: /\.(litcoffee)$/i
      lang: -> 'js'
    'CoffeeScript (JSX)':
      render: (text, filepath, cb) ->
        react = require 'coffee-react'
        result = react.compile text
        cb null, result
      exts: /\.(cjsx)$/i
      lang: -> 'js'
    'CoffeeScript (CJSX)':
      render: (text, filepath, cb) ->
        react = require 'coffee-react'
        result = react.compile text
        cb null, result
      exts: /\.(cjsx)$/i
      lang: -> 'js'
    'TypeScript':
      render: (text, filepath, cb) ->
        ts = allowUnsafeNewFunction -> allowUnsafeEval -> require 'typescript'
        result = allowUnsafeEval -> ts.transpileModule(
          text,
          compilerOptions:
            module: ts.ModuleKind.CommonJS
        )
        cb null, result.outputText
      lang: -> 'js'
      exts: /\.(ts)$/i
    'TypeScriptReact':
      render: (text, filepath, cb) ->
        ts = allowUnsafeNewFunction -> allowUnsafeEval -> require 'typescript'
        result = allowUnsafeEval -> ts.transpileModule(
          text,
          compilerOptions:
            module: ts.ModuleKind.CommonJS
            jsx: 'React'
        )
        cb null, result.outputText
      lang: -> 'js'
      exts: /\.(tsx)$/i
    'LESS':
      render: (text, filepath, cb) ->
        less = require 'less'
        # Get Resource Path
        resourcePath = atom.themes.resourcePath;
        # Atom UI Variables is under `./static/variables/`
        atomVariablesPath = path.resolve resourcePath, 'static', 'variables'
        options = {
          paths: [ # Specify search paths for @import directives
            '.'
            atomVariablesPath
          ]
        }
        less.render(text,options)
        .then((output) ->
          cb(null,output.css)
        )
        .catch((error) ->
          cb(error)
        )
      lang: -> 'css'
      exts: /\.(less)$/i
    'Jade':
      render: (text, filepath, cb) ->
        jade = allowUnsafeNewFunction -> allowUnsafeEval -> require 'jade'
        options = {
          filename: filepath
          pretty: true
        }
        fn = allowUnsafeNewFunction -> allowUnsafeEval ->
          jade.compile text, options
        result = allowUnsafeNewFunction -> allowUnsafeEval -> fn()
        cb null, result
      lang: -> 'html'
      exts: /\.(jade)$/i
    'Pug':
      render: (text, filepath, cb) ->
        pug = allowUnsafeNewFunction -> allowUnsafeEval -> require 'pug'
        options = {
          filename: filepath
          pretty: true
        }
        fn = allowUnsafeNewFunction -> allowUnsafeEval ->
          pug.compile text, options
        result = allowUnsafeNewFunction -> allowUnsafeEval -> fn()
        cb null, result
      lang: -> 'html'
      exts: /\.(pug)$/i
    'Dogescript':
      render: (text, filepath, cb) ->
        dogescript = require "dogescript"
        beautify = true
        result = dogescript text, beautify
        cb null, result
      exts: /\.(djs)$/i
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
      exts: /\.(dson)$/i
      lang: -> 'json'
    'Stylus':
      render: (text, filepath, cb) ->
        stylus = require "stylus"
        stylus(text)
        .set('filename', filepath)
        .render (err, css) ->
          cb err, css
      exts: /\.(styl)$/i
      lang: -> 'css'
    'Babel ES6 JavaScript':
      # ES6 with Babel.js
      render: (text, filepath, cb) ->
        babel = require 'babel-core'
        options =
          presets: [
            require 'babel-preset-es2015'
            require 'babel-preset-react'
            require 'babel-preset-stage-0'
            require 'babel-preset-stage-1'
            require 'babel-preset-stage-2'
            require 'babel-preset-stage-3'
          ]
        result = babel.transform(text, options)
        cb null, result.code
      exts: /\.(js|jsx|es6|es)$/i
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
      exts: /\.(em)$/i
      lang: -> 'js'
    'SpacePen':
      render: (text, filepath, cb) ->
        try
          # Get a filename in the current directory that is unique
          generateFilepath = (filepath, cb) ->
            extension = path.extname(filepath)
            cd = path.dirname(filepath)
            newFilename = "preview-temp-file-#{+new Date()}#{extension}"
            newFilepath = path.resolve cd, newFilename
            return cb(null, newFilepath)
          generateFilepath(filepath, (err, fp) ->
            # console.log fp
            if err?
              return cb(err, null)
            # Write to file
            fs.writeFile fp, text or "", (err) ->
              if err?
                return cb(err, null)
              # Get the View class module
              try
                View = require(fp) # Get the View module
                view = new View() # Create new View
                # Check if it is an instance of a Space-pen View
                if view instanceof View
                  # Is Space-pen view
                  cb(null, view)
                else
                  cb(new Error("Is not a SpacePen View"), null)
                # Delete file
                fs.unlink fp
                return
              catch e
                # return error
                cb(e, null)
                # Delete file
                fs.unlink fp
                return
            )
        catch e
          return cb(e, null)
      exts: /\.(coffee|js)$/i
    'LiveScript':
      render: (text, filepath, cb) ->
        livescript = require 'livescript'
        options = {
          filename: filepath
          bare: true
        }
        result = allowUnsafeNewFunction -> livescript.compile text, options
        cb null, result
      exts: /\.(ls)$/i
      lang: -> 'js'
    'ng-classify (coffee)':
      render: (text, filepath, cb) ->
        ngClassify = require 'ng-classify'
        result = ngClassify(text) + '\n'
        cb null, result
      exts: /\.(coffee)$/i
      lang: -> 'coffee'
    'ng-classify (js)':
      render: (text, filepath, cb) ->
        ngClassify = require 'ng-classify'
        result = ngClassify text
        coffeescript = require 'coffee-script'
        result = coffeescript.compile result
        cb null, result
      exts: /\.(coffee)$/i
      lang: -> 'js'
    'YAML':
      render: (text, filepath, cb) ->
        jsyaml = require 'js-yaml'
        try
          json = jsyaml.safeLoad text
          return cb null, JSON.stringify json, null, 2
        catch e
          return cb null, e.message
      exts: /\.(yaml)$/i
      lang: -> 'json'
    'glsl':
      render: (text, filepath, cb) ->
        try
          # glslangValidator needs file not text, so we create temp file.
          # extension must be the same, so validator can detect shader type.
          tmp = require 'tmp'
          extension = '.' + filepath.split('.').pop();
          tempFile = tmp.fileSync {prefix: 'atom-preview-editor', postfix: extension};
          file = fs.writeFileSync tempFile.fd, text

          child_process = require 'child_process'
          validator = atom.config.get 'preview.glslangValidator'
          param = '-E'
          child_process.execFile validator, [param, tempFile.name], (error, stdout, stderr) ->
            tempFile.removeCallback()
            return cb(error, null) if error
            preprocessedGlsl = stdout
            if atom.config.get 'preview.removeExtraBlankLines'
              preprocessedGlsl = preprocessedGlsl.replace /\n\n\n+/g, '\n\n'
            cb(null, preprocessedGlsl)
        catch e
          return cb null, e.message
      exts: /\.(vert|tesc|tese|geom|frag|comp)$/i
      lang: -> 'glsl'
