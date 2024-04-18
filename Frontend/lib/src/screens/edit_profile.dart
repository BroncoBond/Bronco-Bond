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
  late String descriptionMajor = '';
  late String descriptionMinor = '';
  late String descriptionBio = '';
  late String graduationDate = '';
  late List<dynamic> interests = [];
  late List<int> profilePictureData;
  late String profilePictureContentType;
  late Uint8List pfp;
  File? _imageFile;

  final List<String> clubSuggestions = [
    'CSS',
    'sheCodes',
    'Flutter Club',
    'Coding Club',
    'Art Club'
  ];
  late TextEditingController _clubController;
  late TextEditingController _textController;
  List<String> selectedClubs = [];
  List<String> addedInterests = [];

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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.raleway(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            right: 130,
                            bottom: 0,
                            //left: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff3B5F43),
                                //border:
                                //Border.all(color: Colors.white, width: 3.0),
                              ),
                              child: Center(
                                child: IconButton(
                                  iconSize: 16,
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
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

                      // Rows for editing profile information
                      EditableRow(
                        label: 'Username',
                        initialValue: username,
                        userID: widget.userID,
                      ),
                      const Divider(
                          color: Colors.grey,
                          thickness: 1), // Add a horizontal line

                      EditableRow(
                        label: 'Full Name',
                        initialValue: fullName,
                        userID: widget.userID,
                      ),
                      const Divider(
                          color: Colors.grey,
                          thickness: 1), // Add a horizontal line

                      EditableRow(
                        label: 'Preferred Name',
                        initialValue: prefName,
                        userID: widget.userID,
                      ),
                      const Divider(
                          color: Colors.grey,
                          thickness: 1), // Add a horizontal line

                      EditableRow(
                        label: 'Major',
                        initialValue: descriptionMajor,
                        userID: widget.userID,
                      ),
                      const Divider(
                          color: Colors.grey,
                          thickness: 1), // Add a horizontal line

                      EditableRow(
                        label: 'Minor',
                        initialValue: descriptionMinor,
                        userID: widget.userID,
                      ),
                      const Divider(
                          color: Colors.grey,
                          thickness: 1), // Add a horizontal line

                      EditableRow(
                        label: 'Graduation Date',
                        initialValue: graduationDate,
                        userID: widget.userID,
                      ),
                      const Divider(
                          color: Colors.grey,
                          thickness: 1), // Add a horizontal line

                      EditableRow(
                        label: 'Bio',
                        initialValue: descriptionBio,
                        userID: widget.userID,
                      ),
                      const Divider(color: Colors.grey, thickness: 1),

                      const SizedBox(height: 10),
                      // Add space between profile info and selection widgets
                      AddTextWidget(
                        initialInterests: addedInterests,
                        onInterestsChanged: (interests) {
                          setState(() {
                            addedInterests = interests;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.grey),
                      // Selected clubs widget
                      const SizedBox(height: 20),
                      SelectedClubsList(
                        selectedClubs: selectedClubs,
                        onDelete: (club) {
                          setState(() {
                            selectedClubs.remove(club);
                          });
                        },
                      ), // Add space between selected clubs and added texts

                      // Added texts widge

                      const SizedBox(
                          height:
                              20), // Add space between added texts and selection dropdown

                      // Dropdown menu for club selection
                      DropdownButtonFormField<String>(
                        value: null,
                        items: clubSuggestions.map((String suggestion) {
                          return DropdownMenuItem<String>(
                            value: suggestion,
                            child: Text(suggestion),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              !selectedClubs.contains(newValue)) {
                            setState(() {
                              selectedClubs.add(newValue);
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Club',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}

class SelectedClubsList extends StatelessWidget {
  final List<String> selectedClubs;
  final void Function(String) onDelete;

  const SelectedClubsList(
      {Key? key, required this.selectedClubs, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Clubs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        if (selectedClubs.isEmpty)
          const Text(
            'No clubs selected',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedClubs
                .map((club) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(club),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              onDelete(club);
                            },
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
      ],
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
  late TextEditingController textController;
  String? _selectedMajor;
  String? _selectedMinor;
  String? _selectedGradDate;
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
      } else {
        _selectedGradDate = widget.initialValue;
      }
    }
  }

  @override
  void dispose() {
    textController.dispose();
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
      case 'Username':
        if (textController.text.isNotEmpty) {
          regBody["username"] = textController.text;
        } else {
          // empty username
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Username cannot be empty!"),
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
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(widget.label),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                if (widget.label == 'Major' ||
                    widget.label == 'Minor' ||
                    widget.label == 'Graduation Date')
                  buildDropDown(
                    widget.label == 'Major'
                        ? majors
                        : widget.label == 'Minor'
                            ? minors
                            : years,
                    widget.label == 'Major'
                        ? _selectedMajor
                        : widget.label == 'Minor'
                            ? _selectedMinor
                            : _selectedGradDate,
                    (newValue) {
                      setState(() {
                        if (widget.label == 'Major') {
                          _selectedMajor = newValue;
                        } else if (widget.label == 'Minor') {
                          _selectedMinor = newValue;
                        } else {
                          _selectedGradDate = newValue;
                        }
                      });
                    },
                  ),
                if (!(widget.label == 'Major' ||
                    widget.label == 'Minor' ||
                    widget.label == 'Graduation Date'))
                  TextFormField(
                    readOnly: !isEditing,
                    controller: textController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: isEditing
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: Color(0xff3B5F43)),
                            )
                          : InputBorder.none,
                      focusedBorder: isEditing
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: Color(0xff3B5F43), width: 1),
                            )
                          : InputBorder.none,
                    ),
                  ),
                if (isEditing)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.check_rounded),
                      color: const Color(0xff3B5F43),
                      onPressed: _saveChanges,
                    ),
                  )
                else
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      color: const Color(0xffABABAB),
                      onPressed: _toggleEdit,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropDown(
      List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 170,
          height: 43,
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue, // Set default value
            underline: Container(
              height: 1,
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
            onChanged: isEditing ? onChanged : null,
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
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class AddTextWidget extends StatefulWidget {
  final List<String> initialInterests;
  final void Function(List<String>) onInterestsChanged;

  const AddTextWidget({
    Key? key,
    required this.initialInterests,
    required this.onInterestsChanged,
  }) : super(key: key);

  @override
  _AddTextWidgetState createState() => _AddTextWidgetState();
}

class _AddTextWidgetState extends State<AddTextWidget> {
  late TextEditingController _textController;
  final List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _interests.addAll(widget.initialInterests);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Interests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        if (_interests.isEmpty)
          const Text(
            'No interests added',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _interests
                .map((interest) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(interest),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _interests.remove(interest);
                                widget.onInterestsChanged(_interests);
                              });
                            },
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Enter Interest',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (interest) {
            setState(() {
              _interests.add(interest);
              widget.onInterestsChanged(_interests);
              _textController.clear();
            });
          },
        ),
      ],
    );
  }
}
