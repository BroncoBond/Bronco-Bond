import 'package:bronco_bond/src/screens/forgot_password.dart';
import 'package:bronco_bond/src/screens/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:bronco_bond/src/screens/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bronco_bond/src/config.dart';

/// Displays detailed information about a SampleItem.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool staySignedIn = false;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser(BuildContext context) async {
    print('Login Button Pressed');
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
        "staySignedIn": staySignedIn.toString()
      };

      try {
        var response = await http.post(Uri.parse(login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody));

        print('${response.statusCode}');
        // print(response.body);
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            var myToken = jsonResponse['token'];
            var myUserID = getUserIDFromToken(myToken);

            prefs.setString('token', myToken);
            prefs.setString('userID', myUserID);

            print('This is the current user\'s ID: $myUserID');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BottomNavBar(token: myToken, userID: myUserID),
              ),
            );
          } else {
            print('Login failed: ${jsonResponse['message']}');
            // Handle login failure
            // You might want to show an error message to the user
          }
        } else {
          print('HTTP request failed with status: ${response.statusCode}');
          buildDialog(context, "Login failed!",
              "Please check your email and password and try again.");
        }
      } catch (e) {
        print('Error during HTTP request: $e');
        // Handle other exceptions
        // You might want to show an error message to the user
      }
    } else {
      // Handle case where email or password is empty
      // You might want to show an error message to the user
      print('Email or password is empty');
      buildDialog(context, "Login failed!",
          "Email or password is empty. Please try again.");
    }
  }

  String getUserIDFromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['_id'];
    } catch (e) {
      print('Error decoding token: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Verification", 25, FontWeight.w300),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 70),
            buildTitle("BroncoBond", 50.0, FontWeight.w800),
            const SizedBox(height: 8),
            buildTextFieldWithIcon("Email", Icons.email_rounded,
                "example@cpp.edu", emailController, false),
            const SizedBox(height: 30),
            buildTextFieldWithIcon("Password", Icons.lock_rounded, "Password",
                passwordController, true),
            const SizedBox(height: 30),
            buildMainButton("Login", context, (BuildContext context) {
              loginUser(context);
            }),
            buildCheckBox("Stay signed in", staySignedIn, (value) {
              setState(() {
                staySignedIn = value ?? false;
              });
            }),
            const SizedBox(height: 70),
            buildTextButton(
              "Can't Sign In?",
              context,
              const ForgotPasswordPage(),
            ),
            buildTextButton(
              "Create Account",
              context,
              const RegisterPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String label, double size, FontWeight weight) {
    // Title
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: size,
            fontWeight: weight,
            color: const Color(0xFF3B5F43),
          ),
        ),
      ),
    );
  }

  Widget buildTextButton(
      String label, BuildContext context, Widget destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ),
          );
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3B5F43),
          ),
        ),
      ),
    );
  }

  static Widget buildMainButton(String label, BuildContext context,
      void Function(BuildContext) onPressed) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: 329,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFF3B5F43),
          ),
          child: TextButton(
            onPressed: () {
              onPressed(context);
            },
            child: Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for TextFields
  Widget buildTextFieldWithIcon(String label, IconData icon, String hint,
      TextEditingController fieldController, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text label
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
        // Text field
        SizedBox(
          width: 327,
          height: 43,
          child: TextField(
            controller: fieldController,
            keyboardType: TextInputType.text,
            obscureText: obscureText,
            decoration: InputDecoration(
              suffixIcon: Icon(
                icon,
                size: 16,
                color: const Color(0xFF1E1E1E),
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFABABAB),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFABABAB)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3B5F43))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  // Widget for Display Name on Profile checkbox
  Widget buildCheckBox(
      String label, bool currentVal, Function(bool?) onChanged) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 0, right: 5),
          child: CheckboxListTile(
            title: Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            value: currentVal, // Set default value of checkbox to false
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFF3B5F43),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static Future<dynamic> buildDialog(
      BuildContext context, title, String content) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xffABABAB)),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF3B5F43),
                  ),
                )),
          ],
        );
      },
    );
  }
}
