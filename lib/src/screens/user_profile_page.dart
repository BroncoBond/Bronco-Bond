import 'dart:typed_data';

import 'package:bronco_bond/src/screens/edit_profile.dart';
import 'package:bronco_bond/src/screens/settings_page.dart';
import 'package:bronco_bond/src/screens/friends_list_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class UserProfile extends StatefulWidget {
  final userID;

  const UserProfile({Key? key, required this.userID}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late String username = '';
  late int numOfBonds = 0;
  late String descriptionMajor = '';
  late String descriptionBio = '';
  late String graduationDate = '';
  late List<dynamic> bonds = [];
  late List<dynamic> bondRequests = [];
  late List<dynamic> interests = [];
  late List<int> profilePictureData;
  late String profilePictureContentType;
  late Uint8List pfp;
  late TabController _tabController;
  late Future<SharedPreferences> prefsFuture;
  late SharedPreferences prefs;
  String? currentUserID;
  bool isCurrentUserProfile = false;
  late Timer timer;
  bool isBonded = false;
  bool isRequested = false;

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();
    _tabController = TabController(length: 2, vsync: this);

    pfp = Uint8List(0);
    profilePictureData = [];

    prefsFuture.then((value) {
      prefs = value;
      currentUserID = prefs.getString('userID');
      // Get user data using the userID
      fetchDataUsingUserID(widget.userID, currentUserID);
      // Timer to fetch data periodically (commented out so backend isn't constantly running during testing)
      /*timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        fetchDataUsingUserID(widget.userID, currentUserID);.
      });*/
    });
    print('UserID: ${widget.userID}');
  }

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    //timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDataUsingUserID(
      String userID, String? currentUserID) async {
    try {
      final response = await http.get(Uri.parse('$getUserByID/$userID'));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        if (mounted) {
          setState(() {
            username = userData['user']['username'] ?? 'Unknown';
            numOfBonds = userData['user']['numOfBonds'] ?? 0;
            descriptionMajor =
                userData['user']['descriptionMajor'] ?? 'Unknown';
            descriptionBio = userData['user']['descriptionBio'] ?? 'Unknown';
            graduationDate = userData['user']['graduationDate'] ?? 'Unknown';
            interests = userData['user']['interests'] ?? [];
            bonds = userData['user']['bonds'] ?? [];
            bondRequests = userData['user']['bondRequestsReceived'] ?? [];
            isBonded = bonds.contains(currentUserID);
            isRequested = bondRequests.contains(currentUserID);

            late dynamic profilePicture =
                userData['user']['profilePicture'] ?? '';
            if (profilePicture != null && profilePicture != '') {
              profilePictureData =
                  List<int>.from(profilePicture['data']['data']);
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
        }
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void sendRequest(String userID, String? currentUserID) async {
    // User id of the person you want to follow in the body
    var regBody = {"_id": userID};

    try {
      var response = await http.put(
          Uri.parse('$sendBondRequest/$currentUserID'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      print(response.body);

      setState(() {
        isRequested =
            true; // set to "requested" when pressed if bonded is false.
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void unbond(String userID, String? currentUserID) async {
    // User id of the person you want to follow in the body
    var regBody = {"_id": userID};

    try {
      // Current user id is in route
      print('Current User: $currentUserID');
      print('User you want to follow: $userID');

      var response = await http.delete(Uri.parse('$unbondUser/$currentUserID'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      print(response.body);

      print('Unfollowed user: $userID');
      setState(() {
        isBonded = false;
        isRequested = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //bool isCurrentUserProfile = widget.userID == prefs?.getString('userID');
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FutureBuilder(
          future: prefsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              prefs = snapshot.data as SharedPreferences;
              isCurrentUserProfile = widget.userID == currentUserID;
              if (isCurrentUserProfile) {
                return AppBar(
                  title: Text(
                    'BroncoBond',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displaySmall,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF3B5F43),
                  leadingWidth: 0.0,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_rounded),
                        color: Colors.white // const Color(0xFF3B5F43),
                        ),
                  ],
                );
              } else {
                return AppBar(
                  title: Text(
                    'BroncoBond',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displaySmall,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3B5F43),
                    ),
                  ),
                  leadingWidth: 40.0,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                    ),
                  ),
                );
              }
            } else {
              return const SizedBox(); // Return empty box while loading
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff3B5F43)),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if ((snapshot.connectionState == ConnectionState.done)) {
            final prefs = snapshot.data;
            if (prefs != null) {
              return buildUserProfile(prefs);
            } else {
              // Handle the case where prefs is null
              return const Center(
                child: Text('SharedPreferences is null'),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildUserProfile(SharedPreferences prefs) {
    bool isCurrentUserProfile = widget.userID == currentUserID;
    return Column(
      children: [
        buildProfileHeader(isCurrentUserProfile),
        buildInfoBar(),
        // Check if this is the current user, if not then show a follow button
        if (!isCurrentUserProfile)
          buildOtherProfileButtons(widget.userID, currentUserID),
        if (isCurrentUserProfile) buildEditProfileButton(currentUserID),
        TabBar(
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          labelColor: const Color(0xFF3B5F43),
          indicatorColor: const Color(0xFF3B5F43),
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          controller: _tabController,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Posts'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Content for About tab
              buildAboutContent(),
              // Content for Posts tab
              buildPosts(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAboutContent() {
    return SingleChildScrollView(
      //alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAboutSection("Experience", "Add Experiences",
                "Showcase professional experiences..."),
            buildAboutSection(
                "Clubs", "Add Clubs", "Showcase clubs you participated in..."),
            // Interests section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Interests",
                  style: GoogleFonts.raleway(
                    color: const Color(0xFF3B5F43),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.0, // padding between each button
                    runSpacing: 8.0, // padding between each row of buttons
                    children: interests.map((interest) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              width: 1, color: const Color(0xFF3B5F43)),
                        ),
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// Use template for now until user can add more to their page
  Widget buildAboutSection(
      String title, String buttonLabel, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.raleway(
            color: const Color(0xFF3B5F43),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 7.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      //add function to add experience
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(
                          color: Color(0xFF3B5F43),
                        ),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    )),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileHeader(bool isCurrentUserProfile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: profilePictureData.isNotEmpty
                      ? MemoryImage(pfp)
                      : const AssetImage('assets/images/user_profile_icon.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 12),
                // Apply maximum width constraint and handle overflow
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 50),
          // SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStatColumn('Posts', 0),
              const SizedBox(width: 20),
              buildBondsStat(
                  'Bonds', numOfBonds, widget.userID, isCurrentUserProfile),
              const SizedBox(width: 20),
              buildStatColumn('Interests', 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget buildBondsStat(
      String label, int value, String userID, bool isCurrentUserProfile) {
    return IgnorePointer(
      ignoring: !isCurrentUserProfile,
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendsListPage(userID: userID),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFCFC),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Column(
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget buildInfoBar() {
    return Container(
      //margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 15.0),
            child: Text(descriptionBio),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.auto_stories_outlined),
                const SizedBox(width: 10),
                Text(descriptionMajor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.school_rounded),
                const SizedBox(width: 10),
                Text('Class of $graduationDate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPosts() {
    // Replace this with your logic to display user posts
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Image.network(
          'https://via.placeholder.com/150', // Replace with your image URLs
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget buildOtherProfileButtons(String userID, String? currentUserID) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildBondButton(userID, currentUserID),
        SizedBox(
          width: 180,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              // Add your follow button logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(
                  color: Color(0xFF3B5F43),
                ),
              ),
            ),
            child: const Text(
              "Message",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  /*
  * Builds the Bond button based off the status of the 2 users
  */
  Widget buildBondButton(String userID, String? currentUserID) {
    String buttonText = '';
    Color buttonColor = Color(0xFF3B5F43);
    Color textColor = Colors.white;
    if (isBonded) {
      // if users are bonded already, show "unbond"
      buttonText = 'Unbond';
      buttonColor = Color(0xFFABABAB);
    } else if (isRequested) {
      // if users are only requested but not friends, show "requested"
      buttonText = 'Requested';
      buttonColor = Color(0xFFABABAB);
    } else {
      // if users are not bonded, show "bond"
      buttonText = 'Bond';
    }

    return SizedBox(
      width: 180,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          if (isBonded) {
            unbond(userID, currentUserID);
          } else if (isRequested) {
            setState(() {
              isRequested = false;
            });
          } else {
            sendRequest(userID, currentUserID);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget buildEditProfileButton(String? currentUserID) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditProfile(userID: currentUserID)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(
                      color: Color(0xFF3B5F43),
                    ),
                  ),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
