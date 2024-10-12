import 'dart:typed_data';

import 'package:bronco_bond/src/config.dart';
import 'package:bronco_bond/src/screens/chat_page.dart';
import 'package:bronco_bond/src/screens/friends_list_page.dart';
import 'package:bronco_bond/src/screens/services.dart';
import 'package:bronco_bond/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatListPage extends StatefulWidget {
  final userID;
  const ChatListPage({@required this.userID, Key? key}) : super(key: key);

  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage>
    with SingleTickerProviderStateMixin {
  late String username = '';
  late List<dynamic> bonds = [];
  late SharedPreferences prefs;
  late Future<SharedPreferences> prefsFuture;
  int selectedUserIndex = -1;
  late TabController tabController;
  TextEditingController searchController = TextEditingController();

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
          bonds = (userData['user']['bonds'] ?? [])
              .where((bond) => bond['isOnline'] == '1')
              .toList();
          print(bonds);
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
      MaterialPageRoute(builder: (context) => ChatPage(userID: userID)),
    );
  }

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();
    tabController = TabController(length: 2, vsync: this);
    prefsFuture.then((value) {
      prefs = value;
      // Get user data using the userID
      fetchDataUsingUserID(widget.userID);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: const Color(0xff435f49),
          child: Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: SafeArea(
              child: TabBar(
                controller: tabController,
                unselectedLabelColor: Colors.white,
                dividerHeight: 0.0,
                dividerColor: const Color(0xff435f49),
                labelColor: const Color(0xFFFED154),
                labelStyle: GoogleFonts.raleway(
                    fontSize: 16.0, fontWeight: FontWeight.w700),
                indicatorColor: const Color(0xFFFED154),
                indicatorWeight: 7.0,
                tabs: const [
                  Tab(text: 'Chat'),
                  Tab(text: 'Bonds'),
                ],
                labelPadding:
                    const EdgeInsets.only(left: 55.0), // Adjust the value here
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xff435f49),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: TabBarView(
            controller: tabController,
            children: [
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xff435f49),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 30.0, bottom: 30.0, left: 25.0, right: 25.0),
                child: buildBondsTab(bonds),
              ),
            ],
          ),
        ),
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff435f49)),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Wrap the ListView.builder with a Container to constrain its height
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.8, // Adjust the height as needed
            ),
            child: ListView.builder(
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
                      padding: const EdgeInsets.only(top: 5.0),
                      color: selectedUserIndex == index
                          ? Colors.grey.withOpacity(0.5)
                          : null, // Default background color when not tapped
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              backgroundImage: profilePicture != null &&
                                      profilePicture != ''
                                  ? MemoryImage(
                                      decodeProfilePicture(profilePicture))
                                  : const AssetImage(
                                          'assets/images/user_profile_icon.png')
                                      as ImageProvider,
                            ),
                            const Positioned(
                              bottom: 1.5,
                              right: 2,
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: Color(0xFFFED154),
                              ),
                            ),
                          ],
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            username ?? 'Unknown',
                            style: GoogleFonts.raleway(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF435F49)),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
