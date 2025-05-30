import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templify/model/template.dart';

/// Abstract class defining the contract for storage operations.
abstract class StorageProvider {
  /// Retrieves a list of strings from storage by key.
  Future<List<String>?> getStringList(String key);

  /// Saves a list of strings to storage under the specified key.
  Future<void> setStringList(String key, List<String> value);

  /// Retrieves a string from storage by key.
  Future<String?> getString(String key);

  /// Saves a string to storage under the specified key.
  Future<void> setString(String key, String value);
}

/// Implementation of [StorageProvider] using SharedPreferences.
class SharedPreferencesStorageProvider implements StorageProvider {
  final SharedPreferences _prefs;

  SharedPreferencesStorageProvider(this._prefs);

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
}

class User {
  List<Template> _templates = [];
  String _apiGeminis = '';
  StorageProvider? _storageProvider;

  User._();

  static final User instance = User._();

  List<Template> get templates => List.unmodifiable(_templates);

  String get apiGeminis => _apiGeminis;

  void setStorageProvider(StorageProvider provider) {
    _storageProvider = provider;
  }

  Future<void> loadFromStorage() async {
    if (_storageProvider == null) {
      debugPrint('[ERROR] Storage provider not set');
      return;
    }
    debugPrint('[INFO] Loading templates from storage');
    final List<String>? jsonList = await _storageProvider!.getStringList(
      'templates',
    );
    if (jsonList != null) {
      _templates =
          jsonList
              .map<Template?>((element) {
                try {
                  final Map<String, dynamic> map =
                      jsonDecode(element) as Map<String, dynamic>;
                  return Template.fromJson(map);
                } catch (e) {
                  debugPrint('[ERROR] Failed to decode template JSON: $e');
                  return null;
                }
              })
              .where((element) => element != null)
              .cast<Template>()
              .toList();
    } else {
      _templates = [];
    }
    _apiGeminis = await _storageProvider!.getString('apiGeminis') ?? '';
  }

  Future<void> saveTemplates() async {
    if (_storageProvider == null) {
      debugPrint('[ERROR] Storage provider not set');
      return;
    }
    debugPrint('[INFO] Saving templates to storage');
    final List<String> jsonList =
        _templates.map((element) => jsonEncode(element.toJson())).toList();
    try {
      await _storageProvider!.setStringList('templates', jsonList);
    } catch (e) {
      debugPrint('[ERROR] Failed to save templates: $e');
    }
  }

  Future<void> saveSettings() async {
    if (_storageProvider == null) {
      debugPrint('[ERROR] Storage provider not set');
      return;
    }
    debugPrint('[INFO] Saving settings to storage');
    try {
      await _storageProvider!.setString('apiGeminis', _apiGeminis);
    } catch (e) {
      debugPrint('[ERROR] Failed to save settings: $e');
    }
  }

  void addTemplate(Template t) {
    debugPrint('[INFO] Adding template: ${t.name}');
    _templates.add(t);
  }

  void removeTemplate(Template t) {
    debugPrint('[INFO] Removing template: ${t.name}');
    _templates.remove(t);
  }

  set apiGeminis(String v) {
    debugPrint('[INFO] Setting apiGeminis to $v');
    _apiGeminis = v;
  }
}
