#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DORADO_BIN="$REPO_DIR/dorado-1.4.0-osx-arm64/bin/dorado"

MODEL_SUP="$REPO_DIR/dorado-1.4.0-osx-arm64/bin/dna_r10.4.1_e8.2_400bps_sup@v5.2.0"
MODEL_MOD="$REPO_DIR/dorado-1.4.0-osx-arm64/bin/dna_r10.4.1_e8.2_400bps_sup@v5.2.0_5mC_5hmC@v1"

RAW_DIR="$REPO_DIR/data/raw/pod5"
OUT_BASE="$REPO_DIR/data/processed/dorado"
REF="$REPO_DIR/data/ref/hs1pct.fa"

mkdir -p "$OUT_BASE"

# ----------------------------
# AUTO GPU / CPU DETECTION
# ----------------------------
DEVICE="auto"

# macOS Metal check (simple + reliable heuristic)
if system_profiler SPDisplaysDataType 2>/dev/null | grep -qi "Metal"; then
    DEVICE="auto"   # Dorado will pick metal internally
else
    DEVICE="cpu"
fi

echo "Using device: $DEVICE"

# ----------------------------
# FULL RUN (all barcodes)
# ----------------------------
for file in "$RAW_DIR"/barcode*_filtered.pod5; do
    barcode=$(basename "$file" | cut -d'_' -f1)
    outdir="$OUT_BASE/$barcode"

    if [[ -e "$outdir" ]]; then
        echo "Skipping $barcode: output already exists at $outdir"
        continue
    fi

    mkdir -p "$outdir"

    echo "Processing $barcode..."

    "$DORADO_BIN" basecaller \
        "$MODEL_SUP" \
        "$file" \
        -x "$DEVICE" \
        --modified-bases-models "$MODEL_MOD" \
        --reference "$REF" \
        --emit-moves \
        --output-dir "$outdir"

    echo "$barcode done."
done


# # ----------------------------
# # SANITY CHECK (barcode01 only)
# # ----------------------------
# SANITY_FILE="$RAW_DIR/barcode01_filtered.pod5"
# SANITY_OUT="$OUT_BASE/barcode01_sanity"

# mkdir -p "$SANITY_OUT"

# echo "Running SANITY CHECK: barcode01"

# "$DORADO_BIN" basecaller \
#     "$MODEL_SUP" \
#     "$SANITY_FILE" \
#     -x "$DEVICE" \
#     --modified-bases-models "$MODEL_MOD" \
#     --reference "$REF" \
#     --emit-moves \
#     --output-dir "$SANITY_OUT"

# echo "Sanity done: barcode01"
