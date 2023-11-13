import 'package:bronco_bond/src/screens/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "BroncoBond",
                  style: GoogleFonts.raleway(
                    textStyle: Theme.of(context).textTheme.displaySmall,
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B5F43),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserInfoPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Create Account",
                    style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displaySmall,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B5F43),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
