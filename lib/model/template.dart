import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Template {
  final String _text;
  final String _name;
  static final RegExp _fieldPattern = RegExp(r'\/(\w+)');

  Template(this._name, this._text) {
    if (_name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (_text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final text = json['text'] as String?;
    if (name == null || text == null) {
      throw FormatException('Invalid JSON: missing name or text');
    }
    return Template(name, text);
  }

  Map<String, dynamic> toJson() {
    return {'name': _name, 'text': _text};
  }

  String get name => _name;

  /// Extracts the unique field names from the template text.
  /// Fields are identified by the pattern '/word'.
  List<String> getFields() {
    final matches = _fieldPattern.allMatches(_text);
    final fields = matches.map((m) => m.group(1)!).toSet().toList();
    debugPrint('Extracted fields: $fields');
    return fields;
  }

  /// Replaces the fields in the template text with the provided values.
  /// If a field is not found in the values map, it is left unchanged.
  String replaceFields(Map<String, String> values) {
    final output = _text.replaceAllMapped(_fieldPattern, (match) {
      final key = match.group(1)!;
      if (!values.containsKey(key)) {
        debugPrint('Missing value for key: $key');
        return match.group(0)!; // Fallback to original
      }
      return values[key]!;
    });
    debugPrint('Replaced text: $output');
    return output;
  }
}
