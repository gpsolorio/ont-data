#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input.bam> <output.txt>"
  exit 1
fi

INPUT_BAM=$1
OUTPUT_TXT=$2

samtools view "$INPUT_BAM" | cut -f1 > "$OUTPUT_TXT"
