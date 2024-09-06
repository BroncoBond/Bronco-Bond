import 'package:bronco_bond/src/screens/forgot_password.dart';
import 'package:bronco_bond/src/screens/registration_page.dart';
import 'package:bronco_bond/src/screens/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:bronco_bond/src/screens/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bronco_bond/src/config.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// Displays detailed information about a SampleItem.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool hidePassword = true;
  bool staySignedIn = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.forward();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          print(jsonResponse);
          if (jsonResponse['status']) {
            var token = jsonResponse['token'];
            var userID = getUserIDFromToken(token);

            prefs.setString('token', token);
            prefs.setString('userID', userID);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavBar(userID: userID),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xFF435F49),
        body: SlidingUpPanel(
          maxHeight: MediaQuery.of(context).size.height,
          minHeight: MediaQuery.of(context).size.height - 540,
          color: Colors.transparent,
          boxShadow: null,
          panelBuilder: (ScrollController sc) => buildLogin(sc),
          body: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height * 0.2,
                left: (MediaQuery.of(context).size.width - 250) /
                    2, // center logo
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(
                            0, 2.0), // start from the bottom of the screen
                        end: Offset.zero, // end at the center vertically
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeInOut,
                      )),
                      child: Image.asset(
                        'assets/images/BroncoBondCircle.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogin(ScrollController sc) {
    return SingleChildScrollView(
      controller: sc,
      child: Stack(
        children: [
          Positioned.fill(
            top: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/login_bg.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildTitle("Bronco", 45.0, FontWeight.w800, Colors.white),
                      buildTitle(
                          "Bond", 45.0, FontWeight.w800, Color(0xFFFED154)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  buildTextFieldWithIcon(
                      Icons.email_rounded, "Email", emailController, false),
                  const SizedBox(height: 10),
                  buildTextFieldWithIcon(
                      Icons.lock_rounded, "Password", passwordController, true),
                  buildCheckBox("Stay signed in", staySignedIn, (value) {
                    setState(() {
                      staySignedIn = value ?? false;
                    });
                  }),
                  const SizedBox(height: 70),
                  buildMainButton("Log In", "yellow", context,
                      (BuildContext context) {
                    loginUser(context);
                  }),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 40.0),
                      child: buildTextButton(
                        "Forgot your password?",
                        context,
                        const ForgotPasswordPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Don't have an account yet?",
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      buildTextButton(
                        "Sign up",
                        context,
                        const RegisterPage(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(String label, double size, FontWeight weight, Color color) {
    // Title
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: size,
            fontWeight: weight,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget buildTextButton(
      String label, BuildContext context, Widget destination) {
    return Container(
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
            color: const Color(0xFFFED154),
          ),
        ),
      ),
    );
  }

  static Widget buildMainButton(String label, String color,
      BuildContext context, void Function(BuildContext) onPressed) {
    Color buttonColor;
    Color textColor;

    if (color == "yellow") {
      buttonColor = const Color(0xFFFED154);
      textColor = const Color(0xFF435E49);
    } else if (color == "green") {
      buttonColor = const Color(0xFF435E49);
      textColor = const Color(0xFFFED154);
    } else {
      // Default colors
      buttonColor = const Color(0xFFFED154);
      textColor = const Color(0xFF435E49);
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Container(
          width: 329,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: buttonColor,
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
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for TextFields
  Widget buildTextFieldWithIcon(
    IconData icon,
    String hint,
    TextEditingController fieldController,
    bool obscureText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field
        SizedBox(
          width: 327,
          height: 60,
          child: TextField(
            controller: fieldController,
            keyboardType: TextInputType.text,
            obscureText: obscureText ? hidePassword : obscureText,
            cursorColor: Color(0xFFFED154),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 16,
                color: const Color(0xFF2E4233),
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF2E4233),
              ),
              suffixIcon: obscureText
                  ? IconButton(
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFF2E4233),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Color(0xFF55685A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFFED154), width: 3.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
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
          padding: const EdgeInsets.only(left: 20, top: 0, right: 0),
          child: CheckboxListTile(
            title: Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            value: currentVal, // Set default value of checkbox to false
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            side: const BorderSide(color: const Color(0xFFFED154), width: 1.5),
            checkColor: const Color(0xFF435E49),
            activeColor: const Color(0xFFFED154),
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
                  overlayColor:
                      MaterialStateColor.resolveWith((states) => Colors.white),
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
