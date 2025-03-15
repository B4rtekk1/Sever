import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class Destination {
  const Destination(this.title, this.icon, this.selectedIcon, this.color);
  final String title;
  final IconData icon;
  final IconData selectedIcon;
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
      home: const MyHomePage(title: "File Manager"),
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
  final ApiService _apiService = ApiService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(apiService: _apiService),
          ChatPage(apiService: _apiService),
          ProfilePage(apiService: _apiService),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
            icon: Icon(destination.icon),
            activeIcon: Icon(destination.selectedIcon),
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

// Strona Home - Wyświetlanie zmiennej serwerowej i aktualizacja
class HomePage extends StatefulWidget {
  final ApiService apiService;

  const HomePage({super.key, required this.apiService});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String serverVariable = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadServerVariable();
  }

  void _loadServerVariable() async {
    final value = await widget.apiService.getServerVariable();
    setState(() {
      serverVariable = value;
    });
  }

  void _updateServerVariable() async {
    final newValue = await widget.apiService.updateServerVariable("Nowa wartość ${DateTime.now()}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(newValue)));
    _loadServerVariable();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Zmienna serwerowa: $serverVariable", style: const TextStyle(fontSize: 24)),
          ElevatedButton(
            onPressed: _updateServerVariable,
            child: const Text("Aktualizuj zmienną"),
          ),
        ],
      ),
    );
  }
}

// Strona Chat - Lista plików z serwera
class ChatPage extends StatefulWidget {
  final ApiService apiService;

  const ChatPage({super.key, required this.apiService});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() async {
    final fileList = await widget.apiService.getFiles();
    setState(() {
      files = fileList;
    });
  }

  void _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final message = await widget.apiService.uploadFile(file, ""); // Pusty folder, możesz zmienić
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _loadFiles();
    }
  }

  void _downloadFile(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String savePath = "${dir.path}/$filename";
    await widget.apiService.downloadFile(filename, savePath);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pobrano: $filename")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<String>>(
            future: widget.apiService.getFiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Błąd połączenia'));
              }
              final files = snapshot.data ?? [];
              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    title: Text(file),
                    onTap: () => _downloadFile(file),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _uploadFile,
            child: const Text("Wyślij plik"),
          ),
        ),
      ],
    );
  }
}

// Strona Profile - Wyświetlanie logów
class ProfilePage extends StatelessWidget {
  final ApiService apiService;

  const ProfilePage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: apiService.getLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Błąd połączenia'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Text(snapshot.data ?? 'Brak logów', style: const TextStyle(fontSize: 16)),
        );
      },
    );
  }
}