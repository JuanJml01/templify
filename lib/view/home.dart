import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.sizeOf(context);

    var buttonMaketemplate = TextButton(
      onPressed:
          () => debugPrint(
            "Altura: ${screen.height} y Anchura: ${screen.height}",
          ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(
          Theme.of(context).colorScheme.secondary,
        ),
        minimumSize: WidgetStatePropertyAll<Size>(
          Size(
            screen.width * 0.8,
            screen.height < 850 ? screen.height * 0.1 : screen.height * 0.06,
          ),
        ),
      ),
      child: Text(
        "Crear template",
        style: TextStyle(
          fontSize: screen.height < 850 ? 30 : 20,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );

    var buttonSend = TextButton(
      onPressed: () => debugPrint(" height : ${screen.height}"),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(
          Theme.of(context).colorScheme.primary,
        ),
        minimumSize: WidgetStatePropertyAll<Size>(
          Size(
            screen.width * 0.8,
            screen.height < 850 ? screen.height * 0.1 : screen.height * 0.06,
          ),
        ),
      ),
      child: Text(
        "Enviar mensaje con template",
        style: TextStyle(
          fontSize: screen.height < 850 ? 30 : 20,
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Container(
      color: Theme.of(context).colorScheme.surfaceDim,
      child: Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [buttonMaketemplate, buttonSend],
        ),
      ),
    );
  }
}
