VERSION=0.1.0

default:
	cat ./Makefile

.PHONY: build
build:
	mkdir -p build/jazip-${VERSION}
	dart2native bin/main.dart -o build/jazip-${VERSION}/jazip
	tar -zcvf build/jazip-${VERSION}.tar.gz build/jazip-${VERSION}