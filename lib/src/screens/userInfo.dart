import 'package:bronco_bond/src/screens/interests.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<String> majors = [
  "Aerospace Engineering",
  "Agribusiness and Food Industry Management",
  "Agricultural Science",
  "Animal Health Science",
  "Animal Science",
  "Anthropology",
  "Apparel Merchandising and Management",
  "Architecture",
  "Art History",
  "Biology",
  "Biotechnology",
  "Business Administration",
  "Chemical Engineering",
  "Chemistry",
  "Civil Engineering",
  "Communication",
  "Computer Engineering",
  "Computer Science",
  "Construction Engineering and Management",
  "Criminology",
  "Early Childhood Studies",
  "Economics",
  "Electrical Engineering",
  "Electromechanical Systems Engineering Technology",
  "Electronic Systems Engineering Technology",
  "English",
  "Environmental Biology",
  "Food Science and Technology",
  "Gender, Ethnicity, and Multicultural Studies",
  "Geography",
  "Geology",
  "History",
  "Hospitality Management",
  "Industrial Engineering",
  "Kinesiology",
  "Landscape Architecture",
  "Liberal Studies",
  "Manufacturing Engineering",
  "Mathematics",
  "Mechanical Engineering",
  "Music",
  "Nutrition",
  "Philosophy",
  "Physics",
  "Plant Science",
  "Political Science",
  "Psychology",
  "Science, Technology, and Society",
  "Sociology",
  "Spanish",
  "Theatre",
  "Urban and Regional Planning",
  "Visual Communication Design",
]; // List of majors (implement later)

const List<String> minors = [
  "Accounting",
  "African American Studies",
  "Agribusiness and Food Industry Management",
  "Agronomy",
  "Animal and Veterinary Science",
  "Anthropology",
  "Art History",
  "Asian/Pacific Islander American Studies",
  "Astronomy",
  "Biophysics",
  "Botany",
  "Business Law",
  "Business",
  "Chemistry",
  "Chicana/o and Latina/o Studies",
  "Chinese",
  "Communication Studies",
  "Computer Information Systems",
  "Computer Science",
  "Contract Management",
  "Criminology",
  "Culinology®",
  "Dance",
  "Data Science",
  "Economics",
  "Energy Engineering",
  "English",
  "Entrepreneurship",
  "Environmental Health Specialist",
  "Equine Studies",
  "Fashion Merchandising",
  "Finance",
  "Food Safety",
  "Food Science and Technology",
  "Footwear Design and Merchandising",
  "French",
  "Gender and Sexuality Studies",
  "Geographic Information Systems",
  "Geography",
  "Geology",
  "History",
  "Horticulture",
  "Hospitality Management",
  "Human Resources",
  "International Agricultural Business Management",
  "International Business",
  "Landscape Architecture",
  "Management and Leadership",
  "Management of Not-for-Profit Organization",
  "Marketing Management",
  "Materials Engineering",
  "Mathematics",
  "Microbiology",
  "Multicultural Leadership Studies",
  "Multimedia Journalism",
  "Music",
  "Native American Studies",
  "Nonviolence Studies",
  "Nutrition",
  "Operations Management",
  "Pest and Disease Management",
  "Philosophy",
  "Physics",
  "Physiology",
  "Plant Based Food and Nutrition",
  "Political Science",
  "Psychology",
  "Public Relations",
  "Real Estate",
  "Regenerative Studies",
  "Science Education",
  "Science, Technology, and Society",
  "Social Work",
  "Sociology",
  "Soil Science",
  "Spanish",
  "Statistics",
  "Studio Arts",
  "Supply Chain/Logistics",
  "Teaching English to Speakers of Other Languages",
  "Theatre",
  "Urban and Community Agriculture",
  "Urban and Regional Planning",
  "Water Resources and Irrigation Design",
  "Writing Studies",
  "Zoology",
]; // List of minors (implement later)

/// Displays detailed information about a SampleItem.
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController prefNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool displayNameOnProfile = false;
  bool changingMajor = false;
  String? _selectedMajor;
  String? _selectedMinor;

  void addInfoToUser(BuildContext context) async {
    // add backend functionality here

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InterestsPage(),
      ),
    );
  }

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 8.0),
            buildTextField("Full Name", fullNameController),
            buildTextField("Preferred Name", prefNameController),
            buildCheckBox("Display Name on Profile", displayNameOnProfile,
                (value) {
              setState(() {
                displayNameOnProfile = value ?? false;
              });
            }),
            buildProfileIcon(),
            const SizedBox(height: 10),
            buildDropDown("Major*", majors, _selectedMajor, (newValue) {
              setState(() {
                _selectedMajor = newValue;
              });
            }),
            buildCheckBox("Planning on Changing Majors", changingMajor,
                (value) {
              setState(() {
                changingMajor = value ?? false;
              });
            }),
            buildDropDown("Minor", minors, _selectedMinor, (newValue) {
              setState(() {
                _selectedMinor = newValue;
              });
            }),
            const SizedBox(height: 10),
            buildTextArea(),
            buildButton("Next", context),
          ],
        ),
      ),
    );
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

  // Widget for Display Name on Profile checkbox
  Widget buildCheckBox(
      String label, bool currentVal, Function(bool?) onChanged) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 0, right: 5),
          child: CheckboxListTile(
            title: Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            value: currentVal, // Set default value of checkbox to false
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Color(0xFF3B5F43),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Widget for Profile Icon upload section
  Widget buildProfileIcon() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Icon
          Image.asset(
            'assets/images/user_profile_icon.png',
            width: 75.0,
            height: 75.0,
          ),
          // Padding in between image and column
          const SizedBox(width: 15),
          // Column that contains text and upload button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text
              Text(
                "Profile Icon",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              // Padding in between text and button
              const SizedBox(height: 10),
              // Upload button
              SizedBox(
                width: 239,
                height: 43,
                child: ElevatedButton(
                  onPressed: () {
                    /*Add upload profile image functionality here*/
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: Color(0xFFABABAB),
                      ),
                    ),
                  ),
                  child: Text(
                    "Upload",
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Widget for Dropdown Buttons
  Widget buildDropDown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          width: 327,
          height: 43,
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue, // Set default value
            underline: Container(
              // height: 1, uncomment to get rid of underline in dropdown
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFABABAB),
                  // width: 2, can't seem to get an outline to appear in the dropdown button
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            iconEnabledColor: const Color(0xFFABABAB),
            items: items.map((String value) {
              return buildDropDownItem(value);
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> buildDropDownItem(String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  // Widget for Bio TextArea, uses multiple lines
  Widget buildTextArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text label
        Text(
          "Bio",
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
          height: 101,
          child: TextField(
            controller: bioController,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFABABAB)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.all(12.0),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget buildButton(String label, BuildContext context) {
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
              addInfoToUser(context);
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
}
