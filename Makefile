VERSION=0.1.0

default:
	cat ./Makefile

.PHONY: build
build:
	rm -rf ./build
	mkdir -p build/jazip-${VERSION}
	dart2native bin/main.dart -o build/jazip-${VERSION}/jazip
	tar -czvf build/jazip-${VERSION}.tar.gz -C build jazip-${VERSION}