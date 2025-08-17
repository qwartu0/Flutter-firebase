import 'package:flutter/material.dart';
import 'package:laba12/screens/transactions_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'first_screen.dart';
import 'second_screen.dart';
import 'life_screen.dart';
import 'mine_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    FirstScreen(),
    MineScreen(),
    TransactionsScreen(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Transactions',
          ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF23695C),
        unselectedItemColor: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
} 