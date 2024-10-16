import 'package:bronco_bond/src/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void logoutUser(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Token not in SharedPreferences');
        return;
      }

      var response = await http.post(
        Uri.parse(logout),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('Logging out.');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        } else {
          print('Proper Logout failed: ${jsonResponse['message']}');
          print('Sending you back to login');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
          // Handle login failure
          // You might want to show an error message to the user
        }
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        // Handle other HTTP status codes
        // You might want to show an error message to the user
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      // Handle other exceptions
      // You might want to show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFDDDDDD),
              size: 36,
            )),
        title: Text('Settings',
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFDDDDDD),
            )),
        titleSpacing: 0.0,
        backgroundColor: const Color(0xff435f49),
        toolbarHeight: 72,
      ),
      body: Container(
        color: const Color(0xff435f49),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 18),
                  child: buildSearchBar('Search Bonds', searchController),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Container(
                      padding:
                          const EdgeInsets.only(top: 2, bottom: 2, left: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xB2DDDDDD),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      child:
                          settingsListTile(Icons.person_rounded, 'My Account')),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'How you use BroncoBond',
                    style: GoogleFonts.raleway(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF939393)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    bottom: 16,
                  ),
                  child: Container(
                      padding:
                          const EdgeInsets.only(top: 3, bottom: 3, left: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xB2DDDDDD),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          settingsListTile(Icons.bookmark_rounded, 'Saved'),
                          settingsListTile(
                              Icons.block_flipped, 'Blocked Accounts'),
                          settingsListTile(
                              Icons.notifications, 'Notifications'),
                        ],
                      )),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'More info and support',
                    style: GoogleFonts.raleway(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF939393)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    bottom: 16,
                  ),
                  child: Container(
                      padding:
                          const EdgeInsets.only(top: 3, bottom: 3, left: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xB2DDDDDD),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          settingsListTile(
                              Icons.phone_iphone_rounded, 'Device Permission'),
                          settingsListTile(Icons.language, 'Language'),
                          settingsListTile(Icons.info, 'About'),
                          settingsListTile(Icons.help, 'Help')
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: TextButton(
                    onPressed: () {
                      //create dump for all user info
                      // Navigate to the login screen or clear user session
                      logoutUser(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFB00020),
                          size: 26,
                        ),
                        const SizedBox(width: 6),
                        Text('Log Out',
                            style: GoogleFonts.raleway(
                                color: const Color(0xFFB00020),
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsListTile(IconData leadingIcon, String title) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: const Color(0xFF435F49),
        size: 28,
      ),
      title: Text(
        title,
        style: GoogleFonts.raleway(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF435F49),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF435F49),
        size: 30,
      ),
      onTap: () {
        // TODO: Navigate to settings
      },
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
                  // TODO: search through settings
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
