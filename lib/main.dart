import 'package:flutter/material.dart';
import 'package:bronco_bond/src/screens/signin.dart';
import 'package:bronco_bond/src/screens/navbar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: prefs.getString('token'),
  ));
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({
    @required this.token,
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
          /* add this into '/' route later, commented out for testing
          (context) =>
              (token != null && JwtDecoder.isExpired(token) == false)
                  ? BottomNavBar(token: token)
                  : const SigninPage(),

          (context) => BottomNavBar(token: token)
          */
          '/': (context) =>
              (token != null && JwtDecoder.isExpired(token) == false)
                  ? BottomNavBar(token: token)
                  : const SigninPage(),
        });
  }
}
