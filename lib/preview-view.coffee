{$, $$$, EditorView} = require 'atom'
path = require 'path'
_ = require 'underscore-plus'
TextBuffer = atom.deserializers.deserializers.TextBuffer
Editor = atom.deserializers.deserializers.Editor
renderers = require './renderer'
analyticsWriteKey = "bp0dj6lufc"
pkg = require "../package"
version  = pkg.version

module.exports =
class PreviewView extends EditorView
  @content: (params) ->
    params = params ? params || {}
    super(params)

  constructor: () ->
    # Create TextBuffer
    buffer = new TextBuffer
    console.log buffer
    # Create Editor
    editor = new Editor(buffer: buffer)
    console.log editor
    # Initialize the EditorView
    super(editor)
    # Empty to start
    editor.setText ''

    # Setup Observers
    # Update on Tab Change
    atom.workspaceView.on \
    'pane-container:active-pane-item-changed', @handleTabChanges
    # Setup debounced renderer
    atom.config.observe 'preview.refreshDebouncePeriod', \
    (wait) =>
      console.log "update debounce to #{wait} ms"
      @debouncedRenderPreview = _.debounce @renderPreview.bind(@), wait

    # Setup Analytics
    Analytics = require 'analytics-node'
    @analytics = new Analytics analyticsWriteKey
    # set a unique identifier
    if not atom.config.get 'preview._analyticsUserId'
      uuid = require 'node-uuid'
      atom.config.set 'preview._analyticsUserId', uuid.v4()
    # identify the user
    atom.config.observe 'preview._analyticsUserId', {}, (userId) =>
      # console.log 'userId :', userId
      @analytics.identify {
        userId: userId
      }

    # Start rendering
    @renderPreview()

  destroy: ->
    @unsubscribe()
    atom.workspaceView.off \
    'pane-container:active-pane-item-changed', @handleTabChanges

  getTitle: ->
    if @getEditor()?
      "#{@getEditor().getTitle()} preview"
    else
      "Preview"

  getPath: ->
    if @getEditor()?
      @getEditor().getPath()

  getUri: ->
    "preview://editor"

  changeHandler: () =>
    console.log 'changeHandler'
    @renderPreview()
    # pane = atom.workspace.paneForUri @getUri()
    # if pane? and pane isnt atom.workspace.getActivePane()
    #   pane.activateItem @

  handleEvents: () ->
    console.log 'handleEvents'
    currEditor = atom.workspace.getActiveEditor()
    if currEditor?
      @subscribe currEditor.getBuffer(), \
      'contents-modified', @changeHandler
      @subscribe currEditor, 'path-changed', => @trigger 'title-changed'

  handleTabChanges: =>
    console.log 'handleTabChanges'
    updateOnTabChange =
      atom.config.get 'preview.updateOnTabChange'
    if updateOnTabChange
      currEditor = atom.workspace.getActiveEditor()
      if currEditor?
        # Stop watching for events on current Editor
        @unsubscribe()
        # Start watching editors on new editor
        @handleEvents()
        # Trigger update
        @changeHandler()

  renderPreview: () ->
    console.log 'renderPreview'
    # Update Title
    @trigger 'title-changed'
    # Start preview processing
    cEditor = atom.workspace.getActiveEditor()
    editor = @getEditor()
    if cEditor? and cEditor isnt editor
      # Source Code text
      text = cEditor.getText()
      console.log(text)
      console.log(cEditor is editor, cEditor, editor)
      @showLoading()
      # Update Title
      @trigger 'title-changed'
      # Create Callback
      callback = (error, result) =>
        if error?
          return @showError error
        outLang = renderer.lang()
        grammar = atom.syntax.selectGrammar("source.#{outLang}", result)
        editor.setGrammar grammar
        editor.setText result
        @redraw()
        console.log 'DONE!'
      # Start preview processing
      try
        grammar = cEditor.getGrammar().name
        filePath = cEditor.getPath()
        # console.log grammar,filePath
        extension = path.extname(filePath)
        # console.log extension
        renderer = renderers.findRenderer grammar, extension
        # console.log renderer
        if not text?
          # Track
          @analytics.track {
            userId: atom.config.get 'preview._analyticsUserId'
            event: 'Nothing to render'
            properties:
              grammar: grammar
              extension: extension
              version: version
              # Google Analytics
              label: "#{grammar}|#{extension}"
          }
          return @showError new Error "Nothing to render."
        if renderer?
          # Track
          @analytics.track {
            userId: atom.config.get 'preview._analyticsUserId'
            event: 'Preview'
            properties:
              grammar: grammar,
              extension: extension,
              version: version
              # Google Analytics
              label: "#{grammar}|#{extension}"
              category: version
          }
          return renderer.render text, filePath, callback
        else
          # Track
          @analytics.track {
            userId: atom.config.get 'preview._analyticsUserId'
            event: 'Renderer not found'
            properties:
              grammar: grammar,
              extension: extension,
              version: version
              # Google Analytics
              label: "#{grammar}|#{extension}"
              category: version
          }
          return @showError(new Error \
          "Can not find renderer for grammar #{grammar}.")
      catch e
        # Track
        @analytics.track {
          userId: atom.config.get 'preview._analyticsUserId'
          event: 'Error'
          properties:
            error: e
            vesion: version
            # Google Analytics
            label: "#{grammar}|#{extension}"
            category: version
        }
        return @showError e
  showLoading: () ->
  showError: () ->
