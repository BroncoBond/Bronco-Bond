import 'dart:typed_data';
import 'package:bronco_bond/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FriendsListPage extends StatefulWidget {
  final userID;

  const FriendsListPage({Key? key, required this.userID}) : super(key: key);

  @override
  FriendsListPageState createState() => FriendsListPageState();
}

class FriendsListPageState extends State<FriendsListPage> {
  late Future<SharedPreferences> prefsFuture;
  late SharedPreferences prefs;
  late String username = '';
  late List<dynamic> bonds = [];
  late List<dynamic> bondRequestsSent = [];
  late List<dynamic> bondRequestsReceived = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  int selectedUserIndex = -1;

  bool showSearchBar = false;

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

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchDataUsingUserID(String userID) async {
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

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
          bonds = userData['user']['bonds'] ?? [];
          bondRequestsSent = userData['user']['bondRequestsSent'] ?? [];
          bondRequestsReceived = userData['user']['bondRequestsReceived'] ?? [];
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

  void acceptRequest(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"_id": userID};

    try {
      var response = await http.put(Uri.parse(acceptBondRequest),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(regBody));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bond request accepted!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xff3B5F43),
        ),
      );
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void declineRequest(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"_id": userID};

    try {
      var response = await http.put(Uri.parse(declineBondRequest),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(regBody));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bond request declined.'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xff3B5F43),
        ),
      );
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Searches database by username, returns user, then uses the user's id to send a bond request
  void sendRequest() async {
    String? token = prefs.getString('token');
    final query = searchController.text;

    try {
      final response = await http.get(
        Uri.parse('$search?username=$query'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);

        // Get exact user from username
        final user = users.firstWhere((user) => user['username'] == query,
            orElse: () => null);

        // Get userID from user and send friend request
        if (user != null) {
          final userID = user['_id'];

          try {
            var regBody = {"_id": userID};

            var response = await http.put(Uri.parse(sendBondRequest),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token"
                },
                body: jsonEncode(regBody));

            // Display success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bond request sent to ${user['username']}'),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xff3B5F43),
              ),
            );
          } catch (e) {
            print('Error fetching user data: $e');
            // Display error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('An error occurred! Try again later.'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Display error if user is null and does not exist
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User does not exist!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Display error if user is null and does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User does not exist!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bond request revoked.'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xff3B5F43),
        ),
      );
      print('Revoked bond request to user: $userID');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error revoking request.'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xff3B5F43),
        ),
      );
      print('Error fetching user data: $e');
    }
  }

  void navigateToUserProfile(String userID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(userID: userID)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: prefsFuture,
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show error message if something went wrong
        } else {
          if (snapshot.data == null) {
            return const Text(
                'Error: SharedPreferences not initialized'); // Show error message
          } else {
            prefs =
                snapshot.data!; // Initialize prefs with the completed Future
            // Now you can use prefs in your widget tree
            if (username.isEmpty) {
              fetchDataUsingUserID(widget.userID);
            }
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: const Color.fromARGB(255, 67, 95, 73),
                appBar: AppBar(
                  backgroundColor: const Color.fromARGB(255, 67, 95, 73),
                  leading: IconButton(
                    padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showSearchBar = !showSearchBar;
                        });
                      },
                      icon: const Icon(
                        Icons.person_add,
                        color: Color.fromARGB(255, 67, 95, 73),
                        size: 20,
                      ),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                            color: Color.fromARGB(255, 67, 95, 73),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 0),
                      ),
                      style: const ButtonStyle(
                        elevation: WidgetStatePropertyAll(0),
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                        minimumSize: WidgetStatePropertyAll(Size(72, 32)),
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 254, 209, 84)),
                      ),
                    ),
                    const SizedBox(width: 30)
                  ],
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(
                        kToolbarHeight), // Adjust the height as needed
                    child: Row(
                      children: [
                        //const SizedBox(width: 8.0),
                        Expanded(
                          child: TabBar(
                            dividerColor: Color.fromARGB(255, 67, 95, 73),
                            tabAlignment: TabAlignment.center,
                            isScrollable: true,
                            labelStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            labelColor: Color.fromARGB(255, 254, 209, 84),
                            indicatorColor:
                                Color.fromARGB(255, 254, 209, 84),
                            indicatorSize: TabBarIndicatorSize.label,
                            unselectedLabelColor: Colors.white,
                            unselectedLabelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            indicatorWeight: 7,
                            tabs: [
                              Tab(
                                child: Center(
                                  child: Text('Bonds'),
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
                          buildBondsTab(bonds), // Tab View for "Friends"
                          buildRequestsTab(
                              bondRequestsReceived), // Tab View for "Requests" (to user)
                          buildPendingTab(
                              bondRequestsSent), // Tab View for "Pending" (requests from user)
                        ],
                      ),
                    ),
                    if (showSearchBar)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 3,
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
        }
      },
    );
  }

  Widget buildBondsTab(List<dynamic> bonds) {
    if (bonds.isEmpty) {
      return Stack(children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Text('No bonds found'),
          ),
        ),
      ]);
    }
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
          child: FutureBuilder(
            future: Future.wait(bonds.map((bond) => fetchBondUsernames(bond))),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 59, 95, 67)),
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
                          padding: const EdgeInsets.only(bottom: 15),
                          color: selectedUserIndex == index
                              ? Colors.grey.withOpacity(0.5) // Grey when tapped
                              : null, // Default background color when not tapped
                          child: ListTile(
                            leading: CircleAvatar(
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
                            title: Text(
                              username ?? 'Unknown',
                              style: const TextStyle(
                                  color: Color(0xFF435E49),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildRequestsTab(List<dynamic> requests) {
    if (requests.isEmpty) {
      return Stack(children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Text('No bond requests'),
          ),
        ),
      ]);
    }
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
          child: FutureBuilder(
            future:
                Future.wait(requests.map((user) => fetchBondUsernames(user))),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xff3B5F43)),
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
                          padding: const EdgeInsets.only(bottom: 15),
                          color: selectedUserIndex == index
                              ? Colors.grey.withOpacity(0.5) // Grey when tapped
                              : null, // Default background color when not tapped
                          child: ListTile(
                              leading: CircleAvatar(
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
                              title: Text(
                                username ?? 'Unknown',
                                style: const TextStyle(
                                    color: Color(0xFF435E49),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      declineRequest(userID);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      minimumSize: const Size.fromRadius(15),
                                      backgroundColor: const Color(0xFFDDDDDD),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      'Decline',
                                      style: TextStyle(
                                          color: Color(0xFF929292),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      acceptRequest(userID);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      minimumSize: const Size.fromRadius(15),
                                      backgroundColor: const Color.fromARGB(
                                          255, 85, 104, 90),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(
                                          color: Color(0xFFFED154),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildPendingTab(List<dynamic> requests) {
    if (requests.isEmpty) {
      return Stack(children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Text('No pending requests'),
          ),
        ),
      ]);
    }
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          color: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24,horizontal: 15),
          child: FutureBuilder(
            future: Future.wait(requests.map((user) => fetchBondUsernames(user))),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
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
                          padding: const EdgeInsets.only(bottom: 15),
                          color: selectedUserIndex == index
                              ? Colors.grey.withOpacity(0.5) // Grey when tapped
                              : null, // Default background color when not tapped
                          child: ListTile(
                            leading: CircleAvatar(
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
                            title: Text(
                              username ?? 'Unknown',
                              style: const TextStyle(
                                  color: Color(0xFF435E49),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 45,
                              ),
                              color: const Color.fromARGB(255, 147, 147, 147),
                              onPressed: () {
                                revokeRequest(userID);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
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
                style: const TextStyle(
                  fontSize: 16,
                ),
                controller: fieldController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Add bond by username',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.person_add_rounded,
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
                sendRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5F43),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  Uint8List decodeProfilePicture(dynamic profilePicture) {
    List<int> profilePictureData =
        List<int>.from(profilePicture['data']['data']);
    List<int> decodedImageBytes =
        base64Decode(String.fromCharCodes(profilePictureData));
    return Uint8List.fromList(decodedImageBytes);
  }
}
