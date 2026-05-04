import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'add_item_screen.dart';
import 'requests_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _lastSelectedTabKey = 'last_selected_tab';
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const AddItemScreen(),
    const RequestsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedTab();
  }

  Future<void> _loadLastSelectedTab() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIndex = prefs.getInt(_lastSelectedTabKey);
    if (!mounted || storedIndex == null || storedIndex < 0 || storedIndex >= _pages.length) {
      return;
    }
    setState(() {
      _selectedIndex = storedIndex;
    });
  }

  Future<void> _saveLastSelectedTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSelectedTabKey, index);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _saveLastSelectedTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}