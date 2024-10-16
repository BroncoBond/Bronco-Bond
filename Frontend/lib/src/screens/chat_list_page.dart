import 'dart:typed_data';

import 'package:bronco_bond/src/config.dart';
import 'package:bronco_bond/src/screens/chat_page.dart';
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
  late TabController tabController;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
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
          bonds = (userData['user']['bonds'] ?? []);
        });
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBondUsername(String userID) async {
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

  void performSearch() async {
    String searchText = searchController.text.toLowerCase();

    setState(() {
      selectedUserIndex = -1;
    });

    // Fetch all bond usernames
    List<Map<String, dynamic>> fetchedUsernames = await Future.wait(
      bonds.map((bond) => fetchBondUsername(bond)),
    );

    // Filter bonds by the fetched usernames
    searchResults = fetchedUsernames.where((userData) {
      final username = userData['user']['username']?.toLowerCase() ?? '';
      return username.contains(searchText);
    }).toList();
  }

  void navigateToUserProfile(String userID) {
    setState(() {
      selectedUserIndex = -1;
    });
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
    searchController.addListener(() {
      setState(() {}); // Rebuild the widget on search input change
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                labelPadding: const EdgeInsets.only(left: 55.0),
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
      return Center(
        child: Text(
          'No bonds found',
          style: GoogleFonts.raleway(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF939393),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
          child: buildSearchBar('Search Bonds', searchController),
        ),
        Expanded(
          child: FutureBuilder(
            future: Future.wait(bonds.map((bond) => fetchBondUsername(bond))),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xff435f49)),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Map<String, dynamic>> sortedBonds = snapshot.data!;

                // Check if there's an active search, and filter the sortedBonds
                if (searchController.text.isNotEmpty) {
                  sortedBonds = sortedBonds.where((userData) {
                    String username =
                        userData['user']['username']?.toLowerCase() ?? '';
                    return username
                        .contains(searchController.text.toLowerCase());
                  }).toList();
                }

                // If search results are empty, show 'No bonds found'
                if (sortedBonds.isEmpty) {
                  return Center(
                    child: Text(
                      'No bonds found',
                      style: GoogleFonts.raleway(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF939393),
                      ),
                    ),
                  );
                }

                // Sort the bonds alphabetically
                sortedBonds.sort((a, b) {
                  String usernameA = a['user']['username'] ?? '';
                  String usernameB = b['user']['username'] ?? '';
                  return usernameA
                      .toLowerCase()
                      .compareTo(usernameB.toLowerCase());
                });

                // Group the bonds by the first letter of the username
                Map<String, List<Map<String, dynamic>>> groupedBonds = {};
                for (var bond in sortedBonds) {
                  String username = bond['user']['username'] ?? 'Unknown';
                  String firstLetter = username[0].toUpperCase();

                  if (!groupedBonds.containsKey(firstLetter)) {
                    groupedBonds[firstLetter] = [];
                  }
                  groupedBonds[firstLetter]!.add(bond);
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: ListView.builder(
                    itemCount: groupedBonds.keys.length,
                    itemBuilder: (context, index) {
                      String firstLetter = groupedBonds.keys.elementAt(index);
                      List<Map<String, dynamic>> bondsForLetter =
                          groupedBonds[firstLetter]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header for the letter
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, bottom: 8.0),
                            child: Text(
                              firstLetter,
                              style: GoogleFonts.raleway(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF435F49),
                              ),
                            ),
                          ),
                          // List of users under the current letter
                          ...bondsForLetter.asMap().entries.map((entry) {
                            final bondIndex =
                                entry.key; // Bond in the current group
                            final userData = entry.value;
                            final profilePicture =
                                userData['user']['profilePicture'];
                            final username = userData['user']['username'];
                            final isOnline = userData['user']['isOnline'];
                            // Find the original bond from the unsorted list
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedUserIndex = bondIndex;
                                  });
                                  navigateToUserProfile(
                                      sortedBonds[bondIndex]['user']['_id']);
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  color: selectedUserIndex == bondIndex
                                      ? Colors.grey.withOpacity(0.5)
                                      : null, // Highlight only the selected user
                                  child: ListTile(
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.white,
                                          backgroundImage: profilePicture !=
                                                      null &&
                                                  profilePicture != ''
                                              ? MemoryImage(
                                                  decodeProfilePicture(
                                                      profilePicture))
                                              : const AssetImage(
                                                      'assets/images/user_profile_icon.png')
                                                  as ImageProvider,
                                        ),
                                        if (isOnline)
                                          const Positioned(
                                            bottom: 1.5,
                                            right: 2,
                                            child: CircleAvatar(
                                              radius: 5,
                                              backgroundColor:
                                                  Color(0xFFFED154),
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
                          }).toList(),
                        ],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildSearchBar(String label, TextEditingController fieldController) {
    bool showCancelButton =
        searchResults.isNotEmpty || searchController.text.isNotEmpty;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: fieldController,
                keyboardType: TextInputType.text,
                cursorColor: const Color(0xFF435F49),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.raleway(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF939393)),
                  border: InputBorder.none,
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF939393),
                    ),
                  ),
                ),
                onChanged: (String value) {
                  performSearch();
                },
              ),
            ),
          ),
          if (showCancelButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    searchResults.clear();
                    selectedUserIndex = -1;
                  });
                },
                child: Text('Cancel',
                    style: GoogleFonts.raleway(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }
}
