import 'package:bronco_bond/src/screens/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void registerUser() async {
    /*
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text
      };

      var response = await http.post(Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInPage()));
      } else {
        print("SomeThing Went Wrong");
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextField("Email*", emailController),
            buildTextField("Password*", passwordController),
            buildTextField(" Confirm Password*", passwordController),
            const SizedBox(height: 10),
            buildButton("Register", context, const UserInfoPage()),
          ],
        ),
      ),
    );
  }
}

// Widget for TextFields
Widget buildTextField(String label, TextEditingController fieldController) {
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

Widget buildButton(String label, BuildContext context, Widget destination) {
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
    ),
  );
}
