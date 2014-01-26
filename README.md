Zuckrig Closure
=====================

A Grunt task that reduces a verbose syntax for Google Closure Compiler to be more Pythonic/Rubistic.

What is does?
-------------

It reduces needed code for Google Closure Compiler (provide, require and annotation).

Automatically adds:
- provide for a class
- require for super class
- constructor annotation
- extends annotation

See examples:

```javascript
app.Employee = (function(_super) {
  __extends(Employee, _super);

  /**
    @param {string} name
   */
  function Employee(name) {
    Employee.__super__.constructor.call(this);
    this.name = name;
  }

   return Employee;

})(app.Model);
```

  Compiles to:

```javascript
goog.provide('app.Employee');

goog.require('app.Model');

app.Employee = (function(_super) {
  __extends(Employee, _super);

  /**
    @constructor
    @extends {app.Model}
    @param {string} name
   */
  function Employee(name) {
    Employee.__super__.constructor.call(this);
    this.name = name;
  }

  return Employee;

  })(app.Model);
```

Tests
-----
   ```sh
   grunt test
   ```

## Development Stack
   ```sh
   grunt -f
   ```

## License
Copyright (c) 2013 Lukas Rychtecky

Licensed under the MIT license.
