#!/bin/bash

# Yabai Window Navigation Debugger
# Shows why window navigation might not be working as expected

echo "========================================="
echo "     YABAI WINDOW NAVIGATION DEBUG      "
echo "========================================="
echo ""

# Get current window
CURRENT_WINDOW=$(yabai -m query --windows --window | jq -r '.id')
echo "📍 Current Window ID: $CURRENT_WINDOW"
yabai -m query --windows --window | jq -r '"   App: \(.app)\n   Title: \(.title)"'
echo ""

# Check what windows are reachable
echo "🧭 Testing Navigation Directions:"
echo "---------------------------------"

# Test each direction
for dir in west east north south; do
    echo -n "  $dir: "
    result=$(yabai -m query --windows --window $dir 2>&1)
    if [[ $? -eq 0 ]]; then
        echo "✅ $(echo $result | jq -r '"\(.app) - \(.title[0:30])..."')"
    else
        echo "❌ No window found"
    fi
done

echo ""
echo "📊 Window Distribution:"
echo "----------------------"
yabai -m query --windows --space | jq -r '
    [.[] | select(."is-floating" == false)] | 
    "  Total tiled windows: \(length)"'

echo ""
echo "🌳 Window Tree Depth Analysis:"
echo "------------------------------"
echo "  Windows with direct navigation paths:"
yabai -m query --windows --space | jq -r '
    [.[] | select(."split-type" != "none" and ."is-floating" == false)] | 
    .[] | "    - \(.app): \(.title[0:30])..."' | head -10

echo ""
echo "💡 Suggestions:"
echo "--------------"
WINDOW_COUNT=$(yabai -m query --windows --space | jq '[.[] | select(."is-floating" == false)] | length')

if [ $WINDOW_COUNT -gt 6 ]; then
    echo "  ⚠️  You have $WINDOW_COUNT tiled windows in one space!"
    echo "  This creates a complex tree structure."
    echo ""
    echo "  Try one of these solutions:"
    echo "  1. Move some windows to other spaces (Shift+Option+1-9)"
    echo "  2. Float some windows (Shift+Option+Space)"
    echo "  3. Close unnecessary windows"
    echo "  4. Use Option+Tab to cycle through all windows"
fi

echo ""
echo "🔧 Quick Actions:"
echo "----------------"
echo "  • Balance windows: yabai -m space --balance"
echo "  • Toggle float: yabai -m window --toggle float"
echo "  • Create new space: yabai -m space --create"
echo "  • Move to space 2: yabai -m window --space 2"