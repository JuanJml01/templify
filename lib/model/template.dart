import 'package:flutter/widgets.dart';

class Template {
  final String _text;

  Template(this._text);
  
  List<String> getField()
  {
    final pattern = RegExp(r'\/(\w+)');
    final matches = pattern.allMatches(_text);
    debugPrint(matches.map((m)=>m.group(1)!).toSet().toList().toString());
    return matches.map((m)=>m.group(1)!).toSet().toList();
  }

  String replaceField(Map<String,String> value){

    final pattern = RegExp(r'\/(\w+)');

    final output = _text.replaceAllMapped(pattern, (match){
      final key = match.group(1)!;
      return value[key]!;
    });

    debugPrint("Texto remplazado es:\n$output");

    return output;
  }
}