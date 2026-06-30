all: build

.PHONY: build
build:
	@/usr/local/bin/camus -v
	@/usr/local/bin/camus
	@python3 -m http.server --bind localhost 8000 --directory html
