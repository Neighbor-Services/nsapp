#!/bin/bash
echo "Building Android AppBundle with Obfuscation..."
flutter build appbundle --release --obfuscate --split-debug-info=./debug_info --target lib/main_prod.dart

echo "Building Android APK with Obfuscation..."
flutter build apk --release --obfuscate --split-debug-info=./debug_info --target lib/main_prod.dart
echo "Done."
