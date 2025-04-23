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
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() {
        message = 'Tölts ki minden mezőt!';
      });
      return;
    }

    final url = Uri.parse(
      'https://app-in-progress-457709.lm.r.appspot.com/notes',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"title": "$title", "content": "$content"}',
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // visszatérés és frissítés
    } else {
      setState(() {
        message = 'Hiba történt (${response.statusCode})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Új jegyzet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Cím'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Tartalom'),
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
