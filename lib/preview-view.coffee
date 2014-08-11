{$, $$, $$$} = require 'atom'
path = require 'path'
_ = require 'underscore-plus'
renderers = require './renderer'
PreviewMessageView = require './preview-message-view'
OptionsView = require './options-view'
SelectRendererView = require './select-renderer-view.coffee'
analyticsWriteKey = "bp0dj6lufc"
pkg = require "../package"
version  = pkg.version
# Get Atom internal modules
resourcePath = atom.config.resourcePath
# EditorView = require path.resolve resourcePath, 'src', 'editor-view'
ReactEditorView = require path.resolve resourcePath, 'src', 'react-editor-view'
TextBuffer = require path.resolve resourcePath, 'node_modules', 'text-buffer'
Editor = require path.resolve resourcePath, 'src', 'editor'

module.exports =
class PreviewView extends ReactEditorView
  @content: (params) ->
    params = params ? params || {}
    super(params)

  lastEditor: null
  lastRendererName: null # TODO: implement the tracking of this
  matchedRenderersCache: {}

  constructor: () ->
    # Create TextBuffer
    buffer = new TextBuffer
    # Create Editor
    editor = new Editor(buffer: buffer)
    # Initialize the EditorView
    super(editor)
    # Add classes
    @addClass('preview-container')
    # Empty to start
    editor.setText ''

    # Get EditorContents element
    @editorContents = $('.editor-contents', @element)
    # Attach the MessageView
    @messageView = new PreviewMessageView()
    @showLoading()
    # Attach the OptionsView
    @optionsView = new OptionsView(@)
    # Create SelectRendererView
    @selectRendererView = new SelectRendererView(@)
    # Create container for Previewing Rendered HTML
    @htmlPreviewContainer = $$ ->
      @div =>
        @div "THIS IS A TEST"
    @.append @htmlPreviewContainer
    @htmlPreviewContainer.hide() # hide by default

    # Setup Observers
    # Update on Tab Change
    atom.workspaceView.on \
    'pane-container:active-pane-item-changed', @handleTabChanges
    # Setup debounced renderer
    atom.config.observe 'preview.refreshDebouncePeriod', \
    (wait) =>
      # console.log "update debounce to #{wait} ms"
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
    @messageView.detach()
    @unsubscribe()
    atom.workspaceView.off \
    'pane-container:active-pane-item-changed', @handleTabChanges

  getTitle: ->
    # if @lastRendererName?
    #   "#{@lastRendererName} Preview"
    # else
    #   "Preview"
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
    @debouncedRenderPreview()

  handleEvents: () ->
    currEditor = atom.workspace.getActiveEditor()
    if currEditor?
      @subscribe currEditor.getBuffer(), \
      'contents-modified', @changeHandler
      @subscribe currEditor, 'path-changed', => @trigger 'title-changed'

  handleTabChanges: =>
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

  renderPreview: =>
    @renderPreviewWithRenderer "Default"

  renderPreviewWithRenderer: (rendererName) =>
    # Update Title
    @trigger 'title-changed'
    # Start preview processing
    cEditor = atom.workspace.getActiveEditor()
    editor = @getEditor()
    if cEditor? and cEditor isnt editor and \
    cEditor instanceof Editor
      # console.log "Remember last editor"
      @lastEditor = cEditor
    else
      # console.log "Revert to last editor", @lastEditor
      cEditor = @lastEditor
    if cEditor?
      # Source Code text
      text = cEditor.getText()
      # console.log(text)
      # console.log(cEditor is editor, cEditor, editor)
      @showLoading()
      # Update Title
      @trigger 'title-changed'
      # Create Callback
      callback = (error, result) =>
        @hideMessage()
        # Force focus on the editor
        focusOnEditor = =>
          if @lastEditor?
            # console.log "Focus on last editor!", @lastEditor
            uri = @lastEditor.getUri()
            if pane = atom.workspace.paneForUri(uri)
              # console.log pane
              pane.activate()

        if error?
          focusOnEditor()
          return @showError error
        # Check if result is a string and therefore source code
        if typeof result is "string"
          outLang = renderer.lang()
          grammar = atom.syntax.selectGrammar("source.#{outLang}", result)
          editor.setGrammar grammar
          editor.setText result
          @redraw()
          @hideViewPreview()
          focusOnEditor()
        # Check if result is a Space-pen View (jQuery)
        else if result instanceof $
          # Is SpacePen View
          @renderViewForPreview(result)
          focusOnEditor()

        else
          # Unknown result type
          @hideViewPreview() # Show Editor by default
          focusOnEditor()
          return @showError new Error("Unsupported result type.")

      # Start preview processing
      try
        grammar = cEditor.getGrammar().name
        filePath = cEditor.getPath()
        # console.log grammar,filePath
        extension = path.extname(filePath)
        # console.log extension
        # Get the renderer
        renderer = null
        if rendererName is "Default"
          # Get the cached renderer for this file
          renderer = @matchedRenderersCache[filePath]
          # Check if cached renderer was found
          if not renderer?
            # Find renderer
            renderer = renderers.findRenderer grammar, extension
        else
          # Get the Renderer by name
          renderer = renderers.grammars[rendererName]
        # Save matched renderer
        @matchedRenderersCache[filePath] = renderer
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

  toggleOptions: ->
    @optionsView.toggle()

  selectRenderer: ->
    @selectRendererView.attach()

  showError: (result) ->
    failureMessage = result?.message
    @showMessage()
    @messageView.message.html $$$ ->
      @div
        class: 'preview-spinner'
        style: 'text-align: center'
        =>
          @span
            class: 'loading loading-spinner-large inline-block'
          @div
            class: 'text-highlight',
            'Previewing Failed\u2026'
            =>
              @div
                class: 'text-error'
                failureMessage if failureMessage?
          @div
            class: 'text-warning'
            result?.stack

  showLoading: ->
    @showMessage()
    @messageView.message.html $$$ ->
      @div
        class: 'preview-spinner'
        style: 'text-align: center'
        =>
          @span
            class: 'loading loading-spinner-large inline-block'
          @div
            class: 'text-highlight',
            'Loading Preview\u2026'

  showMessage: ->
    if not @messageView.hasParent()
      #@editorContents.append @messageView
      @.append @messageView

  hideMessage: ->
    if @messageView.hasParent()
      @messageView.detach()

  renderViewForPreview: (view) =>
    @editorContents.hide()
    @htmlPreviewContainer.show()
    @htmlPreviewContainer.html view
  hideViewPreview: =>
    @htmlPreviewContainer.hide()
    @editorContents.show()
