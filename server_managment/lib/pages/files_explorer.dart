import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:server_managment/services/api_service.dart';

class FilesExplorerPage extends StatefulWidget {
  final ApiService apiService;

  const FilesExplorerPage({super.key, required this.apiService});

  @override
  _FilesExplorerPageState createState() => _FilesExplorerPageState();
}

class _FilesExplorerPageState extends State<FilesExplorerPage> {
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
      final message = await widget.apiService.uploadFile(file, "");
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

  IconData _getIcon(String path) {
    if (path.endsWith('/')) {
      return Icons.folder;
    }
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'mp3':
      case 'wav':
        return Icons.music_note;
      case 'mp4':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
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
                    leading: Icon(_getIcon(file)),
                    title: Text(file.split('/').last),
                    subtitle: Text(file),
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