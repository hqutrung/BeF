import 'package:bef/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bef/models/user_data.dart';
import 'package:provider/provider.dart';

import 'activity_screen.dart';
import 'create_post_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: TextField(
          cursorColor: Colors.white,
          controller: _searchController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            focusColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Tìm kiếm...',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                'BeF',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Billabong',
                  fontStyle: FontStyle.italic,
                  fontSize: 35.0,
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: _clearSearch,
            ),
            filled: true,
          ),
          onSubmitted: (input) {
            if (input.isNotEmpty) {
              setState(() {
                _users = DatabaseService.searchUsers(input);
              });
            }
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: currentUserId),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(),
          ProfileScreen(
            currentUserId: currentUserId,
            userId: currentUserId,
          ),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.orange[500],
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        activeColor: Colors.white,
        inactiveColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
