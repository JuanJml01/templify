import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:templify/presenters/user_presenter.dart';
import 'package:templify/theme/theme.dart';
import 'package:templify/view/create_template.dart';
import 'package:templify/view/home.dart';

void main() async {
  // 1. Haz que main sea async
  WidgetsFlutterBinding.ensureInitialized();
  final userPresenter = UserPresenter(); // 3. Crea la instancia del presenter
  await userPresenter
      .initialize(); // 4. Llama y espera a que se complete la inicialización

  runApp(
    ChangeNotifierProvider.value(
      // 5. Usa ChangeNotifierProvider.value
      value: userPresenter, //    porque ya tienes la instancia creada
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      title: 'Templify',
      theme: themeLight,
      darkTheme: themeDark,
      home: Home(),
      routes: {
        "/home": (context) => Home(),
        "/createTemplate": (context) => CreateTemplate(),
      },
      initialRoute: "/home",
      themeMode: ThemeMode.system,
    );
  }
}
