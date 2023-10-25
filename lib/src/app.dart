import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/interests.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      onGenerateRoute: (RouteSettings routeSettings) {
            switch (routeSettings.name) {
              case 'login':
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const LoginPage()
                );
              case 'signup':
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const SignupPage()
                );
              case 'interests':
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const InterestsPage()
                );
              default:
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) => const LoginPage()
                );
            }
      },
    );
  }
}