CMD = xcodebuild
LINT_PATHS = Sources/ Tests/
LINT_FLAGS = --reporter junit | tee result.xml
TEST_BUILD = xcodebuild build-for-testing 
TEST_FLAGS = -destination 'platform=iOS Simulator,name=iPhone 11,OS=14.2'

build:
	$(CMD)

build-ci:
	swiftc

build-for-tests:
	$(TEST_BUILD) -scheme Tests $(TEST_FLAGS)

test: build-for-tests
	$(CMD) test -scheme PDKitTests $(TEST_FLAGS)
	$(CMD) test -scheme PatchDataTests $(TEST_FLAGS)
	$(CMD) test -scheme PatchDayTests $(TEST_FLAGS)

lint:
	swiftlint lint $(LINT_PATHS) $(LINT_FLAGS)

autocorrect:
	swiftlint autocorrect $(LINT_PATHS)
