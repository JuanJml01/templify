import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:templify/presenters/user_presenter.dart';
import 'package:templify/theme/theme.dart';
import 'package:templify/view/create_template.dart';
import 'package:templify/view/home.dart';
import 'package:templify/view/select_template.dart';
import 'package:templify/view/send_templates.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userPresenter = UserPresenter();
  await userPresenter.initialize();

  runApp(
    ChangeNotifierProvider.value(value: userPresenter, child: const MyApp()),
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
        "/selectTemplate": (context) => SelectTemplate(),
        "/sendTemplate": (context) => SendTemplates(),
      },
      initialRoute: "/home",
      themeMode: ThemeMode.system,
    );
  }
}
