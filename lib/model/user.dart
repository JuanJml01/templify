import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:templify/model/template.dart';

class User {
  List<Template> _templates = [];
  String _apiGeminis = '';

  User._();

  static final User instance = User._();

  List<Template> get templates => List.unmodifiable(_templates);
  String get apiGeminis => _apiGeminis;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> jsoList = prefs.getStringList('templates') ?? [];

    _templates =
        jsoList.map<Template>((element) {
          final Map<String, dynamic> map =
              jsonDecode(element) as Map<String, dynamic>;
          return Template.fromJson(map);
        }).toList();

    _apiGeminis = prefs.getString("apiGeminis") ?? '';
  }

  Future<void> saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> jsonList =
        _templates.map((elemnt) => jsonEncode(elemnt.toJson())).toList();

    await prefs.setStringList('template', jsonList);
  }

  void addTemplate(Template t) => _templates.add(t);

  void removeTemplate(Template t) => _templates.remove(t);

  set apiGeminis(String v) => _apiGeminis = v;
}
