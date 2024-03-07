import 'package:bronco_bond/src/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final userID;
  const HomePage({@required this.userID, Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late String username = '';
  late SharedPreferences prefs;

  Future<void> fetchDataUsingUserID(String userID) async {
    try {
      final response = await http.get(Uri.parse('$getUserByID/$userID'));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
        });
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
    fetchDataUsingUserID(widget.userID);
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'BroncoBond',
            style: GoogleFonts.raleway(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3B5F43)),
          ),
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            labelColor: Color(0xFF3B5F43),
            indicatorColor: Color(0xFF3B5F43),
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Communities'),
              Tab(text: 'My Bonds'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Welcome $username!'),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildTabContent('Tab 1'),
                  buildTabContent('Tab 2'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String tabName) {
    return ListView(
      children: [
        buildCard(tabName, 'Card 1'),
        buildCard(tabName, 'Card 2'),
        buildCard(tabName, 'Card 3'),
        // Add more cards as needed
      ],
    );
  }

  Widget buildCard(String tabName, String cardName) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(cardName),
        subtitle: Text('Subtitle for $cardName in $tabName'),
        onTap: () {
          // Handle card tap
          print('Tapped on $cardName in $tabName');
        },
      ),
    );
  }
}
