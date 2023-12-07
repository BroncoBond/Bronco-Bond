import 'package:bronco_bond/src/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            // User data
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Username: ${widget.user['username']}'),
                Text('Email: ${widget.user['email']}'),
                Padding(
                  padding: const EdgeInsets.only(top: 160.0),
                  child: Image.asset('assets/images/BroncoBond_logo.png'),
                ),
              ],
            ),
            // Background image, ordered behind the button
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/bg_asset.png',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Join Now button
            Positioned(
              bottom: 12.0,
              right: 12.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  // Button functionality
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  // Button text and icon
                  child: Row(
                    children: [
                      Text(
                        "Join Now",
                        style: GoogleFonts.raleway(
                          textStyle: Theme.of(context).textTheme.displaySmall,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(),
                      Image.asset(
                        'assets/images/arrow_right.png',
                        width: 25.0,
                        height: 25.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}