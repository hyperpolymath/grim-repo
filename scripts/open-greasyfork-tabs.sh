#!/bin/bash
# SPDX-License-Identifier: MPL-2.0
# Opens GreasyFork upload pages for all 6 scripts

echo "Opening GreasyFork upload tabs..."
echo "Follow UPLOAD_GUIDE.md for each tab"
echo ""

# Open 6 tabs for new script uploads
for i in {1..6}; do
  xdg-open "https://greasyfork.org/en/scripts/new" 2>/dev/null || \
  open "https://greasyfork.org/en/scripts/new" 2>/dev/null || \
  echo "Please open: https://greasyfork.org/en/scripts/new"
  sleep 1
done

echo ""
echo "✓ Opened 6 tabs for script uploads"
echo ""
echo "Upload order:"
echo "1. GrimGreaser"
echo "2. GrimPager"
echo "3. GrimTemplateEngine"
echo "4. GrimLicenseChecker"
echo "5. GrimCIValidator"
echo "6. GrimSecurityScanner"
echo ""
echo "See UPLOAD_GUIDE.md for copy-paste ready descriptions and tags!"
