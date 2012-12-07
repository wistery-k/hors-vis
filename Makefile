.PHONY: start

main.js: main.coffee
	coffee -cb main.coffee
start:
	coffee -cbw main.coffee &
	guard