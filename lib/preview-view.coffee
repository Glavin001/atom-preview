path = require 'path'
{$, $$$, ScrollView, EditorView} = require 'atom'
_ = require 'underscore-plus'
renderers = require './renderer'
analyticsWriteKey = "bp0dj6lufc"
pkg = require "../package"
version  = pkg.version

module.exports =
class PreviewView extends ScrollView
  atom.deserializers.add(PreviewView)

  @deserialize: (state) ->
    new PreviewView(state)

  @content: ->
    @div
      class: 'preview-container native-key-bindings editor editor-colors'
      tabindex: -1
      =>
        @div
          #class: 'editor-contents'
          outlet: 'codeBlock'
        @div
          outlet: 'message'

  initialize: ->
    super

    # Update on Tab Change
    atom.workspaceView.on \
    'pane-container:active-pane-item-changed', @handleTabChanges

    # Update on font-size change
    atom.config.observe 'editor.fontSize', () =>
      @changeHandler()

    # Setup debounced renderer
    atom.config.observe 'preview.refreshDebouncePeriod', \
    (wait) =>
      # console.log "update debounce to #{wait} ms"
      @debouncedRenderHTMLCode = _.debounce @renderHTMLCode.bind(@), wait

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

  serialize: ->
    deserializer: 'PreviewView'
    filePath: @getPath()
    editorId: @editorId

  destroy: ->
    @unsubscribe()
    atom.workspaceView.off \
    'pane-container:active-pane-item-changed', @handleTabChanges

  getModel: -> null

  subscribeToFilePath: (filePath) ->
    @trigger 'title-changed'
    @handleEvents()
    @renderHTML()

  resolveEditor: (editorId) ->
    resolve = =>
      @editor = @editorForId(editorId)

      if @editor?
        @trigger 'title-changed' if @editor?
        @handleEvents()
      else
        # The editor this preview was created for has been closed so close
        # this preview since a preview cannot be rendered without an editor
        @parents('.pane').view()?.destroyItem(this)

    if atom.workspace?
      resolve()
    else
      @subscribe atom.packages.once 'activated', =>
        resolve()
        @renderHTML()

  editorForId: (editorId) ->
    for editor in atom.workspace.getEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  handleTabChanges: =>
    updateOnTabChange =
      atom.config.get 'preview.updateOnTabChange'
    if updateOnTabChange
      currEditor = atom.workspace.getActiveEditor()
      if currEditor?
        # Stop watching for events on current Editor
        @unsubscribe()
        # Switch to new editor
        @editor = currEditor
        @editorId = @editor.id
        # Start watching editors on new editor
        @handleEvents()
        # Trigger update
        @changeHandler()

  handleEvents: () ->
    if @editor?
      @subscribe @editor.getBuffer(), \
      'contents-modified', @changeHandler
      @subscribe @editor, 'path-changed', => @trigger 'title-changed'

  changeHandler: () =>
    @renderHTML()
    pane = atom.workspace.paneForUri @getUri()
    if pane? and pane isnt atom.workspace.getActivePane()
      pane.activateItem @

  renderHTML: () ->
    if @editor?
      if @text() is ""
        @forceRenderHTML()
      else
        @debouncedRenderHTMLCode()

  forceRenderHTML: () ->
    if @editor?
      @renderHTMLCode()

  renderHTMLCode: () =>
    @showLoading()
    # Update Title
    @trigger 'title-changed'
    # Create Callback
    callback = (error, result) =>
      if error?
        return @showError error
      outLang = renderer.lang()
      grammar = atom.syntax.selectGrammar("source.#{outLang}", result)
      # Get codeBlock
      codeBlock = @codeBlock.find('pre')
      if codeBlock.length is 0
        codeBlock = $('<pre/>')
        @codeBlock.append(codeBlock)
      # Reset codeBlock
      codeBlock.empty()
      codeBlock.addClass('editor-colors') # Apply Theme background color
      codeBlock.addClass('preview-code-block') # Apply custom Preview styles
      # Render the JavaScript as HTML with syntax Highlighting
      htmlEolInvisibles = ''
      lineTokens = grammar.tokenizeLines(result)
      #lineTokens = lineTokens.slice(0, -1)
      # console.log lineTokens
      for tokens in lineTokens
        lineText = _.pluck(tokens, 'value').join('')
        b = EditorView.buildLineHtml {tokens, text: lineText, htmlEolInvisibles}
        codeBlock.append b
      # Clear message display
      @message.empty()
      # Display the new rendered HTML
      @trigger 'preview:html-changed'
      # Set font-size from Editor to the Preview
      fontSize = atom.config.get('editor.fontSize')
      if fontSize?
        codeBlock.css('font-size', fontSize)
    # Start preview processing
    text = @editor.getText()
    try
      grammar = @editor.getGrammar().name
      filePath = @editor.getPath()
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
            label: version
            value: "#{grammar}|#{extension}"
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
            label: version
            value: "#{grammar}|#{extension}"
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
            label: version
            value: "#{grammar}|#{extension}"
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
          # Google Analytics
          label: version
          value: "#{grammar}|#{extension}"
      }
      return @showError e


  syncScroll: ->
    console.log 'Sync scroll'
    editorView = atom.workspaceView.getActiveView()
    if editorView.getEditor?() is @editor
      scrollView = editorView.scrollView
      height = scrollView[0].scrollHeight
      y = scrollView.scrollTop()


  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} preview"
    else
      "Preview"

  getUri: ->
    "preview://editor"

  getPath: ->
    if @editor?
      @editor.getPath()

  showError: (result) ->
    failureMessage = result?.message

    @codeBlock.empty()
    @message.html $$$ ->
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

    @codeBlock.empty()
    @message.html $$$ ->
      @div
        class: 'preview-spinner'
        style: 'text-align: center'
        =>
          @span
            class: 'loading loading-spinner-large inline-block'
          @div
            class: 'text-highlight',
            'Loading HTML Preview\u2026'
