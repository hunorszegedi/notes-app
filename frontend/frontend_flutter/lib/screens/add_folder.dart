import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../styles/app_styles.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key});

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  final TextEditingController _nameController = TextEditingController();
  String message = '';

  Future<void> _submitFolder() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => message = 'Adj meg mappanevet!');
      return;
    }

    final url = Uri.parse(
      'https://app-in-progress-457709.lm.r.appspot.com/folders',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // jelzi, hogy sikerült
    } else {
      setState(() => message = 'Hiba történt (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        title: const Text('Új mappa'),
        backgroundColor: AppStyle.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppStyle.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Mappa neve',
                labelStyle: TextStyle(color: AppStyle.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFolder,
              child: const Text('Mentés'),
            ),
            const SizedBox(height: 10),
            if (message.isNotEmpty)
              Text(message, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
