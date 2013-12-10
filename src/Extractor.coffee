class Extractor

  @_extend_seq = [
    {k: 2, v: ';'}
    {k: 3, v: '}'}
    {k: 4, v: ')'}
    {k: 5, v: '('}
  ]

  class_name: (i, tokens, back = false) ->
    class_name = []
    loop
      next = tokens[i]
      break unless next.type is 'Identifier' or next.value is '.'
      class_name.push next.value
      if back then i-- else i++

    class_name.reverse() if back
    class_name.join ''

  parse_super_class: (i, tokens) ->
    len = tokens.length
    super_class = null

    while i < len
      tok = tokens[i]

      if tok? and (tok.type isnt 'Keyword' or tok.value isnt 'return')
        i += 1
        continue

      skip = false
      for seq in Extractor._extend_seq
        if tokens[i + seq.k]? and tokens[i + seq.k].value isnt seq.v
          i += seq.k
          skip = true
          break

      continue if skip

      if tokens[i + 6].type isnt 'Identifier'
        i += 6
        continue

      super_class = @class_name i + 6, tokens
      break

    super_class

  parse_class_from_def: (i, tokens) ->
    class_name = null
    if tokens[i].value is '=' and tokens[i + 1].value is '(' and tokens[i + 2].value is 'function' and tokens[i + 3].value is '('

      class_name = @class_name i - 1, tokens, true
    class_name

module.exports = Extractor
