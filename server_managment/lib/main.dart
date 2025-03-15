import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Destination {
  const Destination(this.title, this.icon, this.selectedIcon, this.color);
  final String title;
  final IconData icon;        // Ikona dla niewybranego stanu (np. kontur)
  final IconData selectedIcon; // Ikona dla wybranego stanu (np. wypełniona)
  final MaterialColor color;
}

const List<Destination> allDestinations = <Destination>[
  Destination('Home', Icons.widgets_outlined, Icons.widgets, Colors.teal),
  Destination('Chat', Icons.chat_outlined, Icons.chat, Colors.cyan),
  Destination('Profile', Icons.account_circle_outlined, Icons.account_circle, Colors.orange),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(title: "title"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('You have pushed the button this many times:'),
          Text('0', style: TextStyle(fontSize: 34)),
        ],
      ),
    ),
    Center(child: Text('Chat Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting, // Dla efektu zmiany tła
        items: allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
            icon: Icon(destination.icon),           // Ikona niewybrana
            activeIcon: Icon(destination.selectedIcon), // Ikona wybrana
            label: destination.title,
            backgroundColor: destination.color,
          );
        }).toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}