import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bronco_bond/src/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const List<String> interests = [
  "Engineering",
  "Biology",
  "English",
  "Math",
  "Chemistry",
  "Physics",
  "Information Technology",
  "Sociology",
  "Psychology",
  "Computer Science",
  "Hospitality",
  "Animal Science",
  "Education",
  "Football",
  "Soccer",
  "Swimming",
  "Baseball",
  "Basketball",
  "Esports",
  "Snow Sports",
  "Badminton",
  "Volleyball",
  "Tennis",
  "Rowing",
  "Drawing",
  "Singing",
  "Gardening",
  "Gym",
  "Fraternity",
  "Sorority",
  "Digital Art",
  "Archery",
  "Cooking",
  "Baking",
  "Eating",
  "Gaming",
  "Movies",
  "Studying",
  "Watching TV",
  "Anime",
  "Chinese",
  "German",
  "Spanish",
  "Korean",
];

class InterestsPage extends StatefulWidget {
  final String userID;
  const InterestsPage({Key? key, required this.userID}) : super(key: key);

  @override
  InterestsPageState createState() => InterestsPageState();
}

class InterestsPageState extends State<InterestsPage> {
  List<String> userInterests = [];

  void addInterestsToUser(BuildContext context, String userID) async {
    // check if major is empty or null since it is required
    var regBody = {"_id": userID, "interests": userInterests};
    print('Adding interests: $regBody');

    try {
      var response = await http.put(Uri.parse('$updateUser/$userID'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      print('Response body: ${response.body}');
      var jsonResponse = jsonDecode(response.body);

      print("http request made");
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
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
      appBar: AppBar(
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
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "How do you want to be involved?",
                    style: TextStyle(
                        // color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ));
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
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
              padding: EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0, // padding between each button
                runSpacing: 2.0, // padding between each row of buttons
                children:
                    interests.map((interest) => buildButton(interest)).toList(),
              ),
            ),
            const SizedBox(height: 10),
            LoginPageState.buildMainButton("Next", context,
                (BuildContext context) {
              addInterestsToUser(context, widget.userID);
            }),
          ], //column children
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
            isSelected ? const Color(0xFFABABAB) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(
            color: Color(0xFF3B5F43),
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
        style: const TextStyle(
            fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
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
}
