import 'dart:typed_data';

import 'package:bronco_bond/src/screens/settings_page.dart';
import 'package:bronco_bond/src/screens/friends_list_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
  late List<int> profilePictureData;
  late String profilePictureContentType;
  late Uint8List pfp;
  late TabController _tabController;
  late Future<SharedPreferences> prefsFuture;
  late SharedPreferences prefs;
  late Timer timer;
  bool isBonded = false;

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();
    _tabController = TabController(length: 2, vsync: this);

    pfp = Uint8List(0);
    profilePictureData = [];

    prefsFuture.then((value) {
      prefs = value;
      String? currentUserID = prefs.getString('userID');
      // Get user data using the userID
      fetchDataUsingUserID(widget.userID, currentUserID);
      // Timer to fetch data periodically (commented out so backend isn't constantly running during testing)
      /*timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        fetchDataUsingUserID(widget.userID, currentUserID);
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
      final response = await http.get(Uri.parse('${getUserByID}/$userID'));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
          numOfBonds = userData['user']['numOfBonds'] ?? 0;
          descriptionMajor = userData['user']['descriptionMajor'] ?? 'Unknown';
          descriptionBio = userData['user']['descriptionBio'] ?? 'Unknown';
          graduationDate = userData['user']['graduationDate'] ?? 'Unknown';
          bonds = userData['user']['bonds'] ?? [];
          isBonded = bonds.contains(currentUserID);

          late dynamic profilePicture =
              userData['user']['profilePicture'] ?? '';
          if (profilePicture != null && profilePicture != '') {
            print('${profilePicture['contentType'].runtimeType}');
            print('${profilePicture['contentType']}');
            print('${profilePicture['data']['data'].runtimeType}');
            print('${profilePicture['data']['data']}');

            profilePictureData = List<int>.from(profilePicture['data']['data']);
            profilePictureContentType = profilePicture['contentType'];
            print('${profilePictureData}');
            List<int> decodedImageBytes =
                base64Decode(String.fromCharCodes(profilePictureData));
            //print('${decodedImageBytes}');
            pfp = Uint8List.fromList(decodedImageBytes);
            print('pfp: ${pfp}');
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

  void bond(String userID, String? currentUserID) async {
    // User id of the person you want to follow in the body
    var regBody = {"_id": userID};

    try {
      // Current user id is in route
      print('Current User: $currentUserID');
      print('User you want to follow: $userID');

      var response = await http.put(Uri.parse('$bondUser/$currentUserID'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      print('${response.body}');

      print('Now following user: $userID');
      setState(() {
        isBonded = true;
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

      print('${response.body}');

      print('Unfollowed user: $userID');
      setState(() {
        isBonded = false;
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
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: FutureBuilder(
          future: prefsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              prefs = snapshot.data as SharedPreferences;
              String? currentUserID = prefs.getString('userID');
              bool isCurrentUserProfile = widget.userID == currentUserID;
              if (isCurrentUserProfile) {
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
                  leadingWidth: 0.0,
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
                      icon: Icon(Icons.settings_rounded),
                      color: const Color(0xFF3B5F43),
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
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                    ),
                  ),
                );
              }
            } else {
              return SizedBox(); // Return empty box while loading
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
              child: Center(
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
            final prefs = snapshot.data as SharedPreferences?;
            if (prefs != null) {
              return buildUserProfile(prefs);
            } else {
              // Handle the case where prefs is null
              return Center(
                child: Text('SharedPreferences is null'),
              );
            }
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  Widget buildUserProfile(SharedPreferences prefs) {
    String? currentUserID = prefs.getString('userID');
    bool isCurrentUserProfile = widget.userID == currentUserID;
    return Column(
      children: [
        buildProfileHeader(),
        buildInfoBar(),
        // Check if this is the current user, if not then show a follow button
        if (!isCurrentUserProfile)
          buildOtherProfileButtons(widget.userID, currentUserID),
        TabBar(
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          labelColor: Color(0xFF3B5F43),
          indicatorColor: Color(0xFF3B5F43),
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          controller: _tabController,
          tabs: [
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Experience",
              style: GoogleFonts.raleway(
                color: const Color(0xFF3B5F43),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 400,
              height: 40,
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
                    "Add Experience",
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  )),
            ),
            SizedBox(height: 7),
            Text(
              "Showcase professional experiences...",
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            //clubs
            Text(
              "Clubs",
              style: GoogleFonts.raleway(
                color: const Color(0xFF3B5F43),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 400,
              height: 40,
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
                    "Add Clubs",
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  )),
            ),
            SizedBox(height: 7),
            Text(
              "Showcase clubs you participate in...",
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),

            //Interests
            SizedBox(height: 20),
            Text(
              "Interests",
              style: GoogleFonts.raleway(
                color: const Color(0xFF3B5F43),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 400,
              height: 40,
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
                    "Add Interests",
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  )),
            ),
            SizedBox(height: 7),
            Text(
              "Share your interests",
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ])),
    );
  }

  Widget buildProfileHeader() {
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
                  radius: 37.5,
                  backgroundColor: Colors.white,
                  backgroundImage: profilePictureData.isNotEmpty
                      ? MemoryImage(pfp)
                      : const AssetImage('assets/images/user_profile_icon.png')
                          as ImageProvider,
                ),
                SizedBox(height: 12),
                // Apply maximum width constraint and handle overflow
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 50),
          // SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStatColumn('Posts', 0),
              SizedBox(width: 20),
              buildBondsStat('Bonds', numOfBonds, widget.userID),
              SizedBox(width: 20),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget buildBondsStat(String label, int value, String userID) {
    return Column(
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
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero), // No padding
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
            ),
            child: Column(
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  label,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w400),
                ),
              ],
            )),
      ],
    );
  }

  @override
  Widget buildButton(String label) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            child: Text(label, style: TextStyle(fontSize: 15)),
            style: ButtonStyle(
                padding:
                    MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(12)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black)))),
            onPressed: () {
              print('${label} pressed');
            },
          )
        ]));
  }

  Widget buildInfoBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(descriptionBio),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.auto_stories_outlined),
                SizedBox(width: 10),
                Text(descriptionMajor),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.school_rounded),
                SizedBox(width: 10),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 180,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                isBonded
                    ? unbond(userID, currentUserID)
                    : bond(userID, currentUserID);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBonded ? Colors.grey : Color(0xFF3B5F43),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                isBonded ? "Unbond" : "Bond",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBonded ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 180,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // Add your follow button logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFABABAB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "Message",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
