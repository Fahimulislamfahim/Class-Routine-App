import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine_model.dart';

class StorageService {
  static const String _keyApiKey = 'diu_routine_gemini_api_key';
  static const String _keySelectedModel = 'diu_routine_gemini_model';
  static const String _keySavedRoutine = 'diu_routine_saved_data';
  static const String _keySubgroupFilter = 'diu_routine_subgroup_filter';
  static const String _keyIsDarkMode = 'diu_routine_dark_mode';

  /// Save API Key
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, apiKey.trim());
  }

  /// Get API Key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey);
  }

  /// Save Selected Model
  static Future<void> saveModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedModel, model);
  }

  /// Get Selected Model
  static Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedModel) ?? 'gemini-2.5-flash';
  }

  /// Save Active Routine
  static Future<void> saveRoutine(RoutineModel routine) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(routine.toJson());
    await prefs.setString(_keySavedRoutine, jsonStr);
  }

  /// Load Saved Routine
  static Future<RoutineModel?> loadSavedRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySavedRoutine);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return RoutineModel.fromJson(decoded);
      } catch (_) {}
    }
    return null;
  }

  /// Save Filter
  static Future<void> saveSubgroupFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubgroupFilter, filter);
  }

  /// Get Filter
  static Future<String> getSubgroupFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySubgroupFilter) ?? 'ALL';
  }

  /// Save Dark Mode
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  /// Get Dark Mode
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }
}
