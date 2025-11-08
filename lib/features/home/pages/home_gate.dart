import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';
import 'package:studysphere_app/features/calender/pages/calender_page.dart';
import 'package:studysphere_app/features/friend/pages/friend_page.dart';
import 'package:studysphere_app/features/home/pages/home_page.dart';
import 'package:studysphere_app/features/profile/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currIdx = 0;

  // Widget each page
  late final List<Widget> _pages = const [
    MainPage(),
    FriendPage(),
    CalenderPage(),
    ProfilePage(),
  ];

  late final List<Text> _pages_name = const [
    Text("Home"),
    Text("Groups"),
    Text("Calender"),
    Text("You"),
  ];

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: IndexedStack(index: _currIdx, children: _pages_name),
        // Buat logout nanti
        actions: [
          // tombol logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // panggil service logout
              await authService.signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currIdx, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currIdx,
        onTap: (idx) {
          setState(() {
            _currIdx = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }
}
