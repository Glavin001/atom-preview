module.exports =
  'CoffeeScript':
    render: (text) ->
      coffeescript = require 'coffee-script'
      coffeescript.compile text
    lang: -> 'js'
  'CoffeeScript (Literate)':
    render: (text) ->
      coffeescript = require 'coffee-script'
      coffeescript.compile text
    lang: -> 'js'
