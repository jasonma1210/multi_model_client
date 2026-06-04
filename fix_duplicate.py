#!/usr/bin/env python3
"""Fix duplicate _ThinkTagPatterns and _cleanThinkTags in local_ffi_engine.dart"""

filepath = 'lib/core/engines/local_ffi_engine.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find the first occurrence of "return cleaned.trim();" after "_cleanThinkTags"
# This marks the end of the new V76 _cleanThinkTags function
first_clean_end_line = None
for i, line in enumerate(lines):
    if 'return cleaned.trim();' in line and first_clean_end_line is None:
        # The next line should be just "}"
        first_clean_end_line = i + 1  # 0-indexed, this is the "}" line
        break

if first_clean_end_line is None:
    print("ERROR: Could not find first _cleanThinkTags end")
    exit(1)

print(f"First _cleanThinkTags ends at line {first_clean_end_line + 1}")

# Find the LocalFFIEngine class
local_ffi_start_line = None
for i, line in enumerate(lines):
    if 'class LocalFFIEngine {' in line:
        # Go back to find the doc comment
        for j in range(i - 1, max(0, i - 10), -1):
            if lines[j].strip().startswith('/// 本地 FFI'):
                local_ffi_start_line = j
                break
        if local_ffi_start_line is None:
            local_ffi_start_line = i
        break

if local_ffi_start_line is None:
    print("ERROR: Could not find LocalFFIEngine class")
    exit(1)

print(f"LocalFFIEngine class starts at line {local_ffi_start_line + 1}")

# Remove everything between first_clean_end_line+1 and local_ffi_start_line
# (this is the duplicate content)
new_lines = lines[:first_clean_end_line + 1] + ['\n'] + lines[local_ffi_start_line:]

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"Removed {local_ffi_start_line - first_clean_end_line - 1} lines of duplicate content")
print("File fixed successfully")
