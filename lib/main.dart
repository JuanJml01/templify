import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:templify/presenters/user_presenter.dart';
import 'package:templify/theme/theme.dart';
import 'package:templify/view/create_template.dart';
import 'package:templify/view/home.dart';
import 'package:templify/view/select_template.dart';
import 'package:templify/view/send_templates.dart';
import 'package:templify/view/settings.dart';

Future<void> main() async {
  const String loggerId = "main";
  _logInfo(loggerId, "Application starting...");

  WidgetsFlutterBinding.ensureInitialized();
  _logInfo(loggerId, "WidgetsFlutterBinding ensured.");

  final userPresenter = UserPresenter();
  _logInfo(loggerId, "UserPresenter instance created.");

  try {
    _logInfo(loggerId, "Initializing UserPresenter...");
    final stopwatch = Stopwatch()..start();
    await userPresenter.initialize();
    stopwatch.stop();
    _logInfo(
      loggerId,
      "UserPresenter initialized successfully in ${stopwatch.elapsedMilliseconds}ms.",
    );
  } catch (e, s) {
    _logError(
      loggerId,
      "Failed to initialize UserPresenter.",
      error: e,
      stackTrace: s,
    );

    _logWarning(
      loggerId,
      "Proceeding with potentially uninitialized or partially initialized UserPresenter.",
    );
  }

  _logInfo(loggerId, "Setting up Provider and running application...");

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: userPresenter)],
      child: const MyApp(),
    ),
  );
  _logInfo(loggerId, "Application is running.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String loggerId = "MyApp";
    _logInfo(loggerId, "Building widget tree...");

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      debugShowMaterialGrid: false,
      title: 'Templify',

      theme: themeLight,
      darkTheme: themeDark,
      themeMode: ThemeMode.system,

      initialRoute: "/home",
      routes: {
        "/home": (context) => const Home(),
        "/createTemplate": (context) => const CreateTemplate(),
        "/selectTemplate": (context) => const SelectTemplate(),
        "/sendTemplate": (context) => const SendTemplates(),
        "/settings": (context) => const Settings(),
      },
    );
  }
}

void _logInfo(String identifier, String message) {
  debugPrint("INFO:[$identifier]: $message");
}

void _logWarning(String identifier, String message) {
  debugPrint("WARNING:[$identifier]: $message");
}

void _logError(
  String identifier,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  final StringBuffer logMessage = StringBuffer("ERROR:[$identifier]: $message");
  if (error != null) {
    logMessage.write("\nErrorObject: ${error.toString()}");
  }
  if (stackTrace != null) {
    logMessage.write("\nStackTrace:\n$stackTrace");
  }
  debugPrint(logMessage.toString());
}
