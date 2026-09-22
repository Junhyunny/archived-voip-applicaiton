WORKSPACE := voip-ios.xcworkspace
SCHEME := voip-ios
DESTINATION := platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5

test:
	xcodebuild test \
		-workspace "$(WORKSPACE)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)"
