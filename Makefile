new_doc_name ?= "posts/A new document.md"

all: build

.PHONY: build
build:
	@camus -v
	@camus -id

.PHONY: new
new:
	@echo "---" >> $(new_doc_name)
	@echo "display-name: " >> $(new_doc_name)
	@echo "date: $(shell date +'%Y-%m-%d %H:%M:00')" >> $(new_doc_name)
	@echo "---" >> $(new_doc_name)
