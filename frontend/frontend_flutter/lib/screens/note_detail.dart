import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteDetailPage extends StatefulWidget {
  final Map note;
  final List folders; // már lekért listát átadjuk

  const NoteDetailPage({super.key, required this.note, required this.folders});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleC;
  late TextEditingController _contentC;
  String? selectedFolder;
  bool pinned = false;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.note['title']);
    _contentC = TextEditingController(text: widget.note['content']);
    selectedFolder = widget.note['folderId'];
    pinned = widget.note['pinned'] == true;
  }

  Future<void> _save() async {
    final url = Uri.parse(
      'https://app-in-progress-457709.lm.r.appspot.com/notes/${widget.note['id']}',
    );
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleC.text,
        'content': _contentC.text,
        'pinned': pinned,
        'importance': widget.note['importance'],
        'folderId': selectedFolder,
      }),
    );
    if (res.statusCode == 200) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final ok = await http.delete(
      Uri.parse(
        'https://app-in-progress-457709.lm.r.appspot.com/notes/${widget.note['id']}',
      ),
    );
    if (ok.statusCode == 200) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        title: const Text('Jegyzet részletei'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleC,
              style: const TextStyle(color: AppStyle.accentWhite),
              decoration: const InputDecoration(labelText: 'Cím'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentC,
              maxLines: 8,
              style: const TextStyle(color: AppStyle.accentWhite),
              decoration: const InputDecoration(labelText: 'Tartalom'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Kitűzve:',
                  style: TextStyle(color: AppStyle.accentWhite),
                ),
                Switch(
                  value: pinned,
                  onChanged: (v) => setState(() => pinned = v),
                  activeColor: Colors.red,
                ),
                const Spacer(),
                DropdownButton<String?>(
                  value: selectedFolder,
                  dropdownColor: AppStyle.cardColor,
                  hint: const Text(
                    'Mappa',
                    style: TextStyle(color: AppStyle.accentWhite),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Összes')),
                    ...widget.folders.map(
                      (f) => DropdownMenuItem(
                        value: f['id'],
                        child: Text(f['name']),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedFolder = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Mentés')),
          ],
        ),
      ),
    );
  }
}
