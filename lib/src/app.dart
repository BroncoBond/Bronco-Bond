import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/login.dart';
import 'screens/signin.dart';
import 'screens/interests.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const themeColor = Color(0xff3B5F43);
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
      theme: ThemeData(
        useMaterial3: true,

        // Define default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.light,
        ),

        // Define default 'TextTheme'
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.raleway(
            fontSize: 30,
          ),
          bodyMedium: GoogleFonts.raleway(),
          displaySmall: GoogleFonts.raleway(),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      onGenerateRoute: (RouteSettings routeSettings) {
        switch (routeSettings.name) {
          case 'login':
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => const LoginPage());
          case 'signup':
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => const SigninPage());
          case 'interests':
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => const InterestsPage());
          case 'verification':
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => const SigninPage());
          default:
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) => const SigninPage());
        }
      },
    );
  }
}
