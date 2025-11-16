import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'bookmarks_screen.dart'; 

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BookmarksScreen(),
  ];

  static const List<String> _widgetTitles = <String>[
    'InsightEd', // Title for Home
    'Bookmarks', // Title for Bookmarks
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close the drawer
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar is now part of the main container
      appBar: AppBar(
        title: Text(
          _widgetTitles[_selectedIndex],
          // Use the correct theme for the AppBar title
          style: Theme.of(context).textTheme.displaySmall,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        // The leading icon will automatically be a "hamburger" menu
        // to open the drawer when a drawer is present.
      ),
      // The body is the IndexedStack to switch between pages
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // The "sliding" menu is the NavigationDrawer
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        children: const [
          // Add some padding to the top
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Navigation',
              // style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: Text('Bookmarks'),
          ),
        ],
      ),
    );
  }
}