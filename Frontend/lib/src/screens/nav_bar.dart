import 'package:bronco_bond/src/screens/chat_list_page.dart';
import 'package:flutter/material.dart';
import 'package:bronco_bond/src/screens/search_page.dart';
import 'package:bronco_bond/src/screens/home_page.dart';
import 'package:bronco_bond/src/screens/events_page.dart';
import 'package:bronco_bond/src/screens/user_profile_page.dart';

class BottomNavBar extends StatefulWidget {
  final String userID;

  const BottomNavBar({super.key, required this.userID});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            userID: widget.userID,
          ),
          ChatListPage(userID: widget.userID),
          const SearchPage(),
          const EventsPage(),
          UserProfile(userID: widget.userID)
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            iconSize: 30.0,
            selectedItemColor: const Color(0xffFED053),
            unselectedItemColor: const Color(0xff55685A),
            backgroundColor: const Color(0xff2E4233),
            //showSelectedLabels: true,
            //showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Icon(Icons.home_rounded),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Icon(Icons.forum_rounded),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Icon(Icons.explore),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Icon(Icons.calendar_today_rounded),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Icon(Icons.person_rounded),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
