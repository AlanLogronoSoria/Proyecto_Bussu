#!/usr/bin/env bash
# Andes Mobility — Build Script
# Usage: ./scripts/build.sh [android|ios|all]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== Andes Mobility Build Script ===${NC}"

# Environment validation
validate_env() {
  echo "Validating environment..."
  
  if ! command -v flutter &> /dev/null; then echo -e "${RED}Flutter not found${NC}"; exit 1; fi
  echo "  Flutter: $(flutter --version | head -1)"
  
  local required_vars=("SUPABASE_URL" "SUPABASE_ANON_KEY")
  for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then echo -e "${RED}Missing: $var${NC}"; fi
  done
  
  if [ "${ENABLE_MOCK_AUTH:-true}" = "true" ] && [ "${IS_PRODUCTION:-false}" = "true" ]; then
    echo -e "${RED}ERROR: ENABLE_MOCK_AUTH=true with IS_PRODUCTION=true${NC}"
    exit 1
  fi
  echo -e "${GREEN}  Environment OK${NC}"
}

# Static analysis
analyze() {
  echo "Running static analysis..."
  flutter pub get
  flutter analyze || { echo -e "${RED}Analyze failed${NC}"; exit 1; }
  dart analyze lib/ || { echo -e "${RED}Dart analyze failed${NC}"; exit 1; }
  echo -e "${GREEN}  Analysis OK${NC}"
}

# Unit tests
test() {
  echo "Running tests..."
  flutter test --coverage || { echo -e "${RED}Tests failed${NC}"; exit 1; }
  echo -e "${GREEN}  Tests OK${NC}"
}

# Build Android
build_android() {
  echo "Building Android..."
  flutter build appbundle --release \
    --dart-define=IS_PRODUCTION=true \
    --dart-define=ENABLE_MOCK_AUTH=false \
    --obfuscate \
    --split-debug-info=build/debug-info/android
  echo -e "${GREEN}  Android AAB: build/app/outputs/bundle/release/app-release.aab${NC}"
}

# Build iOS
build_ios() {
  echo "Building iOS..."
  flutter build ios --release \
    --dart-define=IS_PRODUCTION=true \
    --dart-define=ENABLE_MOCK_AUTH=false \
    --obfuscate \
    --split-debug-info=build/debug-info/ios
  echo -e "${GREEN}  iOS build: build/ios/iphoneos/Runner.app${NC}"
}

# Main
validate_env
analyze
test

case "${1:-all}" in
  android) build_android ;;
  ios) build_ios ;;
  all) build_android; build_ios ;;
  *) echo "Usage: $0 [android|ios|all]" ; exit 1 ;;
esac

echo -e "${GREEN}=== Build Complete ===${NC}"
