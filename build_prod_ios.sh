#!/bin/bash
echo "Building iOS IPA with Obfuscation..."
flutter build ipa --release --obfuscate --split-debug-info=./debug_info --target lib/main_prod.dart
echo "Done."
