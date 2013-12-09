esprima = require 'esprima'

###*
  Inspirated by https://github.com/steida/coffee2closure
###
class Parser

  constructor: (@source) ->
    @parsed = null
    @tokens = null

  parse: ->
    @parsed = esprima.parse @source,
      comment: true
      tokens: true
      range: true
      loc: true
    @_prepare_tokens()

  _prepare_tokens: ->
    @tokens = @parsed.tokens.concat @parsed.comments
    @_sort_tokens @tokens

  _sort_tokens: ->
    @tokens.sort (a, b) ->
      return 1 if a.range[0] > b.range[0]
      return -1 if a.range[0] < b.range[0]
      0

module.exports = Parser
