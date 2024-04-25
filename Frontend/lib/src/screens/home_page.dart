import 'dart:typed_data';

import 'package:bronco_bond/src/config.dart';
import 'package:bronco_bond/src/screens/friends_list_page.dart';
import 'package:bronco_bond/src/screens/services.dart';
import 'package:bronco_bond/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final userID;
  const HomePage({@required this.userID, Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late String username = '';
  late List<dynamic> bonds = [];
  late SharedPreferences prefs;
  late Future<SharedPreferences> prefsFuture;
  int selectedUserIndex = -1;

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

      // print('Request URL: ${Uri.parse('$getUserByID/$userID')}'); // Debug URL
      // print('Token used: $token'); // Debug token

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
          bonds = userData['user']['bonds'] ?? [];
        });
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBondUsernames(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"_id": userID};
    try {
      final response = await http.post(
        Uri.parse(getUserByID),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return userData;
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  Uint8List decodeProfilePicture(dynamic profilePicture) {
    List<int> profilePictureData =
        List<int>.from(profilePicture['data']['data']);
    List<int> decodedImageBytes =
        base64Decode(String.fromCharCodes(profilePictureData));
    return Uint8List.fromList(decodedImageBytes);
  }

  void navigateToUserProfile(String userID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(userID: userID)),
    );
  }

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();
    prefsFuture.then((value) {
      prefs = value;
      // Get user data using the userID
      fetchDataUsingUserID(widget.userID);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'BroncoBond',
            style: GoogleFonts.raleway(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
          backgroundColor: const Color(0xFF3B5F43),
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            labelColor: Color(0xffFED053),
            indicatorColor: Color(0xffFED053),
            unselectedLabelColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'My Bonds'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Welcome ',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '$username!',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B5F43),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildTabContentForYou('Tab 1'),
                  buildBondsTab(bonds),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String tabName) {
    return ListView(
      children: [
        buildCard(tabName, 'Card 1'),
        buildCard(tabName, 'Card 2'),
        buildCard(tabName, 'Card 3'),
        // Add more cards as needed
      ],
    );
  }

  Widget buildCard(String tabName, String cardName) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(cardName),
        subtitle: Text('Subtitle for $cardName in $tabName'),
        onTap: () {
          // Handle card tap
          print('Tapped on $cardName in $tabName');
        },
      ),
    );
  }

    Widget buildTabContentForYou(String tabName) {
    return ListView(
      children: [
        buildCardForYou(
            tabName,
            'Study Abroad 101',
            'Office of Study Abroad',
            'Thursday, April 25 2024 at 12:00',
            'Online',
            'assets/images/Abroad.png'),
        buildCardForYou(
            tabName,
            'Library Therapy Dogs',
            'University Library',
            'Thursday, April 25 2024 at 3:00 PM',
            'University Library, 2nd Floor, Bronco Community Zone',
            'assets/images/Dog.png'),
        buildCardForYou(
            tabName,
            'eSports Tournament feat. Rocket League',
            'Associated Students Incorparated',
            'Friday, April 26 2024 at 1:00 PM PDT',
            'Games Room Etc.',
            'assets/images/Esport.png'),
        // Add more cards as needed
      ],
    );
  }

    Widget buildCardForYou(String tabName, String cardName, String Organization, String Date,
      String location, String assetPath) {
      return Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 500.0, // set width
              height: 200.0, // set height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),// set border color and width
              ),
              child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
            ListTile(
              title: RichText(
                text: TextSpan(
                  text: cardName,
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                        text: '\nOrganization: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '$Organization', style: TextStyle(fontWeight: FontWeight.normal)),
                    TextSpan(
                        text: '\nDate: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '$Date', style: TextStyle(fontWeight: FontWeight.normal)),
                    TextSpan(
                        text: '\nLocation: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: location, style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              onTap: () {
                // Handle card tap
                print('Tapped on $cardName in $tabName');
              },
            ),
          ],
        ),
      );
  }

  Widget buildBondsTab(List<dynamic> bonds) {
    if (bonds.isEmpty) {
      return const Center(
        child: Text('No bonds found'),
      );
    }
    return FutureBuilder(
      future: Future.wait(bonds.map((bond) => fetchBondUsernames(bond))),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff3B5F43)),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final userData = snapshot.data![index];
              final profilePicture = userData['user']['profilePicture'];
              final username = userData['user']['username'];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedUserIndex = index;
                    });
                    navigateToUserProfile(bonds[index]);
                  },
                  child: Container(
                    color: selectedUserIndex == index
                        ? Colors.grey.withOpacity(0.5) // Grey when tapped
                        : null, // Default background color when not tapped
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: profilePicture != null &&
                                profilePicture != ''
                            ? MemoryImage(decodeProfilePicture(profilePicture))
                            : const AssetImage(
                                    'assets/images/user_profile_icon.png')
                                as ImageProvider,
                      ),
                      title: Text(username ?? 'Unknown'),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
