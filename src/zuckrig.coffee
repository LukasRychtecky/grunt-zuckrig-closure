module.exports = (grunt) ->
  {zuckrig} = require '../tasks/zuckrig_filter'

  grunt.registerMultiTask 'zuckrig', 'Reduce a verbose syntax for Google Closure Compiler to be more Pythonist/Rubist.', ->
    count = 0
    opts = @options(filter: -> true)
    @files.forEach (f) ->

      return unless opts.filter f.dest

      try
        file = grunt.file.read f.dest
        file = zuckrig file
        grunt.file.write f.dest, file
        count++
      catch e
        grunt.log.writeln ['File', f.dest, 'failed'].join(' ')
        grunt.log.error e

    grunt.log.ok "#{count} files fixed by Zuckrig Closure."
