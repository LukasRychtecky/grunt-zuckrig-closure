class Extractor

  @_extend_seq =
    2: ';'
    3: '}'
    4: ')'
    5: '('

  class_name: (i, tokens) ->
    class_name = []
    loop
      next = tokens[i]
      break unless next.type is 'Identifier' or next.value is '.'
      class_name.push next.value
      i++
    class_name.join ''

  parse_super_class: (i, tokens) ->
    len = tokens.length
    super_class = null

    while i < len
      tok = tokens[i]

      if tok.type isnt 'Keyword' or tok.value isnt 'return'
        i += 1
        continue

      for k, v of @_extend_seq
        if tokens[i + k].value isnt v
          i += k
          continue

      if tokens[i + 6].type isnt 'Identifier'
        i += 6
        continue

      super_class = @class_name i + 6, tokens
      break

    super_class

module.exports = Extractor
