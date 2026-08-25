import os
import re

# Find all translation keys in the codebase
tr_pattern = re.compile(r'(["\'])(.*?)\1\.tr\b')
found_keys = set()

for root, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            with open(os.path.join(root, f), 'r', encoding='utf-8') as file:
                content = file.read()
                matches = tr_pattern.findall(content)
                for match in matches:
                    found_keys.add(match[1])

# Extract existing keys from translations.dart
existing_bn_keys = set()
try:
    with open('lib/App/translations.dart', 'r', encoding='utf-8') as file:
        content = file.read()
        
        # very simple extraction for bn_BD section
        bn_bd_section = content.split("'bn_BD':")[1]
        
        # find all keys in this section
        # looking for 'key': 'value'
        key_val_pattern = re.compile(r'^\s*[\'"](.*?)[\'"]\s*:', re.MULTILINE)
        bn_matches = key_val_pattern.findall(bn_bd_section)
        
        for k in bn_matches:
            existing_bn_keys.add(k)
except Exception as e:
    print("Error reading translations.dart:", e)

missing_keys = found_keys - existing_bn_keys

print(f"Total keys found in code: {len(found_keys)}")
print(f"Total keys in BN translation: {len(existing_bn_keys)}")
print(f"Missing keys ({len(missing_keys)}):")
for k in sorted(missing_keys):
    if k.strip():
        print(f"'{k}'")
