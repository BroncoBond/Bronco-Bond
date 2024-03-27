import 'dart:typed_data';
import 'package:bronco_bond/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';
import 'dart:convert';

class FriendsListPage extends StatefulWidget {
  final userID;

  const FriendsListPage({Key? key, required this.userID}) : super(key: key);

  @override
  FriendsListPageState createState() => FriendsListPageState();
}

class FriendsListPageState extends State<FriendsListPage> {
  late String username = '';
  late List<dynamic> bonds = [];
  late List<dynamic> bondRequestsFromUser = [];
  late List<dynamic> bondRequestsToUser = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  int selectedUserIndex = -1;

  bool showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // fetchDataUsingUserID(widget.userID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchDataUsingUserID(String userID) async {
    try {
      final response = await http.get(Uri.parse('$getUserByID/$userID'));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
          bonds = userData['user']['bonds'] ?? [];
          bondRequestsFromUser = userData['user']['bondRequestsFromUser'] ?? [];
          bondRequestsToUser = userData['user']['bondRequestsToUser'] ?? [];
        });
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        print('Error fetching user data: $e');
      }
    }
  }

  Future<Map<String, dynamic>> fetchUsernames(String userID) async {
    try {
      final response = await http.get(Uri.parse('$getUserByID/$userID'));

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

  void acceptRequest(String userID, String? currentUserID) async {
    var regBody = {"_id": userID};

    try {
      var response = await http.put(Uri.parse('$acceptUser/$currentUserID'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      print(response.body);
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void declineRequest(String userID, String? currentUserID) async {
    var regBody = {"_id": userID};

    try {
      var response = await http.put(Uri.parse('$declineUser/$currentUserID'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      print(response.body);
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void performSearch() async {}

  @override
  Widget build(BuildContext context) {
    // Check if username is empty before fetching data
    if (username.isEmpty) {
      fetchDataUsingUserID(widget.userID);
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            username,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
                kToolbarHeight), // Adjust the height as needed
            child: Row(
              children: [
                //const SizedBox(width: 8.0),
                const Expanded(
                  child: TabBar(
                    labelStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    labelColor: Color(0xFF3B5F43),
                    indicatorColor: Color(0xFF3B5F43),
                    unselectedLabelColor: Colors.grey,
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.w500),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Friends'),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Requests'),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Pending'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showSearchBar = !showSearchBar;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3B5F43),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Add Friend",
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: TabBarView(
                children: [
                  buildFriendsTab(bonds), // Tab View for "Friends"
                  buildRequestsTab(
                      bondRequestsToUser), // Tab View for "Requests" (to user)
                  buildPendingTab(
                      bondRequestsFromUser), // Tab View for "Pending" (requests from user)
                ],
              ),
            ),
            if (showSearchBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    child: buildSearchBar(searchController),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildFriendsTab(List<dynamic> bonds) {
    if (bonds.isEmpty) {
      return const Center(
        child: Text('No friends found'),
      );
    }
    return FutureBuilder(
      future: Future.wait(bonds.map((bond) => fetchUsernames(bond))),
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

  Widget buildRequestsTab(List<dynamic> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No friend requests'),
      );
    }
    return FutureBuilder(
      future: Future.wait(requests.map((user) => fetchUsernames(user))),
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
              final userID = userData['user']['_id'];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedUserIndex = index;
                    });
                    navigateToUserProfile(requests[index]);
                  },
                  child: Container(
                    color: selectedUserIndex == index
                        ? Colors.grey.withOpacity(0.5) // Grey when tapped
                        : null, // Default background color when not tapped
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage:
                              profilePicture != null && profilePicture != ''
                                  ? MemoryImage(
                                      decodeProfilePicture(profilePicture))
                                  : const AssetImage(
                                          'assets/images/user_profile_icon.png')
                                      as ImageProvider,
                        ),
                        title: Text(username ?? 'Unknown'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                acceptRequest(userID, widget.userID);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff3B5F43),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                declineRequest(userID, widget.userID);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFABABAB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Decline'),
                            ),
                          ],
                        )),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget buildPendingTab(List<dynamic> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No pending requests'),
      );
    }
    return FutureBuilder(
      future: Future.wait(requests.map((user) => fetchUsernames(user))),
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
                    navigateToUserProfile(requests[index]);
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

  Widget buildSearchBar(TextEditingController fieldController) {
    return Container(
      height: 48,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
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
                decoration: const InputDecoration(
                  hintText: 'Add friend by username',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF3B5F43),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: ElevatedButton(
              onPressed: () {
                performSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B5F43),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Send Bond Request',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToUserProfile(String userID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(userID: userID)),
    );
  }

  Uint8List decodeProfilePicture(dynamic profilePicture) {
    List<int> profilePictureData =
        List<int>.from(profilePicture['data']['data']);
    List<int> decodedImageBytes =
        base64Decode(String.fromCharCodes(profilePictureData));
    return Uint8List.fromList(decodedImageBytes);
  }
}
