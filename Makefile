CMD = xcodebuild
LINT_PATHS = Sources/ Tests/
LINT_FLAGS =
TEST_BUILD = xcodebuild build-for-testing 
TEST_FLAGS = -destination 'platform=iOS Simulator,name=iPhone 11,OS=14.5'

build:
	@$(CMD)

build-for-tests:
	@$(TEST_BUILD) -scheme Tests $(TEST_FLAGS)

test: test-pdkit test-patchdata test-patchday

test-pdkit: build-for-tests
	@$(CMD) test -scheme PDKitTests $(TEST_FLAGS)

test-patchdata: build-for-tests
	@$(CMD) test -scheme PatchDataTests $(TEST_FLAGS)

test-patchday: build-for-tests
	@$(CMD) test -scheme PatchDayTests $(TEST_FLAGS)

lint:
	@swiftlint lint $(LINT_PATHS) $(LINT_FLAGS)

fix:
	@swiftlint fix $(LINT_PATHS)


.PHONY: build build-for-tests test test-pdkit test-patchdata test-patchday lint autocorrect
