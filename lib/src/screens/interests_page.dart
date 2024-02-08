import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:bronco_bond/src/screens/user_info_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterestsPage extends StatelessWidget {
  const InterestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const Text("    How do you want to be involved?"),
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
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                buildButton("Engineering"),
                buildButton("Biology"),
                buildButton("English"),
                buildButton("Math"),
              ]),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Chemistry"),
                  buildButton("Physics"),
                  buildButton("Information Technology")
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Sociology"),
                  buildButton("Psychology"),
                  buildButton("Computer Science")
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Hospitality"),
                  buildButton("Animal Science"),
                  buildButton("Education")
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Sports",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                buildButton("Football"),
                buildButton("Soccer"),
                buildButton("Swimming"),
                buildButton("Baseball")
              ]),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Basketball"),
                  buildButton("Esports"),
                  buildButton("Snow Sports")
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Badminton"),
                  buildButton("Volleyball"),
                  buildButton("Tennis"),
                  buildButton("Rowing")
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Hobbies",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Drawing"),
                  buildButton("Singing"),
                  buildButton("Gardening"),
                  buildButton("Gym")
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Fraternity"),
                  buildButton("Sorority"),
                  buildButton("Digital Art"),
                  buildButton("Archery")
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Cooking"),
                  buildButton("Baking"),
                  buildButton("Eating"),
                  buildButton("Gaming")
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Movies"),
                  buildButton("Studying"),
                  buildButton("Watching TV"),
                  buildButton("Anime")
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Languages",
                style: GoogleFonts.raleway(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Chinese"),
                  buildButton("German"),
                  buildButton("Spanish"),
                  buildButton("Korean")
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
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
      style: ButtonStyle(
          padding:
              MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(17)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.black)))),
      onPressed: () {
        print('$label pressed');
      },
      child: Text(label, style: const TextStyle(fontSize: 15)),
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
