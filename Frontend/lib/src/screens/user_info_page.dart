import 'dart:convert';
import 'dart:io';
import 'package:bronco_bond/src/screens/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bronco_bond/src/config.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/screens/interests_page.dart';
import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:bronco_bond/src/school_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _selectedMajor;
  String? _selectedMinor;
  String? _selectedGradDate;
  String? _selectedPronouns;
  String? _selectedGender;
  String? _selectedAgeGroup;
  File? _imageFile;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void addInfoToUser(BuildContext context) async {
    String? token = prefs.getString('token');
    var userID = getUserIDFromToken(token!);

    // Check if an image is uploaded and handle accordingly
    String base64Image = '';
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    // Check if major and grad date are not empty
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
      print("Regbody: $regBody");

      try {
        var response = await http.put(Uri.parse(updateUser),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(regBody));

        // print('Response body: ${response.body}');
        var jsonResponse = jsonDecode(response.body);

        // print("http request made");

        if (jsonResponse['status']) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InterestsPage()));
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

  final List<String> pronouns = ['He/Him', 'She/Her', 'They/Them', 'Other'];
  final List<String> genders = ['Male', 'Female', 'Non-Binary', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 45, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align all children to the start
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 28,
                    right: 38,
                    child: Container(
                      height: 10.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        color: Color(0xffFED154),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Tell us more about you',
                      style: GoogleFonts.raleway(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff2E4233),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              buildTextField("Full Name", fullNameController),
              const SizedBox(height: 9.0),
              buildTextField("Preferred Name", prefNameController),
              const SizedBox(height: 9.0),
              buildCheckBox("Display Name on Profile", displayNameOnProfile,
                  (value) {
                setState(() {
                  displayNameOnProfile = value ?? false;
                });
              }),
              // const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildDropDown(
                      "Gender",
                      genders,
                      _selectedGender,
                      (newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: buildDropDown(
                      "Pronouns",
                      pronouns,
                      _selectedPronouns,
                      (newValue) {
                        setState(() {
                          _selectedPronouns = newValue;
                        });
                      },
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              buildProfileIcon(),
              const SizedBox(height: 9.0),
              buildDropDown("Major", majors, _selectedMajor, (newValue) {
                setState(() {
                  _selectedMajor = newValue;
                });
              }),
              const SizedBox(height: 9.0),
              buildDropDown("Minor", minors, _selectedMinor, (newValue) {
                setState(() {
                  _selectedMinor = newValue;
                });
              }),
              const SizedBox(height: 9.0),
              buildDropDown(
                  "Expected Graduation Year", years, _selectedGradDate,
                  (newValue) {
                setState(() {
                  _selectedGradDate = newValue;
                });
              }),
              const SizedBox(height: 9.0),
              buildTextArea(),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      addInfoToUser(context);
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: const BoxDecoration(
                        color: Color(0xff435F49),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xffFED154),
                        size: 35.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for TextFields
  Widget buildTextField(String label, TextEditingController fieldController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff2E4233),
          ),
        ),
        const SizedBox(height: 3.0),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextField(
            controller: fieldController,
            keyboardType: TextInputType.text,
            style: GoogleFonts.raleway(
              color: Color(0xFF2E4233),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.raleway(
                color: Color(0xff939393),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Color(0xffDDDDDD),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(11),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  // Widget for Display Name on Profile checkbox (Updated to use Row for alignment)
  Widget buildCheckBox(
      String label, bool currentVal, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: currentVal,
          onChanged: onChanged,
          activeColor: const Color(0xFF3B5F43),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xff435F49),
          ),
        ),
      ],
    );
  }

  // Updated Widget for Profile Icon to align with left
  Widget buildProfileIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align to the start (left)
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
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile Icon",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2E4233),
                ),
              ),
              const SizedBox(height: 3.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffDDDDDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.0),
                      side: const BorderSide(color: Color(0xffDDDDDD)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Select",
                    style: GoogleFonts.raleway(
                      color: Color(0xff939393),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget for TextArea (Bio)
  Widget buildTextArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bio",
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff2E4233),
          ),
        ),
        const SizedBox(height: 3.0),
        SizedBox(
          width: double.infinity,
          child: TextField(
            controller: bioController,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Type here...",
              hintStyle: GoogleFonts.raleway(
                color: Color(0xff939393),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xffDDDDDD),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(11),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  // Widget for DropDowns
  Widget buildDropDown(
    String label,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged, {
    double width = double.infinity,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff2E4233),
          ),
        ),
        const SizedBox(height: 3.0),
        Container(
          width: width,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xffDDDDDD),
            borderRadius: BorderRadius.circular(11),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedItem,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xff3B5F43)),
              onChanged: onChanged,
              items: items
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.raleway(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ))
                  .toList(),
              hint: Text(
                "Select",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff939393),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // // Extract User ID from token
  // String getUserIDFromToken(String token) {
  //   Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //   String userID = decodedToken['_id'];
  //   return userID;
  // }
}
