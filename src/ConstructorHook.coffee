require 'sugar'

ANNO =
  CTOR: '@constructor'
  EXTENDS: '@extends'

class ConstructorHook

  constructor: (@_extractor, @_builder) ->
    @_super_class = null
    @_required = []
    @_produce_pos = -1
    @_to_inject = {}
    @_class_name = null

  ###*
    Injects a constructor annotation. If the annotation is provided does nothing.
    Also injects goog.require and @extends for a super class, if it's necessary.
  ###
  fix: (tokens) ->
    for tok, i in tokens
      @_try_find_super_class tok, i, tokens
      @_find_constructor tok, i, tokens
      @_find_produce_position tok, i, tokens
      @_find_required tok, i, tokens
      @_find_class_name tok, i, tokens

    for k, v of @_to_inject
      @_inject_annotations k, v, tokens

    @_inject_class_provide tokens
    @_inject_require_super tokens

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

  _find_constructor: (tok, i, tokens) ->
    next = tokens[i + 1]
    return if !@_is_constructor tok, next
    @_to_inject[i] = tokens[i - 1]

  _is_extending: (tok, next) ->
    tok.type is 'Identifier' and tok.value is '__extends' and next.value is '('

  _try_find_super_class: (tok, i, tokens) ->
    next = tokens[i + 1]
    if @_is_extending tok, next
      @_super_class = @_extractor.parse_super_class i, tokens
      return

  _find_produce_position: (tok, i, tokens) ->
    return if @_produce_pos isnt -1
    if tok.value is 'goog' and tokens[i + 1].value is '.' and tokens[i + 2].value is 'provide'
      @_produce_pos = i + 7

  _inject_require_super: (tokens) ->
    if @_super_class? and @_produce_pos isnt -1 and @_super_class not in @_required

      @_insert_tokens @_build_super_require(tokens[@_produce_pos].loc), tokens, @_produce_pos

  _insert_tokens: (to_insert, tokens, i) ->
    for tok in to_insert
      tokens.splice i, 0, tok
      i++

  _build_super_require: (orig) ->
    loc = {}
    for k, v of orig
      loc[k] = Object.clone v, true
    loc.start.line++
    loc.end.line++

    @_builder.build_goog_call 'require', "'#{@_super_class}'", loc

  _build_fake_location: ->
    start:
      line: 0
      column: 0
    end:
      line: 0
      column: 0

  _replace_escaped_chars: (val) ->
    val.replace /\\|'/g, ''

  _find_required: (tok, i, tokens) ->
    if tok.value is 'goog' and tokens[i + 1].value is '.' and tokens[i + 2].value is 'require'
      @_required.push @_replace_escaped_chars(tokens[i + 4].value)

  _find_class_name: (tok, i, tokens) ->
    return if @_class_name?
    @_class_name = @_extractor.parse_class_from_def i, tokens

  _inject_class_provide: (tokens) ->
    if @_produce_pos is -1
      provide = @_builder.build_goog_call 'provide', "'#{@_class_name}'", @_build_fake_location()

      @_insert_tokens provide, tokens, 0
      @_produce_pos = provide.length

module.exports = ConstructorHook
