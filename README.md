Zuckrig Closure
=====================

A Grunt task that reduces a verbose syntax for Google Closure Compiler to be more Pythonic/Rubistic.

What it does?
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

Usage
-----

Modify Grunfile.coffee like that:

```coffeescript
module.exports = (grunt) ->

  grunt.initConfig

    zuckrig:
      all:
        options:
          filter: (file) -> not /_test.js$/.test(file)
        files: [
          expand: true
          src: [
            'path/to/**/*.js'
          ]
          ext: '.js'
        ]

    esteWatch:
      options:
        dirs: [
          'path/to/**/'
        ]

      coffee: (filepath) ->
        files = [
          expand: true
          src: filepath
          ext: '.js'
        ];
        grunt.config ['coffee', 'all', 'files'], files
        grunt.config ['zuckrig', 'all', 'files'], files
        grunt.config ['coffee2closure', 'all', 'files'], files
        ['coffee', 'zuckrig', 'coffee2closure']

  grunt.loadNpmTasks 'grunt-zuckrig-closure'

  grunt.registerTask 'build', 'Build app.' ->
    tasks = [
      "clean"
      "coffee"
      'zuckrig'
      "coffee2closure"
      "esteDeps"
      "esteWatch"
    ]
    grunt.task.run tasks
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
