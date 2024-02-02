import 'package:bronco_bond/src/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bronco_bond/src/config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();

}

class SettingsPageState extends State<SettingsPage> {
  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black
          )
        ),
        title: Text('Settings',
        style: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle),
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
            leading: Icon(Icons.notifications),
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
            leading: Icon(Icons.bookmark),
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
            leading: Icon(Icons.block),
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
            leading: Icon(Icons.smartphone),
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
            leading: Icon(Icons.accessibility),
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
            leading: Icon(Icons.translate),
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
            leading: Icon(Icons.info),
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
            leading: Icon(Icons.account_box),
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
            leading: Icon(Icons.help),
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
          padding: EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: () {
              //create dump for all user info
              // Navigate to the login screen or clear user session
              print('User logged out');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage())
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
 