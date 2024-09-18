import 'dart:async';

import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:bronco_bond/src/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
        backgroundColor: Color(0xFF435F49),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
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
                      padding: const EdgeInsets.only(top: 50, bottom: 10),
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
                    // Pin Code Field
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 40.0,
                        ),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 6) {
                              return "Please enter the full code";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10.0),
                            fieldHeight: 65,
                            fieldWidth: 50,
                            inactiveFillColor: Colors.transparent,
                            inactiveColor: Color(0xFFDDDDDD),
                            selectedFillColor: Colors.transparent,
                            selectedColor: Color(0xFF435F49),
                            activeFillColor: Colors.transparent,
                            activeColor: Color(0xFFDDDDDD),
                          ),
                          cursorColor: Color(0xFF435F49),
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          onCompleted: (v) {
                            debugPrint("Completed");
                          },
                          onChanged: (value) {
                            debugPrint(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            debugPrint("Allowing to paste $text");
                            return true;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        hasError ? "*Please enter the code properly" : "",
                        style: GoogleFonts.raleway(
                          color: Color(0xFFB00020),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    //const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Didn't receive the code?",
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E4233),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Resend OTP
                        debugPrint('Resend pressed');
                      },
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Text(
                        "RESEND",
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF55685A),
                        ),
                      ),
                    ),
                  ],
                ),
                LoginPageState.buildMainButton(
                  "Confirm",
                  "green",
                  context,
                  (BuildContext context) {
                    formKey.currentState!.validate();
                    if (currentText.length != 6) {
                      errorController!.add(ErrorAnimationType.shake);
                      setState(() => hasError = true);
                    } else {
                      setState(() => hasError = false);
                      snackBar("OTP Verified!");
                      // Add backend function here
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
