console.log("main.coffee entry point")

g = canvas.getContext("2d")
g.font = "bold 20pt Times New Roman"

# show :: Term -> String

show = (term) -> term.match(
  (label, children) ->
    if children.length == 0
      label
    else
      "(" + label + " " + (children.map show).join(" ") + ")"
  ,
  (sym) -> sym
  (id) -> id
  (id, body) -> "(\\" + id + "." + show(body) + ")",
  (t1, t2) -> "(" + show(t1) + " " + show(t2) + ")")

# substitute ::: Term -> Term -> Term

substitute = (t1, t2) ->
  substitute_ = (id, t2) -> (t1) ->
    t1.match(
      (label, children) -> new Co(label, children.map(substitute_(id, t2))),
      (sym) -> new Fs(sym),
      (id_) -> if (id_ == id) then t2 else new Id(id_),
      (id_, body) ->
        new Abs(id_, if id_ == id then body else substitute_(id, t2)(body))
      ,
      (t1_, t2_) ->
        new App(substitute_(id, t2)(t1_), substitute_(id, t2)(t2_)))
  t1.match(
    (_, _) -> throw "unable to substitute.",
    (_) -> throw "unable to substitute.",
    (_) -> throw "unable to substitute.",
    (id, body) -> substitute_(id, t2)(body),
    (_, _) -> throw "unable to substitute.")

# termToTree :: Term -> Tree

termToTree = (term) ->
  term.match(
    (label, children) -> new Node(label, children.map(termToTree)),
    (sym) -> new Leaf(new Fs(sym)),
    (id) -> new Leaf(new Id(id)),
    (id, body) -> new Leaf(new Abs(id, body)),
    (t1, t2) -> new Leaf(new App(t1, t2)))

# evalTerm :: Hors#bodies -> Term -> Term

evalTerm = (bodies) -> (term) ->
  term.match(
    (label, children) -> new Co(label, children.map(evalTerm(bodies))),
    (sym) -> bodies[sym],
    (id) -> new Id(id),
    (id, body) -> new Abs(id, body),
    (t1, t2) ->
      substitute(evalTerm(bodies)(t1), t2))

# expandTree :: Hors#bodies -> Tree -> Tree

expandTree = (bodies) -> (tree) ->
  tree.match(
    (label, children) -> new Node(label, children.map(expandTree(bodies))),
    (term) -> termToTree(evalTerm(bodies)(term)))

width = (tree) ->
  tree.match(
    (_, children) -> if children.length == 0
                       1
                     else
                       inject(children.map(width), 0, (x,y) -> x+y)
    ,
    (_) -> 1)

drawTree = (tree) ->
  return unless tree
  H = 40
  drawTree_ = (tree, x, y, w) ->
    xx = x + w / 2
    yy = y + H / 2
    tree.match(
      (label, children) ->
        n = children.length
        widths = children.map(width)
        widthSum = inject(widths, 0, (x, y) -> x+y)
                
        accumW = 0
        for i in [0...n]
          cw = w * widths[i] / widthSum
          [cx, cy] = drawTree_(children[i], x + accumW, y + H, cw)
          accumW += cw
          g.beginPath()
          g.moveTo(xx, yy)
          g.lineTo(cx, cy)
          g.closePath()
          g.stroke()
        m = g.measureText(label)
        g.fillStyle = 'rgb(192, 80, 77)'
        g.fillText(label, xx - m.width / 2, yy)
      ,
      (term) ->
        str = show(term)
        if str.length > 10
          str = str[0..7] + "..."
        m = g.measureText(str)
        g.fillStyle = 'rgb(80, 77, 192)'
        g.fillText(str, xx - m.width / 2, yy))
    [xx, yy]
  g.clearRect(0, 0, canvas.width, canvas.height)
  drawTree_(tree, 0, 0, canvas.width)

horsRef = null
treeRef = null

clearRef = (e) ->
  horsRef = null
  treeRef = null
  g.clearRect(0, 0, canvas.width, canvas.height)

expandRoot = (e) ->
  return unless horsRef && treeRef
  try
    treeRef = expandTree(horsRef.bodies)(treeRef)
  catch exn
    alert(exn)
    throw exn

  console.log(treeRef)

  drawTree(treeRef)

readAndInit = (e) ->
  try
    horsRef = parseHors(input.value)
  catch exn
    alert(exn)

  console.log(horsRef)

  for sym, body of horsRef.bodies
    console.log(sym + " = " + show(body))

  treeRef = new Leaf(new Fs(horsRef.startSymbol))
  drawTree(treeRef)

main = () ->
  parseButton.addEventListener("click", readAndInit, false)
  expandButton.addEventListener("click", expandRoot, false)
  clearButton.addEventListener("click", clearRef, false)

main()