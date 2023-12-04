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
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: buildSearchBar(" ")),
              Text(
                "Educational",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                buildButton("Engineering"),
                buildButton("Biology"),
                buildButton("English"),
                buildButton("Math"),
              ]),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Chemistry"),
                  buildButton("Physics"),
                  buildButton("Information Technology")
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Sociology"),
                  buildButton("Psychology"),
                  buildButton("Computer Science")
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Hospitality"),
                  buildButton("Animal Science"),
                  buildButton("Education")
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Sports",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                buildButton("Football"),
                buildButton("Soccer"),
                buildButton("Swimming"),
                buildButton("Baseball")
              ]),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Basketball"),
                  buildButton("Esports"),
                  buildButton("Snow Sports")
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Badminton"),
                  buildButton("Volleyball"),
                  buildButton("Tennis"),
                  buildButton("Rowing")
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Hobbies",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Drawing"),
                  buildButton("Singing"),
                  buildButton("Gardening"),
                  buildButton("Gym")
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Fraternity"),
                  buildButton("Sorority"),
                  buildButton("Digital Art"),
                  buildButton("Archery")
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Cooking"),
                  buildButton("Baking"),
                  buildButton("Eating"),
                  buildButton("Gaming")
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Movies"),
                  buildButton("Studying"),
                  buildButton("Watching TV"),
                  buildButton("Anime")
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Languages",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Chinese"),
                  buildButton("German"),
                  buildButton("Spanish"),
                  buildButton("Korean")
                ],
              ),
              SizedBox(height: 10),
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
                )));
  }
}

//Widget for button
@override
Widget buildButton(String label) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    TextButton(
      child: Text(label, style: TextStyle(fontSize: 15)),
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(17)),
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

Widget buildSearchBar(String label) {
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
