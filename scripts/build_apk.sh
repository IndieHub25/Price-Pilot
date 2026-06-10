#!/bin/bash
# ─────────────────────────────────────────────────────────
# Price Pilot — APK Build Script
# ─────────────────────────────────────────────────────────
# Builds a release APK and copies it to the apk/ directory
# with a versioned filename: PricePilot-v{version}.apk
#
# Usage:
#   ./scripts/build_apk.sh
# ─────────────────────────────────────────────────────────

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PUBSPEC="$PROJECT_ROOT/pubspec.yaml"
APK_DIR="$PROJECT_ROOT/apk"

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     📦 Price Pilot — APK Builder          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
echo ""

# ── Step 1: Sync version first ────────────────────────────
echo -e "${YELLOW}[1/5]${NC} 🔄 Syncing version from CHANGELOG..."
"$SCRIPT_DIR/sync_version.sh"

# ── Step 2: Read version from pubspec.yaml ────────────────
echo -e "${YELLOW}[2/5]${NC} 📖 Reading version..."
VERSION=$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/version: *//' | tr -d '[:space:]')
VERSION_NAME=$(echo "$VERSION" | sed 's/+.*//')

echo -e "  Version: ${GREEN}${VERSION}${NC}"
echo -e "  APK will be: ${GREEN}PricePilot-v${VERSION_NAME}.apk${NC}"

# ── Step 3: Clean previous build ─────────────────────────
echo ""
echo -e "${YELLOW}[3/5]${NC} 🧹 Cleaning previous build..."
cd "$PROJECT_ROOT"
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1
echo -e "  ${GREEN}✅ Clean complete${NC}"

# ── Step 4: Build release APK ─────────────────────────────
echo ""
echo -e "${YELLOW}[4/5]${NC} 🔨 Building release APK..."
flutter build apk --release

BUILT_APK="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"

if [[ ! -f "$BUILT_APK" ]]; then
  echo -e "  ${RED}❌ APK not found at expected path${NC}"
  echo -e "  Expected: $BUILT_APK"
  exit 1
fi

echo -e "  ${GREEN}✅ Build successful${NC}"

# ── Step 5: Copy to apk/ directory ────────────────────────
echo ""
echo -e "${YELLOW}[5/5]${NC} 📂 Copying APK to apk/ directory..."

mkdir -p "$APK_DIR"

APK_FILENAME="PricePilot-v${VERSION_NAME}.apk"
cp "$BUILT_APK" "$APK_DIR/$APK_FILENAME"

APK_SIZE=$(du -h "$APK_DIR/$APK_FILENAME" | cut -f1)

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ APK built successfully!               ║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  📁 ${APK_FILENAME}${NC}"
echo -e "${GREEN}║  📍 ${APK_DIR}/${APK_FILENAME}${NC}"
echo -e "${GREEN}║  📏 Size: ${APK_SIZE}${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
