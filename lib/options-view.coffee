{View} = require 'atom-space-pen-views'

module.exports =
class OptionsView extends View
  @content: ->
    @div =>
      @div
        class: 'overlay from-top'
        =>
          @div class: "tool-panel panel-bottom", =>
            @div class: "inset-panel", =>
              @div class: "panel-heading", =>
                @div class: 'btn-toolbar pull-right', =>
                  @button
                    class: 'btn'
                    click: 'close'
                    'Close'
                @span 'Preview Options'
              @div
                class: "panel-body padded"
                =>
                  @button
                    class: 'btn btn-primary inline-block-tight'
                    click: 'selectRenderer'
                    'Select Renderer'


  initialize: (@previewView) ->

  attach: =>
    @previewView.self.append @
    @previewView.hideMessage()
  toggle: =>
    if @hasParent()
      @detach()
    else
      @attach()
  close: (event, element) =>
    @detach()

  selectRenderer: =>
    # console.log 'Select Renderer!'
    @previewView.selectRenderer()
