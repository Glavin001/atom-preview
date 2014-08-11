{View} = require 'atom'
module.exports =
class PreviewMessageView extends View
  @content: ->
    @div =>
      @div
        class: 'overlay from-top'
        outlet: 'message'
