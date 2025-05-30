import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Template {
  final String _text;
  final String _name;

  Template(this._name, this._text);

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(json['name'] as String, json['text'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': _name, 'text': _text};
  }

  String get name => _name;

  List<String> getField() {
    final pattern = RegExp(r'\/(\w+)');
    final matches = pattern.allMatches(_text);
    debugPrint(matches.map((m) => m.group(1)!).toSet().toList().toString());
    return matches.map((m) => m.group(1)!).toSet().toList();
  }

  String replaceField(Map<String, String> value) {
    final pattern = RegExp(r'\/(\w+)');

    final output = _text.replaceAllMapped(pattern, (match) {
      final key = match.group(1)!;
      return value[key]!;
    });

    debugPrint("Texto remplazado es:\n$output");

    return output;
  }
}
