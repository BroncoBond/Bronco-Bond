import 'package:bronco_bond/src/screens/welcome_page.dart';
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
  int selectedUserIndex = -1;

  @override
  void initState() {
    super.initState();
    // fetchDataUsingUserID(widget.userID);
  }

  Future<void> fetchDataUsingUserID(String userID) async {
    try {
      final response = await http.get(Uri.parse('${getUserByID}/$userID'));

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
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        print('Error fetching user data: $e');
      }
    }
  }

  Future<List<String>> fetchUsernames(List<dynamic> userIDs) async {
    List<String> usernames = [];
    for (var userID in userIDs) {
      try {
        final response = await http.get(Uri.parse('${getUserByID}/$userID'));

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          final username = userData['user']['username'] ?? 'Unknown';
          usernames.add(username);
        } else {
          print(
              'Failed to fetch user data. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          usernames.add('Unknown');
        }
      } catch (e) {
        print('Error fetching user data: $e');
        usernames.add('Unknown');
      }
    }

    return usernames;
  }

  @override
  Widget build(BuildContext context) {
    // Check if username is empty before fetching data
    if (username.isEmpty) {
      fetchDataUsingUserID(widget.userID);
    }
    return DefaultTabController(
      length: 2,
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
            style: GoogleFonts.raleway(
              textStyle: Theme.of(context).textTheme.displaySmall,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
                kToolbarHeight), // Adjust the height as needed
            child: Row(
              children: [
                const SizedBox(width: 16.0),
                const Expanded(
                  child: TabBar(
                    labelStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    labelColor: Color(0xFF3B5F43),
                    indicatorColor: Color(0xFF3B5F43),
                    unselectedLabelColor: Colors.grey,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Friends'),
                      Tab(text: 'Requests'),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3B5F43),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Add Friend",
                      style: GoogleFonts.raleway(
                        fontSize: 16,
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
        body: Row(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Tab View for "All"
                  buildFriendsTab(bonds),
                  // Tab View for "Friends"
                  Container(
                    alignment: Alignment.center,
                    child: const Text("Friends Tab Content"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFriendsTab(List<dynamic> bonds) {
    return FutureBuilder(
      future: fetchUsernames(bonds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<String>? usernames = snapshot.data as List<String>;

          if (usernames.isEmpty) {
            return Center(child: Text('No friends found'));
          }
          return ListView.builder(
            //shrinkWrap: true,
            itemCount: usernames.length,
            itemBuilder: (context, index) {
              final friendUsername = usernames[index];
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
                      title: Text(friendUsername,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  void navigateToUserProfile(String userID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(userID: userID)),
    );
  }
}


/*return ListView.builder(
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, user) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              setState(() {
                selectedResultIndex = user;
              });
              navigateToUserProfile(searchResults[user]);
            },
            child: Container(
                color: selectedResultIndex == user
                    ? Colors.grey.withOpacity(0.5) // Grey when tapped
                    : null, // Default background color when not tapped
                child: ListTile(title: Text(searchResults[user]['username']))),
          ),
        );
      },
    );
        );*/