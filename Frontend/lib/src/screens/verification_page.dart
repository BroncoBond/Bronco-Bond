import 'dart:async';

import 'package:bronco_bond/src/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// Displays detailed information about a SampleItem.
class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  String currentText = "";

  final formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType>? errorController;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            height: 10.0,
                            width: 110.0,
                            decoration: BoxDecoration(
                              color: Color(0xffFED154),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Verify',
                            style: GoogleFonts.raleway(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Color(0xff55685A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: RichText(
                      text: TextSpan(
                        text: "Enter the code sent to ",
                        children: [
                          TextSpan(
                            text: "${widget.email}",
                            style: GoogleFonts.raleway(
                              color: Color(0xFF2E4233),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                        style: GoogleFonts.raleway(
                          color: Color(0xFF2E4233),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // TO DO
              },
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: Color(0xff435F49),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xffFED154),
                  size: 35.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
