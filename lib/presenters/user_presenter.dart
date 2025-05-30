import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templify/model/template.dart';
import 'package:templify/model/user.dart';

/// Manages user-related presentation logic: initialization, template operations, and settings.
class UserPresenter extends ChangeNotifier {
  final UserRepository _repository;

  /// Creates a [UserPresenter] with an optional [repository] for dependency injection.
  UserPresenter({UserRepository? repository})
    : _repository = repository ?? SharedPreferencesUserRepository();

  List<Template> get templates => _repository.getTemplates();

  String get apiGeminis => _repository.getApiKey();

  /// Initializes the presenter by loading user data from storage.
  Future<void> initialize() async {
    _logInfo('Initializing user presenter');
    try {
      await _repository.init();
      _logInfo('Initialization complete');
      notifyListeners();
    } catch (e, stack) {
      _logError('Initialization failed', e, stack);
    }
  }

  Future<void> addTemplate(Template template) async {
    _logInfo('Adding template: ${template.name}');
    try {
      _repository.addTemplate(template);
      await _repository.saveTemplates();
      notifyListeners();
    } catch (e, stack) {
      _logError('Failed to add template', e, stack);
    }
  }

  Future<void> removeTemplate(Template template) async {
    _logInfo('Removing template: ${template.name}');
    try {
      _repository.removeTemplate(template);
      await _repository.saveTemplates();
      notifyListeners();
    } catch (e, stack) {
      _logError('Failed to remove template', e, stack);
    }
  }

  Future<void> setApiGeminis(String apiKey) async {
    if (apiKey.isEmpty) {
      _logWarning('Empty API key provided');
      return;
    }
    _logInfo('Updating API key');
    try {
      _repository.setApiKey(apiKey);
      await _repository.saveSettings();
      notifyListeners();
    } catch (e, stack) {
      _logError('Failed to set API key', e, stack);
    }
  }

  // ------------------
  // Logging helpers
  void _logInfo(String message) => debugPrint('[INFO] UserPresenter: $message');
  void _logWarning(String message) =>
      debugPrint('[WARN] UserPresenter: $message');
  void _logError(String message, Object error, StackTrace stack) {
    debugPrint('[ERROR] UserPresenter: $message - $error');
    debugPrint(stack.toString());
  }
}

/// Defines data operations needed by [UserPresenter].
abstract class UserRepository {
  Future<void> init();
  List<Template> getTemplates();
  Future<void> saveTemplates();
  Future<void> saveSettings();
  void addTemplate(Template template);
  void removeTemplate(Template template);
  String getApiKey();
  void setApiKey(String apiKey);
}

/// [UserRepository] implementation using [SharedPreferences].
class SharedPreferencesUserRepository implements UserRepository {
  final User _user = User.instance;
  SharedPreferencesStorageProvider? _provider;

  @override
  Future<void> init() async {
    debugPrint('[INFO] UserRepository: Initializing storage');
    final prefs = await SharedPreferences.getInstance();
    _provider = SharedPreferencesStorageProvider(prefs);
    _user.setStorageProvider(_provider!);
    await _user.loadFromStorage();
  }

  @override
  List<Template> getTemplates() => _user.templates;

  @override
  Future<void> saveTemplates() => _user.saveTemplates();

  @override
  Future<void> saveSettings() => _user.saveSettings();

  @override
  void addTemplate(Template template) => _user.addTemplate(template);

  @override
  void removeTemplate(Template template) => _user.removeTemplate(template);

  @override
  String getApiKey() => _user.apiGeminis;

  @override
  void setApiKey(String apiKey) => _user.apiGeminis = apiKey;
}
