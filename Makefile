.PHONY: start

SOURCES = wistery.coffee base.coffee parser.coffee main.coffee 

main.js: $(SOURCES)
	coffee -cbj main.js $(SOURCES)
watch:
	coffee -cbwj main.js $(SOURCES)
