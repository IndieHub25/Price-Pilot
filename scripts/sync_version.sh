#!/bin/bash
# ─────────────────────────────────────────────────────────
# Price Pilot — Version Sync Script
# ─────────────────────────────────────────────────────────
# Reads the latest version from CHANGELOG.md and updates:
#   1. pubspec.yaml  (version: x.y.z+buildNumber)
#   2. lib/core/constants/app_constants.dart  (appVersion)
#
# Usage:
#   ./scripts/sync_version.sh          # Sync & verify
#   ./scripts/sync_version.sh --check  # Verify only (CI mode)
# ─────────────────────────────────────────────────────────

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Resolve project root (script lives in scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"
PUBSPEC="$PROJECT_ROOT/pubspec.yaml"
APP_CONSTANTS="$PROJECT_ROOT/lib/core/constants/app_constants.dart"

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     🔄 Price Pilot — Version Sync         ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
echo ""

# ── Step 1: Extract latest version from CHANGELOG.md ─────
echo -e "${YELLOW}[1/4]${NC} 📖 Reading version from CHANGELOG.md..."

CHANGELOG_VERSION=$(grep -oE '## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$CHANGELOG" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

if [[ -z "$CHANGELOG_VERSION" ]]; then
  echo -e "  ${RED}❌ Could not find a version in CHANGELOG.md${NC}"
  echo -e "  Expected format: ## [x.y.z]"
  exit 1
fi

echo -e "  ${GREEN}✅ CHANGELOG version: ${CHANGELOG_VERSION}${NC}"

# ── Step 2: Read current versions from other files ────────
echo -e "${YELLOW}[2/4]${NC} 🔍 Reading current versions..."

PUBSPEC_VERSION=$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/version: *//' | sed 's/+.*//' | tr -d '[:space:]')
PUBSPEC_BUILD=$(grep -E '^version:' "$PUBSPEC" | head -1 | grep -oE '\+[0-9]+' | tr -d '+' || echo "1")
CONSTANTS_VERSION=$(grep -oE "appVersion = '[0-9]+\.[0-9]+\.[0-9]+'" "$APP_CONSTANTS" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

echo -e "  pubspec.yaml:       ${PUBSPEC_VERSION}+${PUBSPEC_BUILD}"
echo -e "  app_constants.dart: ${CONSTANTS_VERSION}"
echo -e "  CHANGELOG.md:       ${CHANGELOG_VERSION}"

# ── Check-only mode ───────────────────────────────────────
if [[ "${1:-}" == "--check" ]]; then
  if [[ "$PUBSPEC_VERSION" == "$CHANGELOG_VERSION" && "$CONSTANTS_VERSION" == "$CHANGELOG_VERSION" ]]; then
    echo ""
    echo -e "${GREEN}✅ All versions are in sync: ${CHANGELOG_VERSION}${NC}"
    exit 0
  else
    echo ""
    echo -e "${RED}❌ Version mismatch detected!${NC}"
    echo -e "  Run ${CYAN}./scripts/sync_version.sh${NC} to fix."
    exit 1
  fi
fi

# ── Step 3: Update pubspec.yaml ───────────────────────────
echo -e "${YELLOW}[3/4]${NC} ✏️  Updating pubspec.yaml..."

if [[ "$PUBSPEC_VERSION" != "$CHANGELOG_VERSION" ]]; then
  # Increment build number when version changes
  NEW_BUILD=$((PUBSPEC_BUILD + 1))
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/^version: .*/version: ${CHANGELOG_VERSION}+${NEW_BUILD}/" "$PUBSPEC"
  else
    sed -i "s/^version: .*/version: ${CHANGELOG_VERSION}+${NEW_BUILD}/" "$PUBSPEC"
  fi
  echo -e "  ${GREEN}✅ Updated to ${CHANGELOG_VERSION}+${NEW_BUILD}${NC}"
else
  echo -e "  ${GREEN}✅ Already up to date (${PUBSPEC_VERSION}+${PUBSPEC_BUILD})${NC}"
fi

# ── Step 4: Update app_constants.dart ─────────────────────
echo -e "${YELLOW}[4/4]${NC} ✏️  Updating app_constants.dart..."

if [[ "$CONSTANTS_VERSION" != "$CHANGELOG_VERSION" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/appVersion = '${CONSTANTS_VERSION}'/appVersion = '${CHANGELOG_VERSION}'/" "$APP_CONSTANTS"
  else
    sed -i "s/appVersion = '${CONSTANTS_VERSION}'/appVersion = '${CHANGELOG_VERSION}'/" "$APP_CONSTANTS"
  fi
  echo -e "  ${GREEN}✅ Updated to ${CHANGELOG_VERSION}${NC}"
else
  echo -e "  ${GREEN}✅ Already up to date${NC}"
fi

# ── Final verification ────────────────────────────────────
echo ""
FINAL_PUBSPEC=$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/version: *//' | sed 's/+.*//' | tr -d '[:space:]')
FINAL_CONSTANTS=$(grep -oE "appVersion = '[0-9]+\.[0-9]+\.[0-9]+'" "$APP_CONSTANTS" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

if [[ "$FINAL_PUBSPEC" == "$CHANGELOG_VERSION" && "$FINAL_CONSTANTS" == "$CHANGELOG_VERSION" ]]; then
  echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✅ All versions synced to ${CHANGELOG_VERSION}           ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
else
  echo -e "${RED}❌ Sync failed — please check files manually${NC}"
  exit 1
fi
echo ""
