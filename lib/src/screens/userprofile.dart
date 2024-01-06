import 'package:bronco_bond/src/screens/interests.dart';
import 'package:bronco_bond/src/screens/searchpage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class UserProfile extends StatefulWidget {
  final token;

  const UserProfile({@required this.token, Key? key}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  late String username;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic>? jwtDecodedToken;

    try {
      jwtDecodedToken = JwtDecoder.decode(widget.token);
      print('Decoded token: $jwtDecodedToken');
    } catch (e) {
      print('Error decoding token: $e');
    }

    // Check if 'username' field exists, otherwise set a default value
    username = jwtDecodedToken?['username'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BroncoBond',
          style: GoogleFonts.raleway(
            textStyle: Theme.of(context).textTheme.displaySmall,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3B5F43),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProfileHeader(),
            buildAboutBar(),
            buildPosts(),
          ],
        ),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Image.asset('assets/images/user_profile_icon.png',
                  width: 75.0, height: 75.0),
              SizedBox(height: 5),
              Text(
                username,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(width: 30),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStatColumn('Posts', '0'),
              SizedBox(width: 10),
              buildStatColumn('Bonds', '0'),
              SizedBox(width: 10),
              buildStatColumn('Interests', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget buildAboutBar() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text("About",
                    style: GoogleFonts.raleway(
                      textStyle: Theme.of(context).textTheme.displaySmall,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3B5F43),
                    ))),
            Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(children: [
                  Image.asset('assets/images/bookicon.png',
                      width: 20, height: 20),
                  Text("  B.A. Visual Communication Design"),
                ])),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Image.asset('assets/images/gradcapicon.png',
                        width: 30, height: 30),
                    Text("  Class of 2027 (Spring)"),
                  ],
                ))
          ],
        ));
  }

  Widget buildPosts() {
    // Replace this with your logic to display user posts
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Image.network(
          'https://via.placeholder.com/150', // Replace with your image URLs
          fit: BoxFit.cover,
        );
      },
    );
  }
}
