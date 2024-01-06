import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
        ),
        body: TabBarView(
          children: [
            buildTabContent('Tab 1'),
            buildTabContent('Tab 2'),
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
      margin: EdgeInsets.all(8.0),
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
