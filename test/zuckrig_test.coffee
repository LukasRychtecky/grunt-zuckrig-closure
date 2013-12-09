{zuckrig} = require '../lib/zuckrig'

describe 'Zuckrig', ->

  it 'should add a constructor annotation', ->
    source = """
      var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

      goog.provide('app.Employee');

      goog.require('app.Person');

      app.Employee = (function(_super) {

        __extends(Employee, _super);

        /**
          @param {string} name
          @extends {app.Person}
        */


        function Employee(name) {
          Employee.__super__.constructor.call(this, name);
        }

        return Employee;

      })(app.Person);

    """

    fixedSource = """
      var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };
      goog.provide('app.Employee');
      goog.require('app.Person');
      app.Employee = (function(_super) {
        __extends(Employee, _super);
        /**
          @param {string} name
          @constructor
          @extends {app.Person}
        */
        function Employee(name) {
          Employee.__super__.constructor.call(this, name);
        }
        return Employee;
      })(app.Person);
    """
    zuckrig(source).should.equal fixedSource