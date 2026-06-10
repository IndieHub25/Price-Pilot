#!/bin/bash
# ─────────────────────────────────────────────────────────
# Price Pilot — Integration Test Runner
# ─────────────────────────────────────────────────────────
# Usage:
#   ./scripts/integration_test.sh
#
# Prerequisites:
#   - An Android emulator must be running, or a physical
#     device must be connected via USB/WiFi debugging.
#   - Verify with: flutter devices
#
# This test launches the app on the device and runs the
# full end-to-end test suite covering:
#   • Account creation (email + phone)
#   • Ride comparison (Uber, Ola, Rapido, Meru, etc.)
#   • Booking flow
#   • Profile editing
#   • Settings toggles
#   • Logout / re-login
#
# To run via Android Studio instead:
#   Right-click integration_test/app_test.dart → Run
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
echo -e "${CYAN}║  🛩️  Price Pilot — Integration Tests       ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
echo ""

# Ensure we're in the project root
cd "$(dirname "$0")/.." || exit

# Check for connected devices
echo -e "${YELLOW}[1/3]${NC} 📱 Checking for connected devices..."
DEVICES=$(flutter devices 2>/dev/null | grep -c "•" || true)

if [[ "$DEVICES" -eq 0 ]]; then
  echo -e "  ${RED}❌ No devices found!${NC}"
  echo ""
  echo "  Please start an Android emulator or connect a device:"
  echo "    emulator -avd <avd_name> &"
  echo "    flutter devices"
  echo ""
  exit 1
fi

echo -e "  ${GREEN}✅ Found $DEVICES device(s)${NC}"

# Install dependencies
echo -e "${YELLOW}[2/3]${NC} 📦 Installing dependencies..."
flutter pub get --quiet
echo -e "  ${GREEN}✅ Dependencies ready${NC}"

# Run integration tests
echo -e "${YELLOW}[3/3]${NC} 🧪 Running integration tests..."
echo ""

flutter test integration_test/app_test.dart \
  --timeout 300s \
  --reporter expanded

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Integration tests passed!             ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
