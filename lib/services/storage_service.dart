import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  // Integer operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  // String list operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  // Remove and clear operations
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
