set shell := ["bash", "-cu"]

python3 := require("python3")
camus := require("camus")
project_name := `basename "$PWD"`

default:
    @{{ camus }} --check

create name="":
    @{{ camus }} --create "{{ name }}.md"

build size="A5":
    @CAMUS_PDF_OPTIONS_PAGE_SIZE={{ size }} {{ camus }} --build

serve: clean
    @CAMUS_PDF_IMAGE_DOWNLOAD_CONCURRENCY=16 {{ camus }} -W

clean:
    @rm -rf dist/html dist/pdf || true
