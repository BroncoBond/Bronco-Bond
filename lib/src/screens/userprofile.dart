import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bronco_bond/src/config.dart';

class UserProfile extends StatefulWidget {
  final userID;

  const UserProfile({Key? key, required this.userID}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late String username = '';
  late TabController _tabController;
  late Future<SharedPreferences> prefsFuture;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();
    _tabController = TabController(length: 2, vsync: this);

    prefsFuture.then((value) {
      prefs = value;
      // Get user data using the userID
      fetchDataUsingUserID(widget.userID, prefs);
    });
    print('UserID: ${widget.userID}');
  }

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDataUsingUserID(
      String userID, SharedPreferences prefs) async {
    try {
      final response = await http.get(Uri.parse('${getUserByID}/$userID'));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
        });

        // Check if this is the current user or not
        if (userID == prefs.getString('userID')) {
          print('This is the current user\'s profile');
        } else {
          print('This is someone else\'s profile');
        }
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BroncoBond',
          style: GoogleFonts.raleway(
            textStyle: Theme.of(context).textTheme.displaySmall,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3B5F43),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('tab bar pressed');
            },
            icon: Icon(Icons.settings_rounded),
            color: const Color(0xFF3B5F43),
          ),
        ],
      ),
      body: FutureBuilder(
        future: prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            SharedPreferences prefs = snapshot.data as SharedPreferences;
            return buildUserProfile(prefs);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildUserProfile(SharedPreferences prefs) {
    return Column(
      children: [
        buildProfileHeader(),
        buildInfoBar(),
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
    return Align(
      alignment: Alignment.centerLeft,
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
    bool isCurrentUserProfile = widget.userID == prefs.getString('userID');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 30),
          Column(
            children: [
              Image.asset(
                'assets/images/user_profile_icon.png',
                width: 75.0,
                height: 75.0,
              ),
              SizedBox(height: 5),
              Text(
                username,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(width: 60),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStatColumn('Posts', '0'),
              SizedBox(width: 20),
              buildStatColumn('Bonds', '0'),
              SizedBox(width: 20),
              buildStatColumn('Interests', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
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
            padding: EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.auto_stories_outlined),
                SizedBox(width: 10),
                Text("B.A. Visual Communication Design"),
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
                Text("Class of 2027 (Spring)"),
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
}
