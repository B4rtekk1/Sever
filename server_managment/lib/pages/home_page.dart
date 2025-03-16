import 'package:flutter/material.dart';
import 'package:server_managment/services/api_service.dart';

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