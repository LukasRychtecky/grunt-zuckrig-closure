require 'sugar'

ANNO =
  CTOR: '@constructor'
  EXTENDS: '@extends'

class ConstructorHook
  @_super_class = null

  ###*
    Injects a constructor annotation. If the annotation is provided does nothing.
  ###
  fix: (tokens) ->
    @._try_find_super_class tokens
    @._find_constructor tokens

  _inject_annotations: (i, comment, tokens) ->

    if comment.type is 'Block'

      if comment.value.indexOf(ANNO.CTOR) is -1
        extends_pos = comment.value.indexOf "  #{ANNO.EXTENDS}"

        if extends_pos is -1
          comment.value += "  #{ANNO.CTOR}\n  "

          if @_super_class?
            comment.value += "#{@_build_extends_anno()}  "
        else
          begin = comment.value.substring 0, extends_pos
          end = comment.value.substr extends_pos
          comment.value = [begin, "  #{ANNO.CTOR}\n  ", end].join ''

    else
      @_inject_new_block i, @_build_ctor_token(comment.loc), tokens

  _build_ctor_token: (loc) ->
    tok =
      type: 'NewBlock',
      value: "*\n    #{ANNO.CTOR}\n"
      loc: {}

    if @_super_class?
      tok.value += "  #{@_build_extends_anno()}"

    for k, v of loc
      tok.loc[k] = Object.clone(v, true)

    if tok.loc.start?
      tok.loc.start.column = 0
      tok.loc.start.line--

    tok

  _build_extends_anno: () ->
    "  #{ANNO.EXTENDS} {#{@_super_class}}\n"

  _inject_new_block: (i, tok, tokens) ->
    tokens.splice i, 0, tok

  _is_constructor: (token, next_sibling) ->
    token.type is 'Keyword' and
    token.value is 'function' and
    next_sibling and
    next_sibling.type is 'Identifier' and
    # ctor from __extends injected helper
    next_sibling.value isnt 'ctor'

  _find_constructor: (tokens) ->
    for token, i in tokens
      next_sibling = tokens[i + 1]
      continue if !@._is_constructor token, next_sibling
      @_inject_annotations i, tokens[i - 1], tokens
      return

  _is_extending: (tok, next) ->
    tok.type is 'Identifier' and tok.value is '__extends' and next.value is '('

  _try_find_super_class: (tokens) ->
    for tok, i in tokens
      next = tokens[i + 1]
      if @._is_extending tok, next
        @_parse_super_class i, tokens
        return

  _parse_super_class: (i, tokens) ->
    len = tokens.length

    while i < len
      tok = tokens[i]

      if tok.type isnt 'Keyword' or tok.value isnt 'return'
        i += 1
        continue

      if tokens[i + 2].value isnt ';'
        i += 2
        continue

      if tokens[i + 3].value isnt '}'
        i += 3
        continue

      if tokens[i + 4].value isnt ')'
        i += 4
        continue

      if tokens[i + 5].value isnt '('
        i += 5
        continue

      if tokens[i + 6].type isnt 'Identifier'
        i += 6
        continue

      super_class = []

      j = 6
      loop
        next = tokens[i + j]
        break unless next.type is 'Identifier' or next.value is '.'
        super_class.push next.value
        j++
        @_super_class = super_class.join('')
      break

module.exports = ConstructorHook
