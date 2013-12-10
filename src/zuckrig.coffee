esprima = require 'esprima'
Parser = require '../lib/Parser'
Writer = require '../lib/Writer'
ConstructorHook = require '../lib/ConstructorHook'
Extractor = require '../lib/Extractor'
TokenBuilder = require '../lib/TokenBuilder'

exports.zuckrig = (source) ->
  parser = new Parser source

  tokens = parser.parse()

  ctor_hook = new ConstructorHook new Extractor(), new TokenBuilder()
  ctor_hook.fix tokens

  writer = new Writer()

  fixed = writer.write tokens

  return fixed
