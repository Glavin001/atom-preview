{SelectListView} = require 'atom-space-pen-views'
renderers = require './renderer'

module.exports =
class SelectRendererView extends SelectListView
  initialize: (@previewView)->
    super
    @addClass('overlay from-top')
    grammars = Object.keys renderers.grammars
    @setItems(grammars)
    @focusFilterEditor()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    # console.log("#{item} was selected")
    @previewView.renderPreviewWithRenderer item
    # Close
    try
      @detach()
    catch e

  attach: =>
    atom.workspace.addTopPanel({item: @})

  toggle: =>
    if @hasParent()
      @detach()
    else
      @attach()
