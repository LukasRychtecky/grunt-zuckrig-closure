require 'sugar'

ANNO =
  CTOR: '@constructor'
  EXTENDS: '@extends'

class ConstructorHook

  ###*
    Injects a constructor annotation. If the annotation is provided does nothing.
  ###
  fix: (tokens) ->
    @._find_constructors tokens

  _inject_annotations: (comment, tokens) ->

    if comment.type is 'Block'

      if comment.value.indexOf(ANNO.CTOR) is -1
        extends_pos = comment.value.indexOf "  #{ANNO.EXTENDS}"

        if extends_pos is -1
          comment.value += "  #{ANNO.CTOR}\n  "
        else
          begin = comment.value.substring 0, extends_pos
          end = comment.value.substr extends_pos
          comment.value = [begin, "  #{ANNO.CTOR}\n  ", end].join ''

    else
      @_inject_new_block @_build_ctor_token(ANNO.CTOR, comment.loc), tokens

  _build_ctor_token: (ctor, loc) ->
    tok =
      type: 'Block',
      value: "*\n  #{ctor}\n"
      loc: {}

    for k, v of loc
      tok.loc[k] = v.clone true
    tok.loc.start.column = 0
    tok.loc.start.line++

  _inject_new_block: (tok, tokens) ->
    tokens.splice i, 0, tok

  _is_constructor: (token, next_sibling) ->
    token.type is 'Keyword' and
    token.value is 'function' and
    next_sibling and
    next_sibling.type is 'Identifier' and
    # ctor from __extends injected helper
    next_sibling.value isnt 'ctor'

  _find_constructors: (tokens) ->
    for token, i in tokens
      next_sibling = tokens[i + 1]
      continue if !@._is_constructor token, next_sibling
      token.__className = next_sibling.value
      @_inject_annotations tokens[i - 1], tokens

module.exports = ConstructorHook
