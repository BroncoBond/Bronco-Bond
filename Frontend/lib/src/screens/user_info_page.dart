// import 'dart:convert';
// import 'dart:io';
// import 'package:bronco_bond/src/screens/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:bronco_bond/src/config.dart';
// import 'package:http/http.dart' as http;
// import 'package:bronco_bond/src/screens/interests_page.dart';
// import 'package:bronco_bond/src/screens/login_page.dart';
// import 'package:bronco_bond/src/school_data.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// Displays detailed information about a SampleItem.
// class UserInfoPage extends StatefulWidget {
//   const UserInfoPage({super.key});

//   @override
//   UserInfoPageState createState() => UserInfoPageState();
// }

// class UserInfoPageState extends State<UserInfoPage> {
//   TextEditingController fullNameController = TextEditingController();
//   TextEditingController prefNameController = TextEditingController();
//   TextEditingController bioController = TextEditingController();

//   bool displayNameOnProfile = false;
//   String? _selectedMajor;
//   String? _selectedMinor;
//   String? _selectedGradDate;
//   String? _selectedPronouns;
//   String? _selectedGender;
//   File? _imageFile;
//   late SharedPreferences prefs;

//   @override
//   void initState() {
//     super.initState();
//     initSharedPref();
//   }

//   void initSharedPref() async {
//     prefs = await SharedPreferences.getInstance();
//   }

//   void addInfoToUser(BuildContext context) async {
//     String? token = prefs.getString('token');
//     var userID = getUserIDFromToken(token!);

//     // Check if an image is uploaded and handle accordingly
//     String base64Image = '';
//     if (_imageFile != null) {
//       List<int> imageBytes = await _imageFile!.readAsBytes();
//       base64Image = base64Encode(imageBytes);
//     }
//     // check if major is empty or null since it is required
//     if (_selectedMajor != null &&
//         _selectedMajor!.isNotEmpty &&
//         _selectedGradDate != null &&
//         _selectedGradDate!.isNotEmpty) {
//       var regBody = {
//         "_id": userID,
//         "fullName": fullNameController.text,
//         "prefName": prefNameController.text,
//         "descriptionBio": bioController.text,
//         "descriptionMajor": _selectedMajor,
//         "descriptionMinor": _selectedMinor,
//         "graduationDate": _selectedGradDate,
//         "profilePicture": _imageFile != null
//             ? {"data": base64Image, "contentType": "image/jpeg"}
//             : null
//       };
//       print("major selected and body created");
//       print("Regbody: $regBody");

//       try {
//         var response = await http.put(Uri.parse(updateUser),
//             headers: {
//               "Content-Type": "application/json",
//               "Authorization": "Bearer $token",
//             },
//             body: jsonEncode(regBody));

//         print('Response body: ${response.body}');
//         var jsonResponse = jsonDecode(response.body);

//         print("http request made");

//         if (jsonResponse['status']) {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (context) => InterestsPage()));
//         } else {
//           print("Something went wrong");
//         }
//       } catch (e) {
//         print('Error during HTTP request: $e');
//       }
//     } else {
//       print('Major or Grad date is empty');
//       LoginPageState.buildDialog(
//           context, "Registration failed!", "Major & Grad Date are required!");
//     }
//   }

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   final List<String> pronouns = ['He/Him', 'She/Her', 'They/Them', 'Other'];
//   final List<String> genders = ['Male', 'Female', 'Non-Binary', 'Other'];


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           color: Colors.black,
//           onPressed: () {
//             if (_selectedMajor != null &&
//                 _selectedMajor!.isNotEmpty &&
//                 _selectedGradDate != null &&
//                 _selectedMajor!.isNotEmpty) {
//               Navigator.of(context).pop();
//             } else {
//               LoginPageState.buildDialog(context, "Registration failed!",
//                   "Major & Grad Date are required!");
//             }
//           },
//         ),

//       ),

      
//       body: SingleChildScrollView(
//         child: Column(
          
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 8.0),
//             buildTextField("", fullNameController),
//             const SizedBox(height: 8.0),
//             buildTextFieldPref("", prefNameController),
//             buildCheckBox("Display Name on Profile", displayNameOnProfile,
//                 (value) {
//               setState(() {
//                 displayNameOnProfile = value ?? false;
//               });
//             }),
        
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40.0), // Adjust padding as needed
//             child:Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: buildDropDown(
//                       "Gender*",
//                       ['Male', 'Female', 'Other'],
//                       _selectedGender,
//                       (newValue) {
//                         setState(() {
//                           _selectedGender = newValue;
//                         });
//                       },
//                       width: 150,
//                        // Set desired width for Gender dropdown
//                     ),
//                   ),
//                   const SizedBox(width: 15), // Space between dropdowns
//                   Expanded(
//                     child: buildDropDown(
//                       "Pronouns*",
//                       ['He/Him', 'She/Her', 'They/Them'],
//                       _selectedPronouns,
//                       (newValue) {
//                         setState(() {
//                           _selectedPronouns = newValue;
//                         });
//                       },
//                       width: 150, // Set desired width for Pronouns dropdown
//                     ),
//                   ),
//                 ],
//               ),
//           ),
//             const SizedBox(height: 10,),
//             buildProfileIcon(),


//             buildDropDown("Major*", majors, _selectedMajor, (newValue) {
//               setState(() {
//                 _selectedMajor = newValue;
//               });
//             }),
//             const SizedBox(height: 8.0),
//             buildDropDown("Minor", minors, _selectedMinor, (newValue) {
//               setState(() {
//                 _selectedMinor = newValue;
//               });
//             }),
//             const SizedBox(height: 8.0),
//             buildDropDown("Expected Graduation Year*", years, _selectedGradDate,
//                 (newValue) {
//               setState(() {
//                 _selectedGradDate = newValue;
//               });
//             }),
//             const SizedBox(height: 10),
//             buildTextArea(),
//             LoginPageState.buildMainButton("Next", context,
//                 (BuildContext context) {
//               addInfoToUser(context);
//             }),
//           ],
//         ),
//       ),
//     );
//   }






//   // Widget for TextFields
//   Widget buildTextField(String label, TextEditingController fieldController) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text label
//         Text(
//           label,
//           style: GoogleFonts.raleway(
//             fontSize: 16,
//             fontWeight: FontWeight.w800,
//             color: Colors.black,
//           ),
//           textAlign: TextAlign.start,
//         ),
//         // Text field
//         SizedBox(
//           width: 327,
//           height: 43,
//           child: TextField(
//             controller: fieldController,
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//                 labelText: "Full Name",
//                 labelStyle: TextStyle(color: Color(0xff939393), fontSize: 18) ,
//                 filled: true,
//                 fillColor:Color(0xffDDDDDD),
//                 border: OutlineInputBorder(
//                 borderSide: BorderSide.none,
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//             textAlign: TextAlign.start,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildTextFieldPref(String label, TextEditingController fieldController) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text label
//         Text(
//           label,
//           style: GoogleFonts.raleway(
//             fontSize: 16,
//             fontWeight: FontWeight.w800,
//             color: Colors.black,
//           ),
//           textAlign: TextAlign.start,
//         ),
//         // Text field
//         SizedBox(
//           width: 327,
//           height: 43,
//           child: TextField(
//             controller: fieldController,
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//                 labelText: "Preferred Name",
//                 labelStyle: TextStyle(color: Color(0xff939393), fontSize: 18) ,
//                 filled: true,
//                 fillColor:Color(0xffDDDDDD),
//                 border: OutlineInputBorder(
//                 borderSide: BorderSide.none,
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//             textAlign: TextAlign.start,
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget for Display Name on Profile checkbox
//   Widget buildCheckBox(
//       String label, bool currentVal, Function(bool?) onChanged) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 15, top: 0, right: 5),
//           child: CheckboxListTile(
//             title: Text(
//               label,
//               style: GoogleFonts.raleway(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.black,
//               ),
//             ),
//             value: currentVal, // Set default value of checkbox to false
//             onChanged: onChanged,
//             controlAffinity: ListTileControlAffinity.leading,
//             activeColor: const Color(0xFF3B5F43),
//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   // static List <String> list = <String> ['male', 'female', 'other', 'perfer not to say'];








//   // Widget for Profile Icon upload section
//   Widget buildProfileIcon() {
//     return Center(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Profile Icon. Check if image is uploaded or not
//           _imageFile != null
//               ? CircleAvatar(
//                   backgroundImage: FileImage(_imageFile!),
//                   radius: 37.5,
//                 )
//               : Image.asset(
//                   'assets/images/user_profile_icon.png',
//                   width: 75.0,
//                   height: 75.0,
//                 ),
//           // Padding in between image and column
//           const SizedBox(width: 20),
//           // Column that contains text and upload button
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text
//               Text(
//                 "Profile Icon",
//                 style: GoogleFonts.raleway(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.start,
//               ),
//               // Padding in between text and button
//               const SizedBox(height: 10),
//               // Upload button
//               SizedBox(
//                 width: 239,
//                 height: 43,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     pickImage();
//                   },
                  
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xffDDDDDD),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(11.0),
//                       side: const BorderSide(
//                         color: Color(0xffDDDDDD)
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     "Select",
//                     style: GoogleFonts.raleway(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.black,
//                     ),
//                     textAlign: TextAlign.start,
//                   ),
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }

 






// Widget buildDropDown(String label, List<String> items, String? selectedValue, Function(String?) onChanged, {double? width}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: GoogleFonts.raleway(
//           fontSize: 16,
//           fontWeight: FontWeight.w800,
//           color: Colors.black,
//         ),
//         textAlign: TextAlign.start,
//       ),
//       const SizedBox(height: 8),
//       SizedBox(
//         width: width ?? 327, // Use the passed width or default to 327
//         height: 60,
//         child: DropdownButtonFormField<String>(
//           decoration: InputDecoration(
            
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             filled: true,
//             fillColor: const Color(0xffDDDDDD),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(11),
//               borderSide: BorderSide.none,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(11),
//               borderSide: BorderSide.none,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(11),
//               borderSide: BorderSide(color: Colors.green),
//             ),
//           ),
//           icon: const Icon(
//             Icons.arrow_drop_down,
//             color: Color(0xff939393),
//           ),
//           value: selectedValue,
//           dropdownColor: Colors.white,
//           items: items.map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.black,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     ],
//   );
// }

// DropdownMenuItem<String> buildDropDownItem(String value) {
//   return DropdownMenuItem<String>(
//     value: value,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       width: 150, // Adjust width to match the dropdown itself
//       child: Text(
//         value,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//           color: Colors.black,
//         ),
//         textAlign: TextAlign.start,
//         overflow: TextOverflow.ellipsis,
//       ),
//     ),
//   );
// }

//   // Widget for Bio TextArea, uses multiple lines
//   Widget buildTextArea() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: TextField(
//         controller: bioController,
//         maxLines: 4,
//         decoration: InputDecoration(
//           labelText: 'Type here',
//           filled: true,
//           fillColor: const Color(0xffDDDDDD),
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(11),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         ),
//       ),
//     );
//   }
// /* Widget buildButton(String label, BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Container(
//           width: 329,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             color: const Color(0xFF3B5F43),
//           ),
//           child: TextButton(
//             onPressed: () {
//               addInfoToUser(context, widget.userID);
//             },
//             child: Text(
//               label,
//               style: GoogleFonts.raleway(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// */
// }


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
      print("Regbody: $regBody");

      try {
        var response = await http.put(Uri.parse(updateUser),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(regBody));

        print('Response body: ${response.body}');
        var jsonResponse = jsonDecode(response.body);

        print("http request made");

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Align all children to the start
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: buildDropDown(
                      "Gender*",
                      genders,
                      _selectedGender,
                      (newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      width: 150,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: buildDropDown(
                      "Pronouns*",
                      pronouns,
                      _selectedPronouns,
                      (newValue) {
                        setState(() {
                          _selectedPronouns = newValue;
                        });
                      },
                      width: 150,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildProfileIcon(),
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
                addInfoToUser(context);
              }),
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
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 43,
          child: TextField(
            controller: fieldController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Color(0xff939393), fontSize: 18),
              filled: true,
              fillColor: Color(0xffDDDDDD),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(11),
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
  Widget buildCheckBox(String label, bool currentVal, Function(bool?) onChanged) {
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
            value: currentVal,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFF3B5F43),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

 
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
          const SizedBox(width: 20),
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
                    backgroundColor: Color(0xffDDDDDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.0),
                      side: const BorderSide(
                        color: Color(0xffDDDDDD)
                      ),
                    ),
                  ),
                  child: Text(
                    "Select",
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

 



  // Widget for Dropdown menu
  Widget buildDropDown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?)? onChanged, {
    double width = 150.0,
  }) {
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
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffDDDDDD),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            dropdownColor: const Color(0xffDDDDDD), // background color of the dropdown
            iconEnabledColor: Colors.green, // green arrow color
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  // Widget for TextArea
  Widget buildTextArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tell us about yourself!",
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 100,
          child: TextField(
            controller: bioController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "Type here...",
              hintStyle: TextStyle(color: Color(0xff939393), fontSize: 18),
              filled: true,
              fillColor: Color(0xffDDDDDD),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(11),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Adjusted vertical padding
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  String getUserIDFromToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['userId'];
  }
}


