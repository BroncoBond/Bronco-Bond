import 'dart:ui';

import 'package:bronco_bond/src/config.dart';
import 'package:bronco_bond/src/school_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class EditProfile extends StatefulWidget {
  final userID;

  const EditProfile({Key? key, required this.userID}) : super(key: key);

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfile> {
  late SharedPreferences prefs;
  late Future<SharedPreferences> prefsFuture;
  Future<void>? _dataFuture;
  late String username = '';
  late String fullName = '';
  late String prefName = '';
  late String pronouns = '';
  late String gender = '';
  late String descriptionMajor = '';
  late String descriptionMinor = '';
  late String descriptionBio = '';
  late String graduationDate = '';
  late List<dynamic> interests = [];
  late List<int> profilePictureData;
  late String profilePictureContentType;
  late Uint8List pfp;
  File? _imageFile;

  late TextEditingController _clubController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();

    pfp = Uint8List(0);
    profilePictureData = [];

    _initData();
  }

  @override
  void dispose() {
    _clubController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    prefs = await prefsFuture;
    await fetchDataUsingUserID(widget.userID);

    _dataFuture = fetchDataUsingUserID(widget.userID);
    _clubController = TextEditingController();
    _textController = TextEditingController();
  }

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> fetchDataUsingUserID(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"_id": userID};
    try {
      final response = await http.post(
        Uri.parse(getUserByID),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
          fullName = userData['user']['fullName'] ?? 'Unknown';
          prefName = userData['user']['prefName'] ?? 'Unknown';
          pronouns = userData['user']['pronouns'] ?? 'Unknown';
          gender = userData['user']['gender'] ?? 'Unknown';
          descriptionMajor = userData['user']['descriptionMajor'] ?? 'Unknown';
          descriptionMinor = userData['user']['descriptionMinor'] ?? 'Unknown';
          descriptionBio = userData['user']['descriptionBio'] ?? 'Unknown';
          graduationDate = userData['user']['graduationDate'] ?? 'Unknown';
          interests = userData['user']['interests'] ?? [];

          late dynamic profilePicture =
              userData['user']['profilePicture'] ?? '';
          if (profilePicture != null && profilePicture != '') {
            //print('${profilePicture['contentType'].runtimeType}');
            //print('${profilePicture['contentType']}');
            //print('${profilePicture['data']['data'].runtimeType}');
            //print('${profilePicture['data']['data']}');

            profilePictureData = List<int>.from(profilePicture['data']['data']);
            profilePictureContentType = profilePicture['contentType'];
            //print('$profilePictureData');
            List<int> decodedImageBytes =
                base64Decode(String.fromCharCodes(profilePictureData));
            //print('${decodedImageBytes}');
            pfp = Uint8List.fromList(decodedImageBytes);
            //print('pfp: $pfp');
          } else {
            pfp = Uint8List(0);
          }
        });
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void editPfp(String userID) async {
    String base64Image = '';
    String? token = prefs.getString('token');

    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    var regBody = {
      "_id": userID,
      "profilePicture": _imageFile != null
          ? {"data": base64Image, "contentType": "image/jpeg"}
          : null
    };

    try {
      var response = await http.put(Uri.parse(updateUser),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(regBody));

      print('Response body: ${response.body}');
      var jsonResponse = jsonDecode(response.body);

      print("http request made");
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile picture uploaded successfully!"),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xff3B5F43)),
        );

        if (_imageFile != null) {
          setState(() {
            profilePictureData = List<int>.from(base64.decode(base64Image));
            profilePictureContentType = "image/jpeg";
            pfp = Uint8List.fromList(profilePictureData);
          });
        }
      } else {
        print("Something went wrong");
      }
    } catch (e) {
      print('Error during HTTP request: $e');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      editPfp(widget.userID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff435f49),
      body: FutureBuilder<void>(
          future: _dataFuture ?? Future.value(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff3B5F43)),
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    // App bar
                    Container(
                      color: const Color(0xff435f49),
                      child: Stack(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.raleway(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20), // Add space from the top

                    // Profile icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: profilePictureData.isNotEmpty
                                ? Image.memory(
                                    pfp,
                                    width: 110.0,
                                    height: 110.0,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/user_profile_icon.png',
                                    width: 110.0,
                                    height: 110.0,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          //top: 0,
                          right: 150,
                          bottom: 0,
                          //left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xfffed154),
                              //border:
                              //Border.all(color: Colors.white, width: 3.0),
                            ),
                            child: Center(
                              child: IconButton(
                                iconSize: 20,
                                icon: ImageIcon(
                                  AssetImage('assets/images/edit.png'),
                                  color: Color(0xff3B5F43),
                                ),
                                onPressed: () {
                                  pickImage();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 30), // Add space below the profile icon

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Rows for editing profile information
                          EditableRow(
                            label: 'User Name',
                            initialValue: username,
                            userID: widget.userID,
                          ),

                          EditableRow(
                            label: 'Full Name',
                            initialValue: fullName,
                            userID: widget.userID,
                          ),

                          EditableRow(
                            label: 'Preferred Name',
                            initialValue: prefName,
                            userID: widget.userID,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: EditableRow(
                                  label: 'Pronouns',
                                  initialValue: pronouns,
                                  userID: widget.userID,
                                ),
                              ),
                              Expanded(
                                child: EditableRow(
                                  label: 'Gender',
                                  initialValue: gender,
                                  userID: widget.userID,
                                ),
                              ),
                            ],
                          ),

                          EditableRow(
                            label: 'Major',
                            initialValue: descriptionMajor,
                            userID: widget.userID,
                          ),

                          EditableRow(
                            label: 'Minor',
                            initialValue: descriptionMinor,
                            userID: widget.userID,
                          ),

                          EditableRow(
                            label: 'Graduation Date',
                            initialValue: graduationDate,
                            userID: widget.userID,
                          ),

                          EditableRow(
                            label: 'Bio',
                            initialValue: descriptionBio,
                            userID: widget.userID,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

class EditableRow extends StatefulWidget {
  final String label;
  final String initialValue;
  final String userID;

  const EditableRow(
      {Key? key,
      required this.label,
      required this.initialValue,
      required this.userID})
      : super(key: key);

  @override
  State<EditableRow> createState() => _EditableRowState();
}

class _EditableRowState extends State<EditableRow> {
  bool isEditing = false;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController textController;
  String? _selectedMajor;
  String? _selectedMinor;
  String? _selectedGradDate;
  String? _selectedPronouns;
  String? _selectedGender;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    textController = TextEditingController(text: widget.initialValue);
    if (widget.initialValue != "Unknown") {
      if (widget.label == 'Major') {
        _selectedMajor = widget.initialValue;
      } else if (widget.label == 'Minor') {
        _selectedMinor = widget.initialValue;
      } else if (widget.label == 'Graduation Date') {
        _selectedGradDate = widget.initialValue;
      } else if (widget.label == 'Pronouns') {
        _selectedPronouns = widget.initialValue;
      } else {
        _selectedGender = widget.initialValue;
      }
    }
  }

  @override
  void dispose() {
    textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveChanges() async {
    String? token = prefs.getString('token');
    var regBody = {
      "_id": widget.userID,
    };

    print('${widget.label} has the text ${textController.text}');
    switch (widget.label) {
      case 'User Name':
        if (textController.text.isNotEmpty) {
          regBody["username"] = textController.text;
        } else {
          // empty username
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("User Name cannot be empty!"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red),
          );
        }
        break;
      case 'Full Name':
        regBody["fullName"] = textController.text;
        break;
      case 'Preferred Name':
        regBody["prefName"] = textController.text;
        break;
      case 'Major':
        regBody["descriptionMajor"] = _selectedMajor!;
        break;
      case 'Minor':
        regBody["descriptionMinor"] = _selectedMinor!;
        break;
      case 'Graduation Date':
        regBody["graduationDate"] = _selectedGradDate!;
        break;
      case 'Bio':
        regBody["descriptionBio"] = textController.text;
        break;
      case 'Pronouns':
        regBody["pronouns"] = _selectedPronouns!;
        break;
      case 'Gender':
        regBody["gender"] = _selectedGender!;
        break;
    }

    print(regBody);

    try {
      var response = await http.put(Uri.parse(updateUser),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(regBody));

      print('Response body: ${response.body}');
      var jsonResponse = jsonDecode(response.body);

      print("http request made");
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        // Changes saved
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Changes saved successfully!"),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xff3B5F43)),
        );
        _toggleEdit();
      } else {
        print("Something went wrong");
      }
    } catch (e) {
      print('Error during HTTP request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12.0,
        left: widget.label == 'Gender' ? 12.0 : 30.0,
        right: widget.label == 'Pronouns' ? 10.0 : 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.label,
                  style: GoogleFonts.raleway(
                      fontSize: 16.0,
                      color: const Color(0xff2e4233),
                      fontWeight: FontWeight.w700),
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.check_rounded),
                  color: const Color(0xff2e4233),
                  onPressed: _saveChanges,
                )
              else
                IconButton(
                  icon: const ImageIcon(
                    AssetImage('assets/images/edit.png'),
                  ),
                  color: const Color(0xffABABAB),
                  onPressed: _toggleEdit,
                ),
            ],
          ),
          if (widget.label == 'Major' ||
              widget.label == 'Minor' ||
              widget.label == 'Graduation Date' ||
              widget.label == 'Pronouns' ||
              widget.label == 'Gender')
            buildDropDown(
              widget.label == 'Major'
                  ? majors
                  : widget.label == 'Minor'
                      ? minors
                      : widget.label == 'Graduation Date'
                          ? years
                          : widget.label == 'Pronouns'
                              ? pronouns
                              : genders,
              widget.label == 'Major'
                  ? _selectedMajor
                  : widget.label == 'Minor'
                      ? _selectedMinor
                      : widget.label == 'Graduation Date'
                          ? _selectedGradDate
                          : widget.label == 'Pronouns'
                              ? _selectedPronouns
                              : _selectedGender,
              (newValue) {
                setState(() {
                  if (widget.label == 'Major') {
                    _selectedMajor = newValue;
                  } else if (widget.label == 'Minor') {
                    _selectedMinor = newValue;
                  } else if (widget.label == 'Graduation Date') {
                    _selectedGradDate = newValue;
                  } else if (widget.label == 'Pronouns') {
                    _selectedPronouns = newValue;
                  } else {
                    _selectedGender = newValue;
                  }
                });
              },
            )
          else
            TextFormField(
              readOnly: !isEditing,
              controller: textController,
              style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff939393)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xffdddddd),
                contentPadding: const EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: isEditing
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xff3B5F43), width: 2.5),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDropDown(
      List<String> items, String? selectedValue, Function(String?) onChanged) {
    String? dropdownValue =
        selectedValue?.isEmpty ?? true ? null : selectedValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          focusNode: _focusNode,
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(
                      0xffdddddd), // Set the background color of the button
                  borderRadius:
                      BorderRadius.circular(8.0), // Set the border radius
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xff3B5F43)
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: dropdownValue,
                  icon: const Padding(
                    padding: EdgeInsets.only(
                        right: 8.0), // Add padding to the right of the icon
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xff2e4233),
                    ),
                  ),
                  iconEnabledColor: const Color(0xff939393),
                  iconDisabledColor: const Color(0xff939393),
                  underline: const SizedBox(),
                  items: items.map((String value) {
                    return buildDropDownItem(value);
                  }).toList(),
                  onChanged: isEditing ? onChanged : null,
                  onTap: () {
                    _focusNode.requestFocus();
                  },
                ),
              );
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
        width: 300,
        child: Text(
          value,
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xff939393),
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
