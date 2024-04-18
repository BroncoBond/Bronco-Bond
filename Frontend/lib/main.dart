import 'package:flutter/material.dart';
import 'package:bronco_bond/src/screens/welcome_page.dart';
import 'package:bronco_bond/src/screens/nav_bar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
      token: prefs.getString('token'), userID: prefs.getString('userID')));
}

class MyApp extends StatelessWidget {
  final token;
  final userID;
  const MyApp({
    @required this.token,
    @required this.userID,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xff3B5F43),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white, // Set the app bar color to white
            elevation: 0.0,
          ),
        ),
        initialRoute: '/', // Initial route
        routes: {
          '/': (context) =>
              (token != null || JwtDecoder.isExpired(token) == false)
                  ? BottomNavBar(
                      userID: userID,
                    )
                  : const SigninPage(),
        });
  }
}


/*
  Dev Notes (set up emulator first):
    Step 1: In terminal [flutter pub get]
    Step 2: In terminal [flutter create .]
    Step 3: In terminal [flutter pub run flutter_launcher_icons]
    Step 4: In terminal [dart run flutter_native_splash:create]
*/
