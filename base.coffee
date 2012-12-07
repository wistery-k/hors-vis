console.log("base.coffee entry point")
# data Term

class Co
  constructor: (@label, @children) ->
  match: (f, _, _, _, _) -> f(@label, @children)

class Fs
  constructor: (@sym) ->
  match: (_, f, _, _, _) -> f(@sym)

class Id
  constructor: (@id) ->
  match: (_, _, f, _, _) -> f(@id)

class Abs
  constructor: (@id, @body) ->
  match: (_, _, _, f, _) -> f(@id, @body)

class App
  constructor: (@t1, @t2) ->
  match: (_, _, _, _, f) -> f(@t1, @t2)

# data Tree

class Node
  constructor: (@label, @children) ->
  match: (f, _) -> f(@label, @children)

class Leaf
  constructor: (@term) ->
  match: (_, f) -> f(@term)

class Hors
  constructor: (@bodies, @startSymbol) ->