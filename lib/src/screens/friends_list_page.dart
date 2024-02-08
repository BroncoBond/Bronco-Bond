import 'package:bronco_bond/src/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class FriendsListPage extends StatelessWidget {
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "BroncoBond",
            style: GoogleFonts.raleway(
              textStyle: Theme.of(context).textTheme.displaySmall,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3B5F43),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
                kToolbarHeight), // Adjust the height as needed
            child: Row(
              children: [
                const SizedBox(width: 16.0),
                const Expanded(
                  child: TabBar(
                    labelStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    labelColor: Color(0xFF3B5F43),
                    indicatorColor: Color(0xFF3B5F43),
                    unselectedLabelColor: Colors.grey,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Friends'),
                      Tab(text: 'Major'),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3B5F43),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Add Friend",
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Row(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Tab View for "All"
                  Container(
                    alignment: Alignment.center,
                    child: const Text("All Tab Content"),
                  ),
                  // Tab View for "Friends"
                  Container(
                    alignment: Alignment.center,
                    child: const Text("Friends Tab Content"),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text("Major Tab Content"),
                  ),
                  // Tab View for "Major"
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
