# Run on the Mac. `brew install xcodegen` once.
.PHONY: gen build test open clean

gen:
	xcodegen generate

build: gen
	xcodebuild -project Lockdown.xcodeproj -scheme Lockdown \
	  -destination 'generic/platform=iOS Simulator' \
	  CODE_SIGNING_ALLOWED=NO build | tail -20

test:
	swift test --package-path Packages/LockdownCore

open: gen
	open Lockdown.xcodeproj

clean:
	rm -rf Lockdown.xcodeproj Packages/LockdownCore/.build DerivedData
