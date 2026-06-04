#!/usr/bin/env python3
"""Remove the residual line with special characters"""

filepath = 'lib/core/engines/local_ffi_engine.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find and remove lines that contain the residual special characters
# These are lines between the _cleanThinkTags function end and LocalFFIEngine class
new_lines = []
skip = False
for i, line in enumerate(lines):
    # Check for the residual line with special Unicode characters
    # It's the line after "return cleaned.trim();\n}"
    if i > 0 and 'return cleaned.trim();' in lines[i-1] if i > 0 else False:
        # This line might be the residual
        if '块' in line or '非贪婪' in line or line.strip().startswith('}') and 'think' in line.lower():
            # Skip this line
            continue
    # Also check for standalone lines with just special chars
    stripped = line.strip()
    if stripped and all(ord(c) > 127 or c in '()（）' for c in stripped if not c.isspace()):
        # This line only contains non-ASCII characters - likely residual
        # But be careful not to remove legitimate Chinese comments
        if '非贪婪' in stripped or '块' in stripped:
            continue
    new_lines.append(line)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"Removed {len(lines) - len(new_lines)} residual lines")
