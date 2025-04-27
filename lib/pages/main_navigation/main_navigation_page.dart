import 'package:absensi_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/pages/home/dashboard_page.dart';
import 'package:absensi_app/pages/history/history_page.dart';
import 'package:absensi_app/pages/profile/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    DashboardPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.black,
        backgroundColor: AppColors.greenDark,
      ),
    );
  }
}
