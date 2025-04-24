import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _keyUID = 'UID';

  static Future<void> saveUID(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUID, uid);
  }

  static Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUID);
  }

  static Future<void> clearUID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUID);
  }
}
