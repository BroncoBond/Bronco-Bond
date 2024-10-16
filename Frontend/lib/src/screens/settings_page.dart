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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black)),
        title: Text(
          'Settings',
          style: GoogleFonts.raleway(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(
              'Account',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to account settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(
              'Notifications',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(
              'Bookmarks',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to privacy settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: Text(
              'Blocked Accounts',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: Text(
              'Device Permissions',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.accessibility),
            title: Text(
              'Accessibility',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(
              'Language',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              'About',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to about page
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: Text(
              'Account Status',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(
              'Help',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          // Add more settings as needed
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
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
            child: Text('Log Out',
                style: GoogleFonts.raleway(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
