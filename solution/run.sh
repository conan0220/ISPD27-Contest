#!/usr/bin/env bash
# I/O-only version: copy the supplied design without optimization.
# The evaluator rejects unchanged baseline submissions.
set -euo pipefail

if [[ $# -ne 4 ]]; then
    echo "Usage: $0 <input_dir> <platform_dir> <output_dir> <top_module>" >&2
    exit 2
fi

input_dir=$1
platform_dir=$2
output_dir=$3
top_module=$4

if [[ ! -d "$input_dir" || ! -d "$platform_dir" ]]; then
    echo "Error: input_dir and platform_dir must be existing directories." >&2
    exit 2
fi
if [[ -z "$output_dir" || -z "$top_module" ]]; then
    echo "Error: output_dir and top_module must not be empty." >&2
    exit 2
fi

# Output names use the design name, not the top-module name.
design_name=$(basename "$input_dir")
input_def=${INPUT_DEF:-"$input_dir/input.def"}
input_verilog=${INPUT_VERILOG:-"$input_dir/input.v"}
output_def=${OUTPUT_DEF:-"$output_dir/$design_name.def"}
output_verilog=${OUTPUT_VERILOG:-"$output_dir/$design_name.v"}

for input_file in "$input_def" "$input_verilog"; do
    if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
        echo "Error: cannot read input file: $input_file" >&2
        exit 2
    fi
done

# Platform files and the top module are reserved for future optimization.
mkdir -p "$output_dir" "$(dirname "$output_def")" "$(dirname "$output_verilog")"
cp "$input_def" "$output_def"
cp "$input_verilog" "$output_verilog"
