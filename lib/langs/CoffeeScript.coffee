coffeescript = require 'coffeescript'

module.exports =
class CoffeeScript extends PreviewView
  initialize: ->
    super()
    
  result: ->
    coffeescript.compile @getEditorText
  lang: ->
    'js'
