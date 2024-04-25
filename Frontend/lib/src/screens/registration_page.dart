import 'package:bronco_bond/src/screens/user_info_page.dart';
import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Displays detailed information about a SampleItem.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void registerUser(BuildContext context) async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      if (emailController.text.contains("@cpp.edu")) {
        if (passwordController.text.length >= 6) {
          if (passwordController.text == confirmPasswordController.text) {
            var regBody = {
              "email": emailController.text,
              "username": usernameController.text,
              "password": passwordController.text
            };

            var response = await http.post(Uri.parse(register),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(regBody));

            if (response.body.isNotEmpty) {
              var jsonResponse = jsonDecode(response.body);
              print(jsonResponse);
              if (jsonResponse['status']) {
                var token = jsonResponse['token'];
                prefs.setString('token', token);

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserInfoPage()));
              } else {
                LoginPageState.buildDialog(context, "Registration failed!",
                    "Account with this email or username already exists.");
              }
            } else {
              print("Empty Response");
            }
          } else {
            LoginPageState.buildDialog(context, "Registration failed!",
                "Passwords do not match. Please try again.");
          }
        } else {
          LoginPageState.buildDialog(context, "Registration failed!",
              "Password must be at least 6 characters!");
        }
      } else {
        LoginPageState.buildDialog(context, "Registration failed!",
              "Invalid Email!");
      }
    } else {
      LoginPageState.buildDialog(context, "Registration failed!",
          "Please fill out all fields and try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "BroncoBond",
          style: GoogleFonts.raleway(
            textStyle: Theme.of(context).textTheme.displaySmall,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3B5F43),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTextField("Username*", usernameController),
            buildTextField("Email*", emailController),
            buildTextFieldWithToggle(
                "Password*", passwordController, _obscurePassword, () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            }),
            buildTextFieldWithToggle(" Confirm Password*",
                confirmPasswordController, _obscureConfirmPassword, () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            }),
            LoginPageState.buildMainButton("Next", context,
                (BuildContext context) {
              registerUser(context);
            }),
          ],
        ),
      ),
    );
  }

  // Widget for TextFields
  Widget buildTextFieldWithToggle(
      String label,
      TextEditingController fieldController,
      bool obscureText,
      VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
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
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: fieldController,
                  keyboardType: TextInputType.text,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFABABAB)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3B5F43)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  textAlign: TextAlign.start,
                ),
                IconButton(
                    onPressed: toggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController fieldController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
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
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFABABAB)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF3B5F43)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  /*Widget buildButton(String label, BuildContext context) {
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
              registerUser(context);
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
  }*/
}
