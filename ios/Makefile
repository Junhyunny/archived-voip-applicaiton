WORKSPACE := voip-ios.xcworkspace
SCHEME := voip-ios
DESTINATION := platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0

test:
	xcodebuild test \
		-workspace "$(WORKSPACE)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)"
