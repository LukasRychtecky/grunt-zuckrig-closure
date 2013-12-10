class TokenBuilder

  build_punc: (val, loc) ->
    {type: 'Punctuator', value: val, loc: loc}

  build_iden: (val, loc) ->
    {type: 'Identifier', value: val, loc: loc}

  build_str: (val, loc) ->
    {type: 'String', value: val, loc: loc}

  build_goog_call: (method, arg, loc) ->
    [
      @build_iden('goog', loc),
      @build_punc('.', loc),
      @build_iden(method, loc),
      @build_punc('(', loc),
      @build_str(arg, loc),
      @build_punc(')', loc),
      @build_punc(';', loc)
    ]

module.exports = TokenBuilder
