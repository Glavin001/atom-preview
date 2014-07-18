path = require 'path'
{$, $$$, ScrollView, EditorView} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class PreviewView extends ScrollView
  atom.deserializers.add(PreviewView)

  @deserialize: (state) ->
    new PreviewView(state)

  @content: ->
    @div
      class: 'atom-preview native-key-bindings'
      tabindex: -1
      =>
        @div
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
    atom.config.observe 'atom-preview.refreshDebouncePeriod', \
    (wait) =>
      # console.log "update debounce to #{wait} ms"
      @debouncedRenderHTMLCode = _.debounce @renderHTMLCode.bind(@), wait

  serialize: ->
    deserializer: 'PreviewView'
    filePath: @getPath()
    editorId: @editorId

  destroy: ->
    @unsubscribe()
    atom.workspaceView.off \
    'pane-container:active-pane-item-changed', @handleTabChanges

  subscribeToFilePath: (filePath) ->
    @trigger 'title-changed'
    @handleEvents()
    @renderHTML()

  resolveEditor: (editorId) ->
    resolve = =>
      @editor = @editorForId(editorId)

      if @editor?
        @trigger 'title-changed' if @editor?
        @handleEvents(renderer)
      else
        # The editor this preview was created for has been closed so close
        # this preview since a preview cannot be rendered without an editor
        @parents('.pane').view()?.destroyItem(this)

    if atom.workspace?
      resolve()
    else
      @subscribe atom.packages.once 'activated', =>
        resolve()
        @renderHTML(renderer)

  editorForId: (editorId) ->
    for editor in atom.workspace.getEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  handleTabChanges: =>
    updateOnTabChange =
      atom.config.get 'atom-preview.updateOnTabChange'
    if updateOnTabChange
      currEditor = atom.workspace.getActiveEditor()
      if currEditor?
        lang = currEditor.getGrammar().name
        Grammar = require "./langs/#{lang}"
        renderer = new Grammar()
        if grammar is "CoffeeScript" or grammar is "CoffeeScript (Literate)"
          # Stop watching for events on current Editor
          @unsubscribe()
          # Switch to new editor
          @editor = currEditor
          @editorId = @editor.id
          # Start watching editors on new editor
          @handleEvents(renderer)
          # Trigger update
          @changeHandler(renderer)

  handleEvents: (renderer) ->
    if @editor?
      @subscribe @editor.getBuffer(), 'contents-modified', @changeHandler(renderer)
      @subscribe @editor, 'path-changed', => @trigger 'title-changed'

  changeHandler: (renderer) =>
    @renderHTML(renderer)
    pane = atom.workspace.paneForUri(@getUri())
    if pane? and pane isnt atom.workspace.getActivePane()
      pane.activateItem(this)

  renderHTML: (renderer) ->
    if @editor?
      if @text() is ""
        @forceRenderHTML(renderer)
      else
        @debouncedRenderHTMLCode()

  forceRenderHTML: (renderer) ->
    if @editor?
      @renderHTMLCode(renderer)

  renderHTMLCode: (renderer) =>
    @showLoading()
    # Update Title
    @trigger 'title-changed'
    # Start preview processing
    result = renderer.result()
    lang = renderer.lang()

    grammar = atom.syntax.selectGrammar("source.#{lang}", result)
    # Get codeBlock
    codeBlock = @codeBlock.find('pre')
    if codeBlock.length is 0
      codeBlock = $('<pre/>')
      @codeBlock.append(codeBlock)
    # Reset codeBlock
    codeBlock.empty()
    codeBlock.addClass('editor-colors')
    # Render the JavaScript as HTML with syntax Highlighting
    htmlEolInvisibles = ''
    for tokens in grammar.tokenizeLines(text).slice(0, -1)
      lineText = _.pluck(tokens, 'value').join('')
      codeBlock.append \
      EditorView.buildLineHtml {tokens, text: lineText, htmlEolInvisibles}
    # Clear message display
    @message.empty()
    # Display the new rendered HTML
    @trigger 'atom-preview:html-changed'
    # Set font-size from Editor to the Preview
    fontSize = atom.config.get('editor.fontSize')
    if fontSize?
      codeBlock.css('font-size', fontSize)

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
      "Atom Preview"

  getUri: ->
    "atom-preview://editor"

  getPath: ->
    if @editor?
      @editor.getPath()

  showError: (result) ->
    failureMessage = result?.message

    @codeBlock.empty()
    @message.html $$$ ->
      @div
        class: 'atom-preview-spinner'
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
        class: 'atom-preview-spinner'
        style: 'text-align: center'
        =>
          @span
            class: 'loading loading-spinner-large inline-block'
          @div
            class: 'text-highlight',
            'Loading HTML Preview\u2026'
