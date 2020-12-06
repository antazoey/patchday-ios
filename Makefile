# <<<<<<< HEAD
# SWIFT_VERSION = DEVELOPMENT-SNAPSHOT-2016-05-03-a
 
# # OS specific differences
# UNAME = ${shell uname}
# ifeq ($(UNAME), Darwin)
# SWIFTC_FLAGS =
# LINKER_FLAGS = -Xlinker -L/usr/local/lib
# endif
# ifeq ($(UNAME), Linux)
# SWIFTC_FLAGS = -Xswiftc "-sdk" -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios14.2-simulator"
# LINKER_FLAGS = -Xlinker -rpath -Xlinker .build/debug

# endif
 
 
# build:
# 	swift build $(SWIFTC_FLAGS) $(LINKER_FLAGS)
 
# test: build
# 	swift test

# lint:
# 	swiftlint lint

# autocorrect:
# 	swiftlint autocorrect
 
# clean:
# 	swift build --clean
 
# distclean:
# 	rm -rf Packages
# 	swift build --clean
 
 
# .PHONY: build test distclean
CMD = xcodebuild
LINT_PATHS = Sources/ Tests/
LINT_FLAGS = --reporter junit | tee result.xml
TEST_BUILD = xcodebuild build-for-testing 
TEST_FLAGS = -destination 'platform=iOS Simulator,name=iPhone 11,OS=14.2'

SWIFTC_FLAGS = -Xswiftc "-sdk" -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios14.2-simulator"
LINKER_FLAGS = -Xlinker -rpath -Xlinker .build/debug

build:
	$(CMD)

build-ci:
	swift build $(SWIFTC_FLAGS) $(LINKER_FLAGS)

build-for-tests:
	$(TEST_BUILD) -scheme Tests $(TEST_FLAGS)

test: test-pdkit test-patchdata test-patchday

test-pdkit: build-for-tests
	$(CMD) test -scheme PDKitTests $(TEST_FLAGS)

test-patchdata: build-for-tests
	$(CMD) test -scheme PatchDataTests $(TEST_FLAGS)

test-patchday: build-for-tests
	$(CMD) test -scheme PatchDayTests $(TEST_FLAGS)

lint:
	swiftlint lint $(LINT_PATHS) $(LINT_FLAGS)

autocorrect:
	swiftlint autocorrect $(LINT_PATHS)


.PHONY: build build-for-tests test test-pdkit test-patchdata test-patchday lint autocorrect
