import 'package:flutter/material.dart';

class CreateTemplate extends StatelessWidget {
  const CreateTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    Size size = MediaQuery.sizeOf(context);
    TextEditingController textController = TextEditingController();

    var explainText = Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSecondaryContainer,
            offset: Offset(6, 6),
            blurRadius: 3,
          ),
        ],
        color: colorScheme.secondaryContainer,
        border: Border.all(
          color: colorScheme.secondaryContainer,
          width: 3,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: size.width * 0.95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            "Este es un ejemplo de cómo crear tu plantilla personalizada:",
            style: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          Text(
            """   - "Hola, buenas tardes señor /nombre" """,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: colorScheme.secondary,
            ),
          ),
          Text(
            """La palabra que aparece después de la barra (/) representa un campo editable que puedes personalizar.""",
            style: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: colorScheme.onSurfaceVariant,
        title: Text("Create Template"),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            explainText,
            SizedBox(
              width: size.width * 0.95,
              child: TextField(
                controller: textController,
                autofocus: true,
                style: TextStyle(),
                keyboardType: TextInputType.text,
                minLines: 12,
                maxLines: 100,
                showCursor: true,
                decoration: InputDecoration(
                  focusColor: colorScheme.surfaceDim,
                  labelText: "Template",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
