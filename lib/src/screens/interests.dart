import 'package:bronco_bond/src/screens/searchpage.dart';
import 'package:bronco_bond/src/screens/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterestsPage extends StatelessWidget {
  const InterestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInfoPage()));
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
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text("    How do you want to be involved?"),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ));
                },
                child: Text(
                  'Skip',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ))
          ]),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            buildTag("Cooking"),
            buildTag("Spanish"),
            buildTag("English"),
            buildTag("Running"),
          ]),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Engineering"),
              buildTag("Mechanical Engineering"),
              buildTag("Movies")
            ],
          ),
          SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            buildTag("Aerospace Engineering"),
            buildTag("Skiing"),
            buildTag("Dancing")
          ]),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Space"),
              buildTag("Esports"),
              buildTag("Billiards"),
              buildTag("Singing")
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Badminton"),
              buildTag("Basketball"),
              buildTag("Eating"),
              buildTag("Soccer")
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Football"),
              buildTag("Agriculture"),
              buildTag("Art"),
              buildTag("Internships")
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Fraternity"),
              buildTag("Sorority"),
              buildTag("Digital Art"),
              buildTag("Archery")
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Computer Science"),
              buildTag("Information Technology")
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Psychology"),
              buildTag("Japanese"),
              buildTag("Korean"),
              buildTag("French")
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTag("Chinese"),
              buildTag("German"),
              buildTag("Biology"),
              buildTag("Math")
            ],
          ),
          SizedBox(height: 5),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
              child: Text(
                "Next",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ))
        ] //column children
            ));
  }
}

//Widget for button
Widget buildTag(String label) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    TextButton(
      child: Text(label, style: TextStyle(fontSize: 14)),
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)))),
      onPressed: () {
        print('${label} pressed');
      },
    )
  ]);
}

Widget buildTextField(String label) {
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
