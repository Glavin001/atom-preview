{View} = require 'atom-space-pen-views'
module.exports = class PreviewMessageView extends View
  @content: ->
    @div =>
      @div
        class: 'overlay preview-overlay-full from-top'
        outlet: 'message'
