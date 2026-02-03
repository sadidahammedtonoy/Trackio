import 'package:get/get.dart';

class numberTranslation {

  /// 🔎 check current language
  static bool get _isBangla =>
      Get.locale?.languageCode == 'bn';

  /// ✅ digits only (safe for numbers)
  static String toBnDigits(String input) {
    if (!_isBangla) return input;

    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];

    var out = input;
    for (int i = 0; i < 10; i++) {
      out = out.replaceAll(en[i], bn[i]);
    }
    return out;
  }

  /// ✅ Date string → Bangla ONLY if language is Bangla
  /// Input example: "03 Feb 2026"
  static String formatDateBnFromString(String input) {
    if (!_isBangla) return input; // 👈 English 그대로 ফেরত

    const monthMap = {
      'Jan': 'জানুয়ারি',
      'Feb': 'ফেব্রুয়ারি',
      'Mar': 'মার্চ',
      'Apr': 'এপ্রিল',
      'May': 'মে',
      'Jun': 'জুন',
      'Jul': 'জুলাই',
      'Aug': 'আগস্ট',
      'Sep': 'সেপ্টেম্বর',
      'Oct': 'অক্টোবর',
      'Nov': 'নভেম্বর',
      'Dec': 'ডিসেম্বর',
    };

    final parts = input.split(' '); // dd MMM yyyy
    if (parts.length != 3) return input;

    final day = toBnDigits(parts[0]);
    final month = monthMap[parts[1]] ?? parts[1];
    final year = toBnDigits(parts[2]);

    return "$day $month $year";
  }
}
