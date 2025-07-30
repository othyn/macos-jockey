.PHONY: setup
setup:
	git config core.hooksPath .githooks
	bundle install

.PHONY: lint
lint:
	swiftlint --strict

# https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile
# https://docs.fastlane.tools/plugins/using-plugins/
# This may not work due to permissions, so use `$ fastlane update` which calls `brew` under the hood
.PHONY: update
update:
	sudo bundle update fastlane
	bundle exec fastlane update_plugins

.PHONY: local
local:
	bundle exec fastlane mac local

.PHONY: beta
beta:
	bundle exec fastlane mac beta

.PHONY: prod
prod:
	bundle exec fastlane mac production

.PHONY: clean
clean:
	# Clean Xcode build folder
	xcodebuild clean -project jockey.xcodeproj -scheme jockey
	# Remove app preferences and state
	rm -rf ~/Library/Preferences/com.othyn.jockey.plist
	rm -rf ~/Library/Saved\ Application\ State/com.othyn.jockey.savedState
	# Reset defaults
	defaults delete com.othyn.jockey 2>/dev/null || true
	@echo "App has been reset to simulate a fresh installation"
