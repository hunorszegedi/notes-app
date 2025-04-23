import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles/app_styles.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleC = TextEditingController();
  final _contentC = TextEditingController();

  bool isPinned = false;
  String importance = 'normal';
  String? selectedFolder; // null = nincs mappa
  List folders = [];

  String message = '';

  /* ---------- mappák lekérése ---------- */
  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    final res = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (res.statusCode == 200) setState(() => folders = jsonDecode(res.body));
  }

  /* ---------- küldés ---------- */
  Future<void> _submit() async {
    final title = _titleC.text.trim();
    final content = _contentC.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() => message = 'Tölts ki minden mezőt!');
      return;
    }

    final res = await http.post(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'pinned': isPinned,
        'importance': importance,
        'folderId': selectedFolder, // lehet null
      }),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context, true); // frissítés kérés a hívónak
    } else {
      setState(() => message = 'Hiba (${res.statusCode})');
    }
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        title: const Text('Új jegyzet'),
        backgroundColor: AppStyle.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleC,
              decoration: const InputDecoration(labelText: 'Cím'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentC,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Tartalom'),
            ),

            /* ---------- opcionális mappa ---------- */
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedFolder,
              hint: const Text('Mappa (opcionális)'),
              dropdownColor: AppStyle.cardColor,
              decoration: const InputDecoration(labelText: 'Mappa'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Nincs mappa'),
                ),
                ...folders.map<DropdownMenuItem<String>>((f) {
                  return DropdownMenuItem<String>(
                    value: f['id'].toString(),
                    child: Text(f['name']),
                  );
                }).toList(),
              ],
              onChanged: (value) => setState(() => selectedFolder = value),
            ),
            /* ---------- pinned + importance ---------- */
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Kitűzve:'),
                Switch(
                  activeColor: AppStyle.accentRed,
                  value: isPinned,
                  onChanged: (v) => setState(() => isPinned = v),
                ),
                const Spacer(),
                const Text('Fontosság:'),
                DropdownButton(
                  value: importance,
                  dropdownColor: AppStyle.cardColor,
                  items:
                      ['low', 'normal', 'high']
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => importance = v!),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text('Mentés')),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
