var DeprecationView, View,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

View = require("atom").View;

module.exports = DeprecationView = (function(_super) {
  __extends(DeprecationView, _super);

  function DeprecationView() {
    this.close = __bind(this.close, this);
    return DeprecationView.__super__.constructor.apply(this, arguments);
  }

  DeprecationView.content = function() {
    return this.div({
      "class": 'coffeescript-preview deprecation-notice'
    }, (function(_this) {
      return function() {
        return _this.div({
          "class": 'overlay from-top'
        }, function() {
          return _this.div({
            "class": "tool-panel panel-bottom"
          }, function() {
            return _this.div({
              "class": "inset-panel"
            }, function() {
              _this.div({
                "class": "panel-heading"
              }, function() {
                _this.div({
                  "class": 'btn-toolbar pull-right'
                }, function() {
                  return _this.button({
                    "class": 'btn',
                    click: 'close'
                  }, 'Close');
                });
                return _this.span({
                  "class": 'text-error'
                }, 'IMPORTANT: CoffeeScript Preview has been Depttrecated!');
              });
              return _this.div({
                "class": "panel-body padded"
              }, function() {
                _this.span({
                  "class": 'text-warning'
                }, 'CoffeeScript Preview has been deprecated. Please migrate to the Preview package for Atom. ');
                return _this.a({
                  href: 'https://github.com/Glavin001/atom-preview'
                }, "Click here to see the Preview package for Atom");
              });
            });
          });
        });
      };
    })(this));
  };

  DeprecationView.prototype.close = function(event, element) {
    return this.detach();
  };

  return DeprecationView;

})(View);
