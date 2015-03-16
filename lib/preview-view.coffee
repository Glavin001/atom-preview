{Emitter, Disposable, CompositeDisposable, TextEditor} = require 'atom'
{$, $$, $$$, ScrollView, TextEditorView} = require 'atom-space-pen-views'

util = require 'util'
path = require 'path'
_ = require 'underscore-plus'
renderers = require './renderer'
PreviewMessageView = require './preview-message-view'
OptionsView = require './options-view'
SelectRendererView = require './select-renderer-view.coffee'
{allowUnsafeEval} = require 'loophole'
analyticsWriteKey = "bp0dj6lufc"
pkg = require "../package"
version  = pkg.version

class PreviewView extends HTMLElement

  textEditor: document.createElement('atom-text-editor')
  messageView = null
  optionsView = null
  selectRendererView = null
  htmlPreviewContainer = null

  lastEditor: null
  lastRendererName: null # TODO: implement the tracking of this
  matchedRenderersCache: {}

  # Setup Observers
  emitter: new Emitter
  disposables: new CompositeDisposable

  # Public: Initializes the indicator.
  initialize: ->
    @classList.add('atom-preview-container')

    # Update on Tab Change
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @handleTabChanges()
    # Setup debounced renderer
    atom.config.observe 'preview.refreshDebouncePeriod', \
    (wait) =>
      # console.log "update debounce to #{wait} ms"
      @debouncedRenderPreview = _.debounce @renderPreview.bind(@), wait

    @self = $(@)

    @editorContents = $(@textEditor)

    # Add Text Editor
    # Placeholder = Please type in a Text Editor to render preview
    @appendChild(@textEditor)

    # Create container for Previewing Rendered HTML
    @htmlPreviewContainer = $$ ->
        @div =>
          @div "Empty HTML Preview..."
    # Add HTML Previewer
    @self.append @htmlPreviewContainer
    @htmlPreviewContainer.hide() # hide by default

    # Attach the MessageView
    @messageView = new PreviewMessageView()
    @self.append(@messageView)

    # Attach the OptionsView
    @optionsView = new OptionsView(@)

    # Create SelectRendererView
    @selectRendererView = new SelectRendererView(@)

    @showLoading()

    # Setup Analytics
    Analytics = null
    allowUnsafeEval ->
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
    return @

  changeHandler: () =>
    @debouncedRenderPreview()

  onDidChangeTitle: (callback) ->
      @emitter.on 'did-change-title', callback

  handleEvents: () ->
    currEditor = atom.workspace.getActiveEditor()
    if currEditor?
      @disposables.add currEditor.getBuffer().onDidStopChanging =>
        @changeHandler() if atom.config.get 'preview.liveUpdate'
      @disposables.add currEditor.onDidChangePath =>
          @emitter.emit 'did-change-title'
      @disposables.add currEditor.getBuffer().onDidSave =>
        @changeHandler() unless atom.config.get 'preview.liveUpdate'
      @disposables.add currEditor.getBuffer().onDidReload =>
        @changeHandler() unless atom.config.get 'preview.liveUpdate'

  handleTabChanges: =>
    updateOnTabChange =
      atom.config.get 'preview.updateOnTabChange'
    if updateOnTabChange
      currEditor = atom.workspace.getActiveEditor()
      if currEditor?
        # Stop watching for events on current Editor
        @disposables.dispose()
        # Start watching editors on new editor
        @handleEvents()
        # Trigger update
        @changeHandler()

  toggleOptions: ->
    @optionsView.toggle()

  selectRenderer: ->
    @selectRendererView.attach()

  showError: (result) ->
    # console.log('showError', result)
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
      @self.append @messageView

  hideMessage: ->
    if @messageView.hasParent()
      @messageView.detach()

  renderViewForPreview: (view) =>
    console.log('renderViewForPreview', view, @htmlPreviewContainer)
    @editorContents.hide()
    @htmlPreviewContainer.show()
    @htmlPreviewContainer.html view
  hideViewPreview: =>
    @htmlPreviewContainer.hide()
    @editorContents.show()

  getTitle: ->
    if @getEditor()?
      "#{@getEditor().getTitle()} preview"
    else
      "Preview"

  getEditor: ->
    @textEditor.getModel()

  getPath: ->
    if @getEditor()?
      @getEditor().getPath()

  getUri: ->
    "atom://atom-preview"

  focus: ->
    false

  # Public: Destroys the indicator.
  destroy: ->
    @messageView.detach()
    @activeItemSubscription.dispose()
    @disposables.dispose()

  renderPreview: =>
    @renderPreviewWithRenderer "Default"

  renderPreviewWithRenderer: (rendererName) =>
    # Update Title
    @emitter.emit 'did-change-title'
    # Start preview processing
    cEditor = atom.workspace.getActiveEditor()
    editor = @getEditor()
    # console.log('renderPreviewWithRenderer', rendererName)
    # console.log('editor', editor, cEditor)
    if cEditor? and cEditor isnt editor and \
    cEditor instanceof TextEditor
      # console.log "Remember last editor"
      @lastEditor = cEditor
    else
      # console.log "Revert to last editor", @lastEditor
      cEditor = @lastEditor
    if not cEditor?
      # cEditor not defined
      @showError({message:"Please type a Text Editor to render preview"})
    else
      # Source Code text
      text = cEditor.getText()
      # Save Preview's Scroll position
      spos = editor.getScrollTop()
      # console.log(text)
      # console.log(cEditor is editor, cEditor, editor)
      @showLoading()
      # Update Title
      @emitter.emit 'did-change-title'
      # Create Callback
      callback = (error, result) =>
        # console.log('callback', error, result.length)
        @hideMessage()
        # Force focus on the editor
        focusOnEditor = =>
          return
          # if @lastEditor?
          #   # console.log "Focus on last editor!", @lastEditor
          #   uri = @lastEditor.getUri()
          #   if pane = atom.workspace.paneForUri(uri)
          #     # console.log pane
          #     pane.activate()

        if error?
          focusOnEditor()
          return @showError error
        # Check if result is a string and therefore source code
        if typeof result is "string"
          outLang = renderer.lang()
          grammar = atom.syntax.selectGrammar("source.#{outLang}", result)
          editor.setGrammar grammar
          editor.setText result
          # Restore Preview's Scroll Positon
          editor.setScrollTop(spos)
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
        # console.log('renderer', renderer)
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

module.exports = document.registerElement 'atom-preview-editor', prototype: PreviewView.prototype
