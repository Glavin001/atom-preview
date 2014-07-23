{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'

module.exports =
  'CoffeeScript':
    render: (text, cb) ->
      coffeescript = require 'coffee-script'
      result = coffeescript.compile text
      cb null, result
    lang: -> 'js'
  'CoffeeScript (Literate)':
    render: (text, cb) ->
      coffeescript = require 'coffee-script'
      result = coffeescript.compile text
      cb null, result
    lang: -> 'js'
  #'TypeScript':
  #  render: (text) ->
  #    typescript = require 'typescript'
  #    # FIXME: Add support for compiling TypeScript
  #  lang: -> 'js'
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
