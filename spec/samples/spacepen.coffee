{View} = require "atom"

module.exports =
class DeprecationView extends View
  @content: ->
    @div
      class: 'coffeescript-preview deprecation-notice', =>
        @div
          class: 'overlay from-top', =>
            @div class: "tool-panel panel-bottom", =>
              @div class: "inset-panel", =>
                @div class: "panel-heading", =>
                  @div class: 'btn-toolbar pull-right', =>
                    @button
                      class: 'btn'
                      click: 'close'
                      'Close'
                  @span
                    class: 'text-error'
                    'IMPORTANT: CoffeeScript Preview has been Deprecated!'
                @div
                  class: "panel-body padded"
                  =>
                    @span
                      class: 'text-warning'
                      'CoffeeScript Preview has been deprecated. Please migrate to the Preview package for Atom. '
                    @a
                      href: 'https://github.com/Glavin001/atom-preview'
                      "Click here to see the Preview package for Atom"
  close: (event, element) =>
    @detach()
