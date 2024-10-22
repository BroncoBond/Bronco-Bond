import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  final String userID;

  const HomePage({required this.userID, Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String fullName = '';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _tabController = TabController(length: 2, vsync: this); // Initialize TabController
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    // Fetch user data if needed
  }

  Future<void> fetchDataUsingUserID(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"_id": userID};

    try {
      final response = await http.post(
        Uri.parse('YOUR_API_ENDPOINT'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          fullName = userData['user']['fullName'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of TabController when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B5F43), // Green background color
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section (Green Top Bar)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, John',
                    style: GoogleFonts.raleway(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/user_profile_icon.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Rounded White Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Tab Navigation (centered)
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Home'),
                        Tab(text: 'For You'),
                      ],
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.transparent, // Transparent to hide the line
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Home Tab Content
                          _buildHomeContent(),
                          // For You Tab Content
                          _buildForYouContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30), // Add space between tabs and content
          // My Events Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'My events',
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildEventCard(
                  'Study Abroad 101',
                  'Oct 24 • 7:00 pm',
                  'Ursa Major',
                  'assets/images/Abroad.png',
                ),
                _buildEventCard(
                  'Pool Party',
                  'Sep 13 • 5:30 pm',
                  'BRIC Pool',
                  'assets/images/Abroad.png',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // My Feed Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'My feed',
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFeedCard(
            'Mark H.',
            'Looking for fellow IT interns @ CDPH!',
            'Anyone else apply for the IT internship offered by CDPH for next semester? Just wanted to try and make friends within the program in case we end up getting selected :) I linked the flyer below.',
            3,
          ),
          _buildFeedCard(
            'Vasu J.',
            'Please help me pick a school',
            'Hello. I got into Cal Poly Pomona for business management and also got into San Jose State University for business management/marketing. CPP is about a 7-hour drive while SJSU is 30 minutes...',
            26,
          ),
          // Add more feed cards here as needed
        ],
      ),
    );
  }

  Widget _buildForYouContent() {
    // Similar content structure for the "For You" tab
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30), // Add space between tabs and content
          // For You Feed Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'For You',
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFeedCard(
            'Emily R.',
            'Study Group for Math 101',
            'Hi everyone, I\'m forming a study group for Math 101. We\'ll be meeting every Tuesday and Thursday at the library. Let me know if you\'re interested!',
            10,
          ),
          _buildFeedCard(
            'Alex P.',
            'Lost my backpack',
            'Hey folks, I lost my black backpack near the cafeteria yesterday afternoon. It has a few textbooks and my laptop. If anyone finds it, please let me know!',
            5,
          ),
          // Add more content for "For You" tab as needed
        ],
      ),
    );
  }

  // Helper Widget for Event Card
  Widget _buildEventCard(
      String title, String date, String location, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    location,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Feed Card
  Widget _buildFeedCard(
      String userName, String title, String content, int likesCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.raleway(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.favorite_border, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$likesCount',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
