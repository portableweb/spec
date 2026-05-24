#!/usr/bin/env bash
#
# build-pweb.sh — package a source directory into a valid .pweb bundle.
#
# Usage: ./build-pweb.sh <source-dir> <output.pweb>
#
# This script enforces the PortableWeb container layout:
#   - The `mimetype` file is the first entry in the ZIP.
#   - The `mimetype` file is STORED (uncompressed) with no extra fields.
#   - All other files use normal DEFLATE compression.
#
# This is the same convention used by EPUB, and allows tools to identify
# a bundle by reading just the first ~80 bytes of the file.
#
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source-dir> <output.pweb>"
  exit 1
fi

SRC_DIR="$1"
OUT_FILE="$2"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: source directory '$SRC_DIR' does not exist." >&2
  exit 1
fi

if [ ! -f "$SRC_DIR/mimetype" ]; then
  echo "Error: '$SRC_DIR/mimetype' is missing. A PortableWeb bundle must contain a mimetype file." >&2
  exit 1
fi

EXPECTED_MIMETYPE="application/vnd.portableweb+zip"
ACTUAL_MIMETYPE="$(cat "$SRC_DIR/mimetype")"
if [ "$ACTUAL_MIMETYPE" != "$EXPECTED_MIMETYPE" ]; then
  echo "Error: '$SRC_DIR/mimetype' must contain exactly: $EXPECTED_MIMETYPE" >&2
  echo "       (found: '$ACTUAL_MIMETYPE')" >&2
  exit 1
fi

if [ ! -f "$SRC_DIR/manifest.json" ]; then
  echo "Error: '$SRC_DIR/manifest.json' is missing." >&2
  exit 1
fi

# Resolve OUT_FILE to an absolute path so the cd below doesn't break it.
case "$OUT_FILE" in
  /*) ABS_OUT="$OUT_FILE" ;;
  *)  ABS_OUT="$PWD/$OUT_FILE" ;;
esac

# Remove existing output file if present.
rm -f "$ABS_OUT"

# Step 1: add `mimetype` as the FIRST entry, STORED (uncompressed),
# with no extra fields. The -X flag strips extra metadata.
( cd "$SRC_DIR" && zip -X0 "$ABS_OUT" mimetype >/dev/null )

# Step 2: add every other file with normal compression.
# -r recurses, -9 max compression, -X strips extra metadata,
# -D omits directory entries (smaller, cleaner archives).
( cd "$SRC_DIR" && zip -Xr9D "$ABS_OUT" . -x mimetype >/dev/null )

# Quick sanity check: verify the first entry is `mimetype`, uncompressed.
FIRST_ENTRY="$(unzip -lqq "$ABS_OUT" | awk 'NR==1 {print $NF}')"
if [ "$FIRST_ENTRY" != "mimetype" ]; then
  echo "Error: bundle build produced an invalid layout (first entry is '$FIRST_ENTRY', expected 'mimetype')." >&2
  exit 1
fi

echo "Built: $ABS_OUT"
echo "  Size:        $(wc -c < "$ABS_OUT") bytes"
echo "  First entry: $FIRST_ENTRY (uncompressed)"
echo "  Total files: $(unzip -lqq "$ABS_OUT" | wc -l | tr -d ' ')"
