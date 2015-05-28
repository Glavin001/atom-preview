url = require 'url'
PreviewView = require './preview-view'

module.exports =
  config:
    updateOnTabChange:
      type: 'boolean'
      default: true
    refreshDebouncePeriod:
      type: 'integer'
      default: 100
    liveUpdate:
      type: 'boolean'
      default: true

  previewView: null
  uri: "atom://atom-preview"

  ###
  # This required method is called when your package is activated. It is passed
  # the state data from the last time the window was serialized if your module
  # implements the serialize() method. Use this to do initialization work when
  # your package is started (like setting up DOM elements or binding events).
  ###
  activate: (state) ->
    # console.log 'activate(state)'
    # console.log state

    atom.commands.add 'atom-workspace',
      'preview:toggle': => @toggle()
    atom.commands.add 'atom-workspace',
      'preview:toggle-options': => @toggleOptions()
    atom.commands.add 'atom-workspace',
      'preview:select-renderer': => @selectRenderer()

    atom.workspace.addOpener (uriToOpen) =>
      return unless uriToOpen is @uri
      # Create and show preview!
      @previewView = new PreviewView()

    # Deserialize state
    @toggle if state.isOpen

  ###
  # This optional method is called when the window is shutting down, allowing
  # you to return JSON to represent the state of your component. When the
  # window is later restored, the data you returned is passed to your module's
  # activate method so you can restore your view to where the user left off.
  ###
  serialize: ->
    # console.log 'serialize()'
    previewPane = atom.workspace.paneForURI(@uri)
    return {
      isOpen: previewPane?
    }

  ###
  # This optional method is called when the window is shutting down. If your
  # package is watching any files or holding external resources in any other
  # way, release them here. If you're just subscribing to things on window, you
  # don't need to worry because that's getting torn down anyway.
  ###
  deactivate: ->
    # console.log 'deactivate()'
    previewPane = atom.workspace.paneForURI(@uri)
    if previewPane
      previewPane.destroyItem(previewPane.itemForURI(@uri))
      return

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?
    previewPane = atom.workspace.paneForURI(@uri)
    if previewPane
      previewPane.destroyItem(previewPane.itemForURI(@uri))
      return
    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(@uri, split: 'right', searchAllPanes: true)
    .done (previewView) =>
    #   console.log("previewView", previewView, @previewView)
      if previewView instanceof PreviewView
          previewView.initialize()
    #     previewView.renderPreview()
    #     previousActivePane.activate()

  toggleOptions: ->
    if @previewView?
      @previewView.toggleOptions()

  selectRenderer: ->
    if @previewView?
      @previewView.selectRenderer()
