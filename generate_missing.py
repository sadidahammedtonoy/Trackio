import json
import os
import re

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

existing_bn_keys = set()
with open('lib/App/translations.dart', 'r', encoding='utf-8') as file:
    content = file.read()
    bn_bd_section = content.split("'bn_BD':")[1]
    key_val_pattern = re.compile(r'^\s*[\'\"](.*?)[\'\"]\s*:', re.MULTILINE)
    bn_matches = key_val_pattern.findall(bn_bd_section)
    for k in bn_matches:
        existing_bn_keys.add(k)

missing_keys = found_keys - existing_bn_keys
# remove empty strings
missing_keys = {k for k in missing_keys if k.strip()}

with open('missing.json', 'w', encoding='utf-8') as f:
    json.dump(sorted(list(missing_keys)), f, ensure_ascii=False, indent=2)

print(f'Wrote {len(missing_keys)} missing keys to missing.json')
