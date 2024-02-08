import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bronco_bond/src/config.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/screens/interests_page.dart';
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

const List<String> years = [
  "2034",
  "2033",
  "2032",
  "2031",
  "2030",
  "2029",
  "2028",
  "2027",
  "2026",
  "2025",
  "2024",
  "2023",
  "2022",
  "2021",
  "2020",
  "2019",
  "2018",
  "2017",
  "2016",
  "2015",
  "2014",
  "2013",
  "2012",
  "2011",
  "2010",
  "2009",
  "2008",
  "2007",
  "2006",
  "2005",
  "2004",
  "2003",
  "2002",
  "2001",
  "2000",
  "1999",
  "1998",
  "1997",
  "1996",
  "1995",
  "1994",
  "1993",
  "1992",
  "1991",
  "1990",
  "1989",
  "1988",
  "1987",
  "1986",
  "1985",
  "1984",
  "1983",
  "1982",
  "1981",
  "1980"
];

/// Displays detailed information about a SampleItem.
class UserInfoPage extends StatefulWidget {
  final String userID;
  const UserInfoPage({Key? key, required this.userID}) : super(key: key);

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController prefNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool displayNameOnProfile = false;
  String? _selectedMajor;
  String? _selectedMinor;
  String? _selectedGradDate;
  File? _imageFile;

  void addInfoToUser(BuildContext context, String userID) async {
    print('User ID: $userID');
    // check if major is empty or null since it is required
    if (_selectedMajor != null &&
        _selectedMajor!.isNotEmpty &&
        _selectedGradDate != null &&
        _selectedGradDate!.isNotEmpty) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var regBody = {
        "_id": userID,
        "fullName": fullNameController.text,
        "prefName": prefNameController.text,
        "descriptionBio": bioController.text,
        "descriptionMajor": _selectedMajor,
        "descriptionMinor": _selectedMinor,
        "graduationDate": _selectedGradDate,
        "profilePicture": {"data": base64Image, "contentType": "image/jpeg"}
      };
      print("major selected and body created");
      print(regBody);

      try {
        var response = await http.put(Uri.parse('$updateUser/$userID'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody));

        print('Response body: ${response.body}');
        var jsonResponse = jsonDecode(response.body);

        print("http request made");
        print(jsonResponse['status']);

        if (jsonResponse['status']) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const InterestsPage()));
        } else {
          print("Something went wrong");
        }
      } catch (e) {
        print('Error during HTTP request: $e');
      }
    } else {
      print('Major or Grad date is empty');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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
            SizedBox(height: 8.0),
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
            SizedBox(height: 8.0),
            buildDropDown("Minor", minors, _selectedMinor, (newValue) {
              setState(() {
                _selectedMinor = newValue;
              });
            }),
            SizedBox(height: 8.0),
            buildDropDown("Expected Graduation Year*", years, _selectedGradDate,
                (newValue) {
              setState(() {
                _selectedGradDate = newValue;
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
          // Profile Icon. Check if image is uploaded or not
          _imageFile != null
              ? CircleAvatar(
                  backgroundImage: FileImage(_imageFile!),
                  radius: 37.5,
                )
              : Image.asset(
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
                    pickImage();
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
            maxLines: 4,
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
              addInfoToUser(context, widget.userID);
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
