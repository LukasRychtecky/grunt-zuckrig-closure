module.exports = (grunt) ->

  path = require 'path'

  # to preserve directory structure
  coffeeLib2SrcDest = grunt.file.expandMapping '**/*.coffee', 'lib/',
    cwd: 'src/'
    ext: '.js'
    rename: (dest, matchedSrcPath) -> path.join dest, matchedSrcPath

  grunt.initConfig

    coffee:
      options:
        bare: true
      all:
        files: coffeeLib2SrcDest.concat [
          expand: true
          src: 'test/**/*.coffee'
          ext: '.js'
        ]

    simplemocha:
      all:
        src: [
          'node_modules/should/lib/should.js'
          'test/**/*.js'
        ]

    watch:
      coffee:
        files: [
          'src/**/*.coffee'
          'test/**/*.coffee'
        ]
        tasks: 'coffee'

      simplemocha:
        files: [
          'lib/**/*.js'
          'test/**/*.js'
        ]
        tasks: 'simplemocha'

    release:
      options:
        bump: true
        add: true
        commit: true
        tag: true
        push: true
        pushTags: true
        npm: true
        commitMessage: '<%= version %>'
        tagName: '<%= version %>'
        tagMessage: '<%= version %>'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-release'
  grunt.loadNpmTasks 'grunt-simple-mocha'

  grunt.registerTask 'install', [
    'coffee'
  ]

  grunt.registerTask 'test', [
    'install', 'simplemocha'
  ]

  grunt.registerTask 'run', [
    'test', 'watch'
  ]

  grunt.registerTask 'default', 'run'
