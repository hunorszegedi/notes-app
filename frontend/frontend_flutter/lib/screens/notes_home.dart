import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_note.dart';

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  List notes = [];

  Future<void> fetchNotes() async {
    final url = Uri.parse(
      'https://app-in-progress-457709.lm.r.appspot.com/notes',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        notes = jsonDecode(response.body);
      });
    } else {
      print('Hiba a lekérdezéskor: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jegyzetek')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['title'] ?? ''),
            subtitle: Text(note['content'] ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotePage()),
          );
          if (result == true) {
            fetchNotes(); // újratöltés ha sikeres mentés
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
