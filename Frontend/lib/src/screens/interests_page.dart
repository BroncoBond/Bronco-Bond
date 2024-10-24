import 'package:bronco_bond/src/school_data.dart';
import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:bronco_bond/src/screens/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bronco_bond/src/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  InterestsPageState createState() => InterestsPageState();
}

class InterestsPageState extends State<InterestsPage> {
  List<String> userInterests = [];
  TextEditingController interestsController = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void addInterestsToUser(BuildContext context) async {
    String? token = prefs.getString('token');
    var userID = getUserIDFromToken(token!);

    var regBody = {"_id": userID, "interests": userInterests};
    try {
      var response = await http.put(Uri.parse(updateInterests),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);

      print("http request made");
      print(jsonResponse);

      if (jsonResponse['status']) {
        print('Added interests: $regBody');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        print("Something went wrong");
      }
    } catch (e) {
      print('Error during HTTP request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     "BroncoBond",
      //     style: GoogleFonts.raleway(
      //       textStyle: Theme.of(context).textTheme.displaySmall,
      //       fontSize: 25,
      //       fontWeight: FontWeight.w800,
      //       color: const Color(0xFF3B5F43),
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 250),
                      child: Text(
                        "How do you want to be involved?",
                        style: GoogleFonts.raleway(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xff2e4233),
                        ),
                        // color: Colors.black,
                        //fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ));
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff939393),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.all(10.0), child: buildSearchBar()), */ // Comment out search bar for now
              // Build all interests
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0, // padding between each button
                  runSpacing: 2.0, // padding between each row of buttons
                  children: interests
                      .map((interest) => buildButton(interest))
                      .toList(),
                ),
              ),
              // const SizedBox(height: 10),
              buildCustomInterest(interestsController),
              LoginPageState.buildMainButton("Done", "green", context,
                  (BuildContext context) {
                addInterestsToUser(context);
              }),
            ], //column children
          ),
        ),
      ),
    );
  }

//Widget for button
  Widget buildButton(String label) {
    bool isSelected = userInterests.contains(label);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xfffed154) : const Color(0x7ffed154),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: const BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          // Toggle selection
          if (userInterests.contains(label)) {
            userInterests.remove(label);
          } else {
            userInterests.add(label);
          }
        });
      },
      child: Text(
        label,
        style: isSelected
            ? GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xff435f49),
                fontWeight: FontWeight.w700)
            : GoogleFonts.raleway(
                fontSize: 14,
                color: const Color(0xff939393),
                fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget buildCustomInterest(TextEditingController textEditingController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textEditingController,
        cursorColor: const Color(0xff939393),
        decoration: InputDecoration(
            labelText: "Add your own interests",
            labelStyle: GoogleFonts.raleway(
                fontSize: 16,
                color: Color(0xff939393),
                fontWeight: FontWeight.w500),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xffdddddd)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: const Color(0xffdddddd),
            focusColor: const Color(0xffdddddd),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xffdddddd),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.add,
                color: Color(0xFF3B5F43),
              ),
              onPressed: () {
                setState(() {
                  String newInterests = textEditingController.text.trim();
                  List<String> interestsToAdd = newInterests.split(',');
                  for (var interest in interestsToAdd) {
                    String trimmedInterest =
                        interest.trim().split(' ').take(3).join(' ');
                    if (trimmedInterest.isNotEmpty) {
                      trimmedInterest = trimmedInterest
                          .split(' ')
                          .map((word) => word.capitalize())
                          .join(' ');
                      userInterests.add(trimmedInterest);
                    }
                  }
                  textEditingController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Interests added successfully!",
                        style: GoogleFonts.raleway(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xff435f49),
                    ),
                  );
                });
              },
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
      ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
