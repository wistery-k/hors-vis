console.log("wistery.coffee")

inject = (lst, init, f) ->
  for x in lst
    init = f(init, x)
  return init

forAny = (lst, f) ->
  inject(lst, false, (acc, x) -> acc || f(x))

forAll = (lst, f) ->
  inject(lst, true, (acc, x) -> acc && f(x))