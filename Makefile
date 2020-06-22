.PHONY: build-appbundle
build-appbundle:
	flutter build appbundle --target-platform android-arm,android-arm64

.PHONY: build-apk
build-apk:
	flutter build apk --target-platform android-arm,android-arm64 --split-per-abi

.PHONY: build-mac
build-mac:
	flutter build macos
