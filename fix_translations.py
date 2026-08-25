import re

with open('lib/App/translations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    # If it's one of those weird string interpolation mistakes, skip it
    if '${"' in line or '${item' in line or 'Failed\\", e.message ?? \\"Could not send' in line:
        continue
    
    # Also escape unescaped '$' if it's inside a string value (only if needed)
    # Actually, we can just replace unescaped '$' with '\$'
    if '$' in line and '\\$' not in line:
        line = line.replace('$', '\\$')
        
    # Also fix 'Failed", e.message' thing which is a parsing artifact
    
    new_lines.append(line)

# Let's also check for unterminated string literals caused by newline characters in the regex matches
# A regex match might have grabbed a newline.
# If a line doesn't end with ',' (ignoring trailing whitespace) and it's inside the map, we need to fix it.
# Actually, the map lines should end with `',` or `},` or just `,`
# Let's do a more robust fix by using regex to find and replace unescaped $

with open('lib/App/translations.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
