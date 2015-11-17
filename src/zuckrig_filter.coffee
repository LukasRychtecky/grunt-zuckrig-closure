esprima = require 'esprima'
Parser = require '../tasks/Parser'
Writer = require '../tasks/Writer'
ConstructorHook = require '../tasks/ConstructorHook'
Extractor = require '../tasks/Extractor'
TokenBuilder = require '../tasks/TokenBuilder'

module.exports.zuckrig = (source) ->
  parser = new Parser source

  tokens = parser.parse()

  ctor_hook = new ConstructorHook(new Extractor(), new TokenBuilder())
  fix_tokens = ctor_hook.fix(tokens)

  writer = new Writer()

  return writer.write(fix_tokens)
