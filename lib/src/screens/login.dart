import 'package:bronco_bond/src/screens/forgotpassword.dart';
import 'package:bronco_bond/src/screens/userInfo.dart';
import 'package:bronco_bond/src/screens/register.dart';
import 'package:bronco_bond/src/screens/verification.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool staySignedIn = false;

  void loginUser() async {
    // add backend functionality here
    // sample code from flutter_todo_with_nodejs
    /*
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){

      var reqBody = {
        "email":emailController.text,
        "password":passwordController.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(reqBody)
      );

      var jsonResponse = jsonDecode(response.body);
      if(jsonResponse['status']){
          var myToken = jsonResponse['token'];
          prefs.setString('token', myToken);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(token: myToken)));
      }else{
        print('Something went wrong');
      }

    }
    */
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
            buildTextFieldWithIcon(
                "Email", Icons.email, "example@cpp.edu", emailController),
            const SizedBox(height: 30),
            buildTextFieldWithIcon(
                "Password", Icons.lock, "Password", passwordController),
            const SizedBox(height: 30),
            buildButton("Login", context, const VerificationPage()),
            buildCheckBox("Stay signed in", staySignedIn),
            const SizedBox(height: 70),
            buildTextButton(
              "Can't Sign In?",
              context,
              const ForgotPasswordPage(),
            ),
            const SizedBox(height: 8),
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

  Widget buildButton(String label, BuildContext context, Widget destination) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 329,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF3B5F43),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => destination,
              ),
            );
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
    );
  }

  // Widget for TextFields
  Widget buildTextFieldWithIcon(String label, IconData icon, String hint,
      TextEditingController fieldController) {
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  // Widget for Display Name on Profile checkbox
  Widget buildCheckBox(String label, bool currentVal) {
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
            onChanged: (bool? newVal) {
              setState(() {
                /* Add checkbox functionality here */
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
