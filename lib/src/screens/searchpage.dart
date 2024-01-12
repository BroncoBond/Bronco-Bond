import 'package:bronco_bond/src/screens/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bronco_bond/src/screens/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bronco_bond/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final token;
  const SearchPage({@required this.token, Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late String username;
  late String userID;
  late SharedPreferences prefs;

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  int selectedResultIndex = -1;

  void performSearch() async {
    final query = searchController.text;

    try {
      print(query);
      final response = await http.get(Uri.parse('${search}?username=$query'));

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

        var jsonResponse = jsonDecode(response.body);
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken); // Handle null values

        print('Search Results: $searchResults');
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
    Map<String, dynamic>? jwtDecodedToken;

    try {
      jwtDecodedToken = JwtDecoder.decode(widget.token);
      print('Decoded token: $jwtDecodedToken');
    } catch (e) {
      print('Error decoding token: $e');
    }

    // Check if 'username' field exists, otherwise set a default value
    username = jwtDecodedToken?['username'] ?? 'Unknown';
    userID = jwtDecodedToken?['_id'] ?? 'Unknown';
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
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
                color: const Color(0xFF3B5F43))),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(username),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: buildSearchBar(" ", searchController)),
              buildSearchResultsList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIcon("Organization", Icons.groups_rounded),
                  buildIcon("Professors", Icons.local_library_rounded),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIcon("People", Icons.language_rounded),
                  buildIcon("Messages", Icons.forum_rounded),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIcon("Events", Icons.calendar_today_rounded),
                  buildIcon("Forums", Icons.newspaper_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar(String label, TextEditingController fieldController) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: fieldController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (String value) {
                print('Search submitted: $value');
                performSearch();
              },
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
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                debugPrint('${title} tapped.');
              },

              child: Icon(
                iconData,
                size: 110,
                color: Color(0xff3B5F43),
              ), // Display text if imagePath is empty
            ),
          ),
        )),
        SizedBox(height: 5),
        Center(
            child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ))
      ],
    );
  }

  Widget buildSearchResultsList() {
    return ListView.builder(
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
  }

  void navigateToUserProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(userID: user['_id'])),
    );
  }
}
