PATHS = Sources/ Tests/

lint:
	swiftlint lint $(PATHS)

autocorrect:
	swiftlint autocorrect $(PATHS)
