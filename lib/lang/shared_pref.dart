import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static String? lang;
  static int? themeClr;

  static Future<void> addLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', lang);
  }

  static Future<String?> getLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }
}
