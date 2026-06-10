#!/bin/bash
# ─────────────────────────────────────────────────────────
# Price Pilot — Run All Tests
# ─────────────────────────────────────────────────────────
# Usage:
#   ./scripts/test.sh              # Run all tests
#   ./scripts/test.sh --coverage   # Generate coverage report
#
# This script runs unit and widget tests. For integration
# tests (which require a device/emulator), use:
#   ./scripts/integration_test.sh
# ─────────────────────────────────────────────────────────

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     🛩️  Price Pilot — Test Runner          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
echo ""

# Ensure we're in the project root
cd "$(dirname "$0")/.." || exit

# Step 1: Format check
echo -e "${YELLOW}[1/4]${NC} 🎨 Checking code formatting..."
if dart format --output=none --set-exit-if-changed . 2>/dev/null; then
  echo -e "  ${GREEN}✅ Formatting OK${NC}"
else
  echo -e "  ${RED}❌ Formatting issues found. Run: dart format .${NC}"
  exit 1
fi

# Step 2: Analysis
echo -e "${YELLOW}[2/4]${NC} 🔍 Running static analysis..."
if flutter analyze --no-fatal-infos 2>/dev/null; then
  echo -e "  ${GREEN}✅ Analysis clean${NC}"
else
  echo -e "  ${RED}❌ Analysis issues found${NC}"
  exit 1
fi

# Step 3: Unit tests
echo -e "${YELLOW}[3/4]${NC} 🧪 Running unit tests..."
if [[ "${1:-}" == "--coverage" ]]; then
  flutter test test/unit/ --coverage --reporter expanded
else
  flutter test test/unit/ --reporter expanded
fi
echo -e "  ${GREEN}✅ Unit tests passed${NC}"

# Step 4: Widget tests
echo -e "${YELLOW}[4/4]${NC} 🧩 Running widget tests..."
flutter test test/widget/ --reporter expanded
echo -e "  ${GREEN}✅ Widget tests passed${NC}"

# Coverage report
if [[ "${1:-}" == "--coverage" ]] && command -v genhtml &>/dev/null; then
  echo ""
  echo -e "${CYAN}📊 Generating HTML coverage report...${NC}"
  genhtml coverage/lcov.info -o coverage/html --quiet
  echo -e "  ${GREEN}✅ Coverage report: coverage/html/index.html${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ All tests passed successfully!     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
