import 'dart:typed_data';

import 'package:bronco_bond/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bronco_bond/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late String username;
  late String userID;
  late SharedPreferences prefs;
  String? currentUserID;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  int selectedResultIndex = -1;

  void performSearch() async {
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
        final users =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        setState(() {
          searchResults = users;
        });

        // Print the usernames of the search results
        for (var user in users) {
          print(user['username']);
        }

        /*
        var jsonResponse = jsonDecode(response.body);
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken); // Handle null values */

        //print('Search Results: $searchResults');
      } else {
        print('Failed to fetch search results');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    currentUserID = prefs.getString('userID');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BroncoBond",
            style: GoogleFonts.raleway(
                textStyle: Theme.of(context).textTheme.displaySmall,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: const Color(0xFF3B5F43),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: buildSearchBar(" ", searchController)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildIcon("Communities", Icons.diversity_3_rounded),
                    buildIcon("Professors", Icons.school_rounded),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildIcon("People", Icons.group_rounded),
                    buildIcon("News", Icons.newspaper_rounded),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildIcon(
                        "Student Benefits", Icons.volunteer_activism_rounded),
                    buildIcon("Forums", Icons.live_help_rounded),
                  ],
                ),
              ],
            ),
          ),
          if (searchResults.isNotEmpty)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              bottom: 0,
              child: buildSearchResultsList(),
            ),
        ],
      ),
    );
  }

  Widget buildSearchBar(String label, TextEditingController fieldController) {
    bool showCancelButton = searchResults.isNotEmpty;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
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
                  hintText: 'Search...',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF3B5F43),
                  ),
                ),
                onSubmitted: (String value) {
                  print('Search submitted: $value');
                  performSearch();
                },
              ),
            ),
          ),
          if (showCancelButton)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    searchResults.clear();
                    selectedResultIndex = -1;
                  });
                },
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.normal)),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildIcon(String title, IconData iconData) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 175,
            height: 175,
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: const Color(0xff3B5F43)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  iconData,
                  size: 100,
                  color: const Color(0xff3B5F43),
                ), // Display text if imagePath is empty
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
            child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ))
      ],
    );
  }

  Widget buildSearchResultsList() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, user) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              setState(() {
                selectedResultIndex = user;
              });
              if (searchResults[user]['_id'] != currentUserID) {
                navigateToUserProfile(searchResults[user]);
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[400]!),
                  ),
                  color: selectedResultIndex == user
                      ? const Color(0xffABABAB) // Grey when tapped
                      : Colors.grey[
                          200], // Default background color when not tapped
                ),
                child: ListTile(
                    leading: CircleAvatar(
                      //radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          searchResults[user]['profilePicture'] != null &&
                                  searchResults[user]['profilePicture'] != ''
                              ? MemoryImage(decodeProfilePicture(
                                  searchResults[user]['profilePicture']))
                              : const AssetImage(
                                  'assets/images/user_profile_icon.png',
                                ) as ImageProvider,
                    ),
                    title: Text(searchResults[user]['username']))),
          ),
        );
      },
    );
  }

  void navigateToUserProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(userID: user['_id'])),
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
