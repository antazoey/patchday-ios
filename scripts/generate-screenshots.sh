#!/usr/bin/env bash
#
# generate-screenshots.sh
#
# Builds PatchDay against a set of simulator destinations, sets each
# simulator's UI appearance, runs the ScreenshotTests XCUI suite (which
# attaches screenshots to its result bundle), then extracts the PNGs and
# names them by device + appearance + screen.
#
# Output:
#   screenshots/<device-slug>/<appearance>/<NN-Screen>.png
#
# Requirements:
#   - Xcode + simulators for the device names listed below
#   - macOS / zsh / bash
#
# Usage:
#   ./scripts/generate-screenshots.sh
#

set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="PatchDay.xcodeproj"
SCHEME="Tests"
OUTPUT_DIR="screenshots"
BUNDLES_DIR="$OUTPUT_DIR/.bundles"

# Devices to capture. Add / remove as needed. App Store typically wants:
#   - one 6.7"+ iPhone (iPhone 17 Pro Max)
#   - one iPad Pro 12.9"+ (iPad Pro 13-inch (M4))
DEVICES=(
    "iPhone 17 Pro Max"
    "iPhone 17"
    "iPad Pro 13-inch (M4)"
)

APPEARANCES=(light dark)

# Reset output.
rm -rf "$OUTPUT_DIR"
mkdir -p "$BUNDLES_DIR"

resolve_udid() {
    local name="$1"
    xcrun simctl list devices available -j 2>/dev/null \
        | python3 -c "
import sys, json
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    for d in devices:
        if d.get('isAvailable') and d.get('name') == '$name':
            print(d['udid'])
            sys.exit(0)
"
}

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed -E 's/^-+|-+$//g; s/-+/-/g'
}

for device in "${DEVICES[@]}"; do
    udid="$(resolve_udid "$device" || true)"
    if [ -z "$udid" ]; then
        echo "⚠️  Skipping '$device' — not installed in this Xcode."
        continue
    fi

    device_slug="$(slugify "$device")"

    for appearance in "${APPEARANCES[@]}"; do
        echo ""
        echo "▶︎ $device / $appearance ($udid)"

        # Boot + set appearance. Don't crash if it's already booted.
        xcrun simctl boot "$udid" >/dev/null 2>&1 || true
        xcrun simctl ui "$udid" appearance "$appearance"

        bundle="$BUNDLES_DIR/$device_slug-$appearance.xcresult"
        rm -rf "$bundle"

        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "platform=iOS Simulator,id=$udid" \
            -only-testing:PatchDayUITests/ScreenshotTests \
            -resultBundlePath "$bundle" \
            test \
            -quiet \
            > "$BUNDLES_DIR/$device_slug-$appearance.log" 2>&1 \
            || {
                echo "❌ xcodebuild failed for $device / $appearance"
                tail -20 "$BUNDLES_DIR/$device_slug-$appearance.log"
                continue
            }

        # Extract every screenshot attachment from the result bundle.
        out_dir="$OUTPUT_DIR/$device_slug/$appearance"
        mkdir -p "$out_dir"

        # Each XCTAttachment is stored inside the bundle's Attachments
        # directory. Names are hashes; the attachment metadata sits in
        # ActionsInvocationRecord but is awkward to walk with shell tools.
        # Easier: pull the metadata via xcresulttool, map filename → name.
        xcrun xcresulttool get --legacy --path "$bundle" --format json 2>/dev/null \
            | python3 -c "
import sys, json, shutil, pathlib
data = json.load(sys.stdin)
out = pathlib.Path('$out_dir')
bundle = pathlib.Path('$bundle')

# Walk the test summary structure looking for attachment payloads.
def walk(node):
    if isinstance(node, dict):
        if node.get('_type', {}).get('_name') == 'ActionTestAttachment':
            name = node.get('name', {}).get('_value', 'unnamed')
            ref = node.get('payloadRef', {}).get('id', {}).get('_value')
            if ref:
                src = bundle / 'Data' / ref
                if src.exists():
                    safe = name.replace('/', '-')
                    shutil.copy(src, out / (safe + '.png'))
        for v in node.values():
            walk(v)
    elif isinstance(node, list):
        for v in node:
            walk(v)

walk(data)
print(f'  ↳ extracted to {out}')
"
    done
done

# Tidy: drop the .bundles staging dir but keep .log files visible if any
# tests failed (so the user can debug).
if find "$BUNDLES_DIR" -name '*.log' -size +0 | grep -q .; then
    echo ""
    echo "ℹ️  Logs preserved in $BUNDLES_DIR"
else
    rm -rf "$BUNDLES_DIR"
fi

echo ""
echo "✅ Done. Screenshots in ./$OUTPUT_DIR/"
