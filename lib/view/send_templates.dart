import 'package:flutter/material.dart';
import 'package:templify/model/template.dart';

class SendTemplates extends StatefulWidget {
  const SendTemplates({super.key});

  @override
  State<SendTemplates> createState() => _SendTemplatesState();
}

class _SendTemplatesState extends State<SendTemplates> {
  @override
  Widget build(BuildContext context) {
    final template = ModalRoute.of(context)!.settings.arguments as Template;
    
    debugPrint("El template: ${template.name}");
    return const Placeholder();
  }
}