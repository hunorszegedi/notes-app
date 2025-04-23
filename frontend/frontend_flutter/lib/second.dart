import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String message = '';

  Future<void> submitNote() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() {
        message = 'Kérlek tölts ki minden mezőt!';
      });
      return;
    }

    final url = Uri.parse(
      'https://app-in-progress-457709.lm.r.appspot.com/notes',
    ); // vagy saját backend URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"title": "$title", "content": "$content"}',
    );

    if (response.statusCode == 200) {
      setState(() {
        message = 'Jegyzet elmentve!';
        _titleController.clear();
        _contentController.clear();
      });
    } else {
      setState(() {
        message = 'Hiba történt (${response.statusCode})';
      });
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Új jegyzet hozzáadása')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Cím'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Tartalom'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: submitNote, child: const Text('Mentés')),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
      ),
    );
  }
}
