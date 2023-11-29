import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BroncoBond",
            style: GoogleFonts.raleway(
                textStyle: Theme.of(context).textTheme.displaySmall,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3B5F43))),
      ),
    );
  }
}
