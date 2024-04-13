import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bronco_bond/src/config.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/screens/interests_page.dart';
import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:bronco_bond/src/school_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Check if an image is uploaded and handle accordingly
    String base64Image = '';
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    // check if major is empty or null since it is required
    if (_selectedMajor != null &&
        _selectedMajor!.isNotEmpty &&
        _selectedGradDate != null &&
        _selectedGradDate!.isNotEmpty) {
      var regBody = {
        "_id": userID,
        "fullName": fullNameController.text,
        "prefName": prefNameController.text,
        "descriptionBio": bioController.text,
        "descriptionMajor": _selectedMajor,
        "descriptionMinor": _selectedMinor,
        "graduationDate": _selectedGradDate,
        "profilePicture": _imageFile != null
            ? {"data": base64Image, "contentType": "image/jpeg"}
            : null
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InterestsPage(userID: userID)));
        } else {
          print("Something went wrong");
        }
      } catch (e) {
        print('Error during HTTP request: $e');
      }
    } else {
      print('Major or Grad date is empty');
      LoginPageState.buildDialog(
          context, "Registration failed!", "Major & Grad Date are required!");
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
            if (_selectedMajor != null &&
                _selectedMajor!.isNotEmpty &&
                _selectedGradDate != null &&
                _selectedMajor!.isNotEmpty) {
              Navigator.of(context).pop();
            } else {
              LoginPageState.buildDialog(context, "Registration failed!",
                  "Major & Grad Date are required!");
            }
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
            const SizedBox(height: 8.0),
            buildTextField("Full Name", fullNameController),
            const SizedBox(height: 8.0),
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
            const SizedBox(height: 8.0),
            buildDropDown("Minor", minors, _selectedMinor, (newValue) {
              setState(() {
                _selectedMinor = newValue;
              });
            }),
            const SizedBox(height: 8.0),
            buildDropDown("Expected Graduation Year*", years, _selectedGradDate,
                (newValue) {
              setState(() {
                _selectedGradDate = newValue;
              });
            }),
            const SizedBox(height: 10),
            buildTextArea(),
            LoginPageState.buildMainButton("Next", context,
                (BuildContext context) {
              addInfoToUser(context, widget.userID);
            }),
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
            activeColor: const Color(0xFF3B5F43),
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
        width: 300,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
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

/* Widget buildButton(String label, BuildContext context) {
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
*/
}
