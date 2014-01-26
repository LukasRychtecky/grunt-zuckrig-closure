esprima = require 'esprima'
Parser = require '../tasks/Parser'
Writer = require '../tasks/Writer'
ConstructorHook = require '../tasks/ConstructorHook'
Extractor = require '../tasks/Extractor'
TokenBuilder = require '../tasks/TokenBuilder'

module.exports.zuckrig = (source) ->
  parser = new Parser source

  tokens = parser.parse()

  ctor_hook = new ConstructorHook new Extractor(), new TokenBuilder()
  ctor_hook.fix tokens

  writer = new Writer()

  fixed = writer.write tokens

  return fixed
