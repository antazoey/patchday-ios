SWIFT_VERSION = DEVELOPMENT-SNAPSHOT-2016-05-03-a
 
# OS specific differences
UNAME = ${shell uname}
ifeq ($(UNAME), Darwin)
SWIFTC_FLAGS =
LINKER_FLAGS = -Xlinker -L/usr/local/lib
endif
ifeq ($(UNAME), Linux)
SWIFTC_FLAGS = -Xswiftc "-sdk" -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios14.2-simulator"
LINKER_FLAGS = -Xlinker -rpath -Xlinker .build/debug

endif
 
 
build:
	swift build $(SWIFTC_FLAGS) $(LINKER_FLAGS)
 
test: build
	swift test

lint:
	swiftlint lint

autocorrect:
	swiftlint autocorrect
 
clean:
	swift build --clean
 
distclean:
	rm -rf Packages
	swift build --clean
 
 
.PHONY: build test distclean
