import 'dart:typed_data';

import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:bronco_bond/src/screens/edit_profile.dart';
import 'package:bronco_bond/src/screens/settings_page.dart';
import 'package:bronco_bond/src/screens/friends_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  late String fullName = '';
  late String username = '';
  late String pronouns = '';
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
  late ExpansionTileController _experienceController;
  late ExpansionTileController _clubsController;
  late ExpansionTileController _interestsController;
  late Future<SharedPreferences> prefsFuture;
  late SharedPreferences prefs;
  bool _experienceExpanded = false;
  bool _clubsExpanded = false;
  bool _interestsExpanded = false;
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
    _experienceController = ExpansionTileController();
    _clubsController = ExpansionTileController();
    _interestsController = ExpansionTileController();

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
    // print('UserID: ${widget.userID}');
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
        if (mounted) {
          setState(() {
            fullName = userData['user']['fullName'] ?? 'Unknown';
            username = userData['user']['username'] ?? 'Unknown';
            pronouns = userData['user']['pronouns'] ?? 'Unknown';
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
        //print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void sendRequest(String userID) async {
    String? token = prefs.getString('token');
    // User id of the person you want to follow in the body
    var regBody = {"_id": userID};

    try {
      var response = await http.put(Uri.parse(sendBondRequest),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
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

  void unbond(String userID) async {
    String? token = prefs.getString('token');
    // User id of the person you want to follow in the body
    var regBody = {"_id": userID};

    try {
      var response = await http.delete(Uri.parse(unbondUser),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
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

  void revokeRequest(String userID) async {
    String? token = prefs.getString('token');
    // User id of the person you want to follow in the body
    var regBody = {"_id": userID};

    try {
      var response = await http.put(Uri.parse(revokeBondRequest),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(regBody));

      print(response.body);

      print('Revoked bond request to user: $userID');
      setState(() {
        isRequested = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: FutureBuilder(
                future: prefsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    prefs = snapshot.data as SharedPreferences;
                    isCurrentUserProfile = widget.userID == currentUserID;
                    return Container(
                      color: const Color(0xff435f49),
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16.0, top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isCurrentUserProfile) ...[
                            Text(
                              username,
                              style: GoogleFonts.raleway(
                                textStyle:
                                    Theme.of(context).textTheme.displaySmall,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
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
                              color: Colors.white,
                            ),
                          ] else ...[
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                username,
                                style: GoogleFonts.raleway(
                                  textStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Add your desired action here
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox(); // Return empty box while loading
                  }
                },
              ),
            ),
            FutureBuilder(
              future: prefsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xff3B5F43)),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  final prefs = snapshot.data;
                  if (prefs != null) {
                    return buildUserProfile(prefs);
                  } else {
                    return const Center(
                      child: Text('SharedPreferences is null'),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserProfile(SharedPreferences prefs) {
    bool isCurrentUserProfile = widget.userID == currentUserID;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/header_bg.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: [
                      buildProfileHeader(context, isCurrentUserProfile,
                          widget.userID, currentUserID),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: TabBar(
                              overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              dividerColor: Colors.transparent,
                              tabAlignment: TabAlignment.start,
                              labelStyle: GoogleFonts.raleway(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                              labelColor: const Color(0xFF3B5F43),
                              indicator: UnderlineTabIndicator(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 10, color: Color(0xFFFED154)),
                              ),
                              indicatorColor: Colors.transparent,
                              unselectedLabelColor: Colors.grey,
                              indicatorWeight: 7,
                              controller: _tabController,
                              tabs: const [
                                Tab(text: 'About'),
                                Tab(text: 'Posts'),
                              ],
                              isScrollable:
                                  true, // Add this line to make the tabs scrollable
                              indicatorPadding:
                                  EdgeInsets.zero, // Add this line to remove
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        body: AutoScaleTabBarView(
          controller: _tabController,
          children: [
            // Content for About tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildAboutContent(),
                  ],
                ),
              ),
            ),
            // Content for Posts tab
            buildPosts(),
          ],
        ),
      ),
    );
  }

  Widget buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInfoBar(),
        buildAboutSection("Experience", "Add Experiences",
            "Showcase professional experiences...", _experienceController),
        buildAboutSection("Clubs", "Add Clubs",
            "Showcase clubs you participated in...", _clubsController),
        // Interests section
        Theme(
          data: ThemeData(splashColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              "Interests",
              style: GoogleFonts.raleway(
                color: const Color(0xFF2E4233),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            onExpansionChanged: (bool expanded) {
              setState(() {
                _interestsExpanded = expanded;
              });
            },
            trailing: Icon(_interestsExpanded ? Icons.remove : Icons.add),
            shape: Border(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0, // padding between each button
                  runSpacing: 10.0, // padding between each row of buttons
                  children: interests.map((interest) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xfffed154),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15.0),
                      child: Text(
                        interest,
                        style: GoogleFonts.raleway(
                            fontSize: 14,
                            color: const Color(0xff435f49),
                            fontWeight: FontWeight.w700),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

// Use template for now until user can add more to their page
  Widget buildAboutSection(String title, String buttonLabel, String description,
      ExpansionTileController controller) {
    bool isExperienceController = controller == _experienceController;
    bool isClubsController = controller == _clubsController;

    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          title,
          style: GoogleFonts.raleway(
            color: const Color(0xFF2E4233),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            if (isExperienceController) {
              _experienceExpanded = expanded;
            } else if (isClubsController) {
              _clubsExpanded = expanded;
            }
          });
        },
        trailing: Icon(
          isExperienceController
              ? _experienceExpanded
                  ? Icons.remove
                  : Icons.add
              : isClubsController
                  ? _clubsExpanded
                      ? Icons.remove
                      : Icons.add
                  : Icons.add,
          color: const Color(0xFF2E4233),
        ),
        shape: Border(),
        controller: controller,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            backgroundColor: Color(0xFFDDDDDD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 0.0,
                          ),
                          child: Text(
                            buttonLabel,
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E4233),
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
                    color: const Color(0xFF2E4233),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildProfileHeader(BuildContext context, bool isCurrentUserProfile,
      String profileUserID, String? currentUserID) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: screenWidth * 0.85, // Set the width to 80% of the screen width
        decoration: ShapeDecoration(
          color: const Color(0xFF2E4233),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              top: 20.0, bottom: 20.0, right: 25.0, left: 25.0),
          child: Column(
            children: [
              SizedBox(
                width: screenWidth *
                    0.25, // Set the width to 30% of the screen width
                child: CircleAvatar(
                  radius: 50, // Increase the radius to make the picture bigger
                  backgroundColor: Colors.white,
                  backgroundImage: profilePictureData.isNotEmpty
                      ? MemoryImage(pfp)
                      : const AssetImage('assets/images/user_profile_icon.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                fullName,
                style: GoogleFonts.raleway(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 11),
              // Apply maximum width constraint and handle overflow
              Text(
                pronouns,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF55685A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: screenWidth *
                          0.03), // Set the width to 3% of the screen width
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatColumn('Posts', 0),
                        SizedBox(
                            width: screenWidth *
                                0.05), // Increase the width to create more space
                        buildBondsStat('Bonds', numOfBonds, widget.userID,
                            isCurrentUserProfile),
                        SizedBox(
                            width: screenWidth *
                                0.03), // Increase the width to create more space
                        buildStatColumn('Interests', 0),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              // Check if this is the current user, if not then show a follow button
              if (!isCurrentUserProfile)
                buildOtherProfileButtons(widget.userID, currentUserID),
              if (isCurrentUserProfile) buildEditProfileButton(currentUserID),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.raleway(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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
                backgroundColor: const Color(0xFF2E4233),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Column(
                children: [
                  Text(
                    value.toString(),
                    style: GoogleFonts.raleway(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
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
          Row(
            children: [
              const ImageIcon(AssetImage('assets/images/book_4.png'),
                  color: const Color(0xFF435E49)),
              const SizedBox(width: 10),
              Text(
                descriptionMajor,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF435E49),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Row(
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: const Color(0xFF435E49),
                ),
                const SizedBox(width: 10),
                Text(
                  'Class of $graduationDate',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF435E49),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              descriptionBio,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF435E49),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPosts() {
    // Replace this with your logic to display user posts
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GridView.builder(
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
      ),
    );
  }

  Widget buildOtherProfileButtons(String userID, String? currentUserID) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildBondButton(userID, currentUserID),
        SizedBox(
          width: 130,
          height: 51,
          child: ElevatedButton(
            onPressed: () {
              // Add your follow button logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF435F49),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              "Message",
              style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
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
    Color buttonColor = const Color(0xFFFED154);
    Color textColor = const Color(0xFF435F49);
    if (isBonded) {
      // if users are bonded already, show "unbond"
      buttonText = 'Unbond';
      buttonColor = const Color(0xFFABABAB);
      textColor = Colors.white;
    } else if (isRequested) {
      // if users are only requested but not friends, show "requested"
      buttonText = 'Requested';
      buttonColor = const Color(0xFFABABAB);
      textColor = Colors.white;
    } else {
      // if users are not bonded, show "bond"
      buttonText = 'Bond';
    }

    return SizedBox(
      width: isRequested ? 145 : 130,
      height: 51,
      child: ElevatedButton(
        onPressed: () {
          if (isBonded) {
            unbond(userID);
          } else if (isRequested) {
            revokeRequest(userID);
          } else {
            sendRequest(userID);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
                  backgroundColor: Color(0xFF435E49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: const BorderSide(
                      color: Color(0xFF435E49),
                    ),
                  ),
                  padding: const EdgeInsets.all(
                      12.0), // Add padding to increase space around the text
                ),
                child: Text(
                  "Edit Profile",
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
