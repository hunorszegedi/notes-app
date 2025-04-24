import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteDetailPage extends StatefulWidget {
  final Map note;
  final List folders;
  const NoteDetailPage({super.key, required this.note, required this.folders});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleC, _contentC;
  String? selectedFolder;
  bool pinned = false;
  int _priority = 1; // 0 = low, 1 = normal, 2 = high

  String? _norm(dynamic id) {
    if (id == null) return null;
    final s = id.toString();
    return s.isEmpty ? null : s;
  }

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.note['title']);
    _contentC = TextEditingController(text: widget.note['content']);
    selectedFolder = _norm(widget.note['folderId']);
    pinned = widget.note['pinned'] == true;
    _priority = widget.note['priority'] ?? 1;
  }

  Future<void> _save() async {
    await http.put(
      Uri.parse(
        'https://app-in-progress-457709.lm.r.appspot.com/notes/${widget.note['id']}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleC.text,
        'content': _contentC.text,
        'pinned': pinned,
        'priority': _priority,
        'folderId': selectedFolder,
      }),
    );
    if (context.mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    await http.delete(
      Uri.parse(
        'https://app-in-progress-457709.lm.r.appspot.com/notes/${widget.note['id']}',
      ),
    );
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.surface,
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
              style: const TextStyle(color: AppStyle.textPrimary),
              decoration: const InputDecoration(labelText: 'Cím'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentC,
              maxLines: 8,
              style: const TextStyle(color: AppStyle.textPrimary),
              decoration: const InputDecoration(labelText: 'Tartalom'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Kitűzve:',
                  style: TextStyle(color: AppStyle.textPrimary),
                ),
                Switch(
                  value: pinned,
                  onChanged: (v) => setState(() => pinned = v),
                  activeColor: Colors.red,
                ),
                const Spacer(),
                DropdownButton<String?>(
                  value:
                      widget.folders.any(
                            (f) => _norm(f['id']) == selectedFolder,
                          )
                          ? selectedFolder
                          : null,
                  dropdownColor: AppStyle.surface,
                  hint: const Text(
                    'Mappa',
                    style: TextStyle(color: AppStyle.textPrimary),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Nincs mappa'),
                    ),
                    ...widget.folders.map(
                      (f) => DropdownMenuItem(
                        value: _norm(f['id']),
                        child: Text(f['name']),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedFolder = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Fontosság:',
                  style: TextStyle(color: AppStyle.textPrimary),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _priority,
                  dropdownColor: AppStyle.surface,
                  style: const TextStyle(color: AppStyle.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Alacsony')),
                    DropdownMenuItem(value: 1, child: Text('Normál')),
                    DropdownMenuItem(value: 2, child: Text('Magas')),
                  ],
                  onChanged: (v) => setState(() => _priority = v!),
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
