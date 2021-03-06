TAGS ?= "sqlite"
GO_BIN ?= go

install:
	packr2
	$(GO_BIN) install -tags ${TAGS} -v .
	make tidy

tidy:
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
else
	echo skipping go mod tidy
endif

deps:
	$(GO_BIN) get github.com/gobuffalo/release
	$(GO_BIN) get github.com/gobuffalo/packr/v2/packr2
	$(GO_BIN) get -tags ${TAGS} -t ./...
	make tidy

build:
	packr2
	$(GO_BIN) build -v .
	make tidy

test:
	packr2
	go run ./helpers/main.go
	$(GO_BIN) test -cover -tags ${TAGS} ./...
	make tidy

ci-deps:
	$(GO_BIN) get -tags ${TAGS} -t ./...

ci-test:
	$(GO_BIN) test -tags ${TAGS} -race ./...

lint:
	gometalinter --vendor ./... --deadline=1m --skip=internal
	make tidy

update:
	$(GO_BIN) get -u -tags ${TAGS}
	make tidy
	packr2
	make test
	make install
	make tidy

release-test:
	go run ./helpers/main.go
	$(GO_BIN) test -tags ${TAGS} -race ./...
	make tidy

release:
	make tidy
	release -y -f version.go
	make tidy
