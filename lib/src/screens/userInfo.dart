import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  bool displayNameOnProfile = false;
  bool changingMajor = false;
  // String? selectedValue;
  List<String> majors = [
    "Psychology",
    "Computer Science",
    "Biology"
  ]; // List of majors (implement later)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
            const SizedBox(height: 50),
            buildTextField("Username*"),
            const SizedBox(height: 10),
            buildTextField("Preferred Name"),
            buildCheckBox("Display Name on Profile", displayNameOnProfile),
            buildProfileIcon(),
            const SizedBox(height: 20),
            buildDropDown("Major*", majors),
            buildCheckBox("Planning on Changing Majors", changingMajor),
            buildDropDown("Minor", majors),
            buildTextArea(),
          ],
        ),
      ),
    );
  }

  // Widget for TextFields
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

  // Widget for Display Name on Profile checkbox
  Widget buildCheckBox(String label, bool currentVal) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 0),
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
            onChanged: (bool? newVal) {
              setState(() {
                /* Add checkbox functionality here */
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
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
  Widget buildDropDown(String label, List<String> items) {
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
            // value: , // Set default value
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
            onChanged: (String? newValue) {
              /* Handle change in value */
            },
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

  Widget buildTextArea() {}
}
