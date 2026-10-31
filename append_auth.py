import re

en_add = {
    'Error': 'Error',
    'Login Failed': 'Login Failed',
    'An unexpected error occurred.': 'An unexpected error occurred.',
    'Google Sign-In Failed: ': 'Google Sign-In Failed: ',
    'Apple Sign-In Failed: ': 'Apple Sign-In Failed: ',
    'Guest login failed.': 'Guest login failed.',
    'Not supported': 'Not supported',
    'Failed': 'Failed',
}

bn_add = {
    'Error': 'ত্রুটি',
    'Login Failed': 'লগইন ব্যর্থ হয়েছে',
    'An unexpected error occurred.': 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে।',
    'Google Sign-In Failed: ': 'গুগল সাইন-ইন ব্যর্থ হয়েছে: ',
    'Apple Sign-In Failed: ': 'অ্যাপল সাইন-ইন ব্যর্থ হয়েছে: ',
    'Guest login failed.': 'গেস্ট লগইন ব্যর্থ হয়েছে।',
    'Not supported': 'সমর্থিত নয়',
    'Failed': 'ব্যর্থ',
}

with open('lib/App/translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add to en_US
en_insert = ""
for k, v in en_add.items():
    if f"'{k}':" not in content:
        en_insert += f"      '{k}': '{v}',\n"

# Add to bn_BD
bn_insert = ""
for k, v in bn_add.items():
    if f"'{k}':" not in content:
        bn_insert += f"      '{k}': '{v}',\n"

content = content.replace("'en_US': {", "'en_US': {\n" + en_insert)
content = content.replace("'bn_BD': {", "'bn_BD': {\n" + bn_insert)

with open('lib/App/translations.dart', 'w', encoding='utf-8') as f:
    f.write(content)

