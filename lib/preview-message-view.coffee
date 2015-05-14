{View} = require 'atom-space-pen-views'
module.exports = class PreviewMessageView extends View
  @content: ->
    @div =>
      @div
        class: 'overlay from-top'
        outlet: 'message'
