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
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'Account',
              style: GoogleFonts.raleway(
                fontSize: 16.0, 
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () {
              // TODO: Navigate to account settings page
            },
          ),
          ListTile(
            title: Text(
              'Notifications',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // TODO: Navigate to notifications settings page
            },
          ),
          ListTile(
            title: Text(
              'Privacy',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // TODO: Navigate to privacy settings page
            },
          ),
          ListTile(
            title: Text(
              'Appearance',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // TODO: Navigate to appearance settings page
            },
          ),
          ListTile(
            title: Text(
              'About',
              style: GoogleFonts.raleway(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // TODO: Navigate to about page
            },
          ),
          // Add more settings as needed
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Perform logout actions
              // Navigate to the login screen or clear user session
              print('User logged out');
            },
            child: Text('Log Out'),
          ),
        ),
      ),
    );
  }
}
 