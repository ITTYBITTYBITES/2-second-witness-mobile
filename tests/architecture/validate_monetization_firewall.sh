#!/bin/bash
echo "=== Running Monetization Firewall Audit ==="
echo ""
echo "Searching for isolated keywords (ad, premium, store, monetize) outside allowed boundaries..."

# Expected allowed locations
ALLOWED="ScenarioNode.gd\|MonetizationUI"

# Find all GDScripts, run grep, ignore the allowed ones
grep -rnwi 'ad\|premium\|store\|monetize' LiquidMemory_V2/scripts/ | grep -v "$ALLOWED"

if [ $? -eq 0 ]; then
  echo ""
  echo "WARNING: Firewall breached! Found monetization keywords outside allowed domains."
  exit 1
else
  echo ""
  echo "SUCCESS: Monetization firewall intact. No logic leakage detected."
  exit 0
fi
