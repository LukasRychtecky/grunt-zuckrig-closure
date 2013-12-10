###*
  Inspirated by https://github.com/steida/coffee2closure
###
class Writer

  _create_space: (length, new_line) ->
    # very rare case, when \ is used in coffee source.
    return '' if length < 0
    space = new Array(length + 1).join ' '
    space = '\n' + space if new_line
    space

  write: (tokens) ->
    source = ''
    prev = null
    for token, i in tokens
      new_line = false
      if prev?
        new_line = token.loc.start.line != prev.loc.end.line
        if new_line
          source += @_create_space token.loc.start.column, true
        else
          source += @_create_space token.loc.start.column - prev.loc.end.column

      if token.type is 'NewBlock'
        source += "  /*#{token.value}  */"
      else if token.type is 'Block'
        source += "/*#{token.value}*/"
      # CoffeeScript 1.4 does not support inline comments, but 2 will do.
      else if token.type == 'Line'
        source += "//#{token.value}"
      else
        source += token.value
        # weird hack, because Este coffee2closure removes last curly bracket, heh?
        source += "\n" if token.value is ';'

      prev = token
    source

module.exports = Writer
