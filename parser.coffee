console.log("parser.coffee entrypoint")

splitSexp = (str) ->
  brace = 0
  ans = []
  s = ""
  for c in str
    if c == "("
      brace += 1
    else if c == ")"
      brace -= 1
      throw "brace unmatched." if brace < 0

    if brace == 0 && c == " " && s.length != 0
      ans.push(s)
      s = ""
    else
      s += c

  throw "brace unmatched" if brace != 0
  ans.push(s) if s.length != 0

  return ans

parseTerm = (nonTerminals) -> (args) -> (str) ->
  if str[0] == "("
    terms = splitSexp(str[1..-2].trim()).map(parseTerm(nonTerminals)(args))

    app = terms[0]
    for t in terms[1..]
      app = new App(app, t)

    terms[0].match(
      (label, _) -> new Co(label, terms[1..]),
      (_) -> app,
      (_) -> app,
      (_, _) -> app,
      (_, _) -> app)
  else
    if args.indexOf(str) != -1
      new Id(str)
    else if nonTerminals.indexOf(str) != -1
      new Fs(str)
    else
      new Co(str, [])

parseHors = (str) ->
  rules = str.trim().split(/\n/).map((s) ->
    [l, r] = s.split("->")
    tmp = l.trim().split(/\s+/)
    [tmp[0], tmp[1..], r.trim()])

  nonTerminals = rules.map((r) ->r[0])

  bodies = {}
  for r in rules
    body = parseTerm(nonTerminals)(r[1])(r[2])
    for x in r[1].reverse()
      body = new Abs(x, body)
    bodies[r[0]] = body

  return new Hors(bodies, nonTerminals[0])
