import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'add_note.dart';
import 'add_folder.dart';
import 'note_detail.dart'; // 🆕
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  List notes = [];
  List folders = [];
  String? selectedFolderId; // null = Összes

  /* --------- API-hívások --------- */
  Future<void> fetchNotes() async {
    final res = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes'),
    );
    if (res.statusCode == 200) setState(() => notes = jsonDecode(res.body));
  }

  Future<void> fetchFolders() async {
    final res = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (res.statusCode == 200) setState(() => folders = jsonDecode(res.body));
  }

  Future<void> assignNote(String id, String? folderId) async {
    final note = notes.firstWhere((n) => n['id'] == id);
    await http.put(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': note['title'],
        'content': note['content'],
        'pinned': note['pinned'],
        'importance': note['importance'],
        'folderId': folderId,
      }),
    );
    fetchNotes();
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
    fetchFolders();
  }

  @override
  Widget build(BuildContext context) {
    final visible =
        selectedFolderId == null
            ? notes
            : notes.where((n) => n['folderId'] == selectedFolderId).toList();

    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        title: Text(
          'NOTES',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppStyle.backgroundColor,
      ),

      /* --------- Szűrő ---------- */
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selectedFolderId,
              dropdownColor: AppStyle.cardColor,
              hint: const Text(
                'Összes',
                style: TextStyle(color: AppStyle.accentWhite),
              ),
              iconEnabledColor: AppStyle.accentWhite,
              items: [
                const DropdownMenuItem(value: null, child: Text('Összes')),
                ...folders.map(
                  (f) =>
                      DropdownMenuItem(value: f['id'], child: Text(f['name'])),
                ),
              ],
              onChanged: (val) => setState(() => selectedFolderId = val),
            ),
          ),

          /* --------- Lista ---------- */
          Expanded(
            child:
                visible.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (_, i) {
                        final n = visible[i];
                        final firstLine =
                            (n['content'] ?? '').split('\n').first;
                        return Card(
                          color:
                              n['pinned'] == true
                                  ? AppStyle.accentRed
                                  : AppStyle.cardColor,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              n['title'] ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              firstLine,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            onTap: () async {
                              final changed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => NoteDetailPage(
                                        note: n,
                                        folders: folders,
                                      ),
                                ),
                              );
                              if (changed == true) fetchNotes();
                            },
                            trailing: PopupMenuButton<String?>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppStyle.accentWhite,
                              ),
                              onSelected: (fid) => assignNote(n['id'], fid),
                              itemBuilder:
                                  (_) => [
                                    const PopupMenuItem(
                                      value: null,
                                      child: Text('Összes'),
                                    ),
                                    ...folders.map(
                                      (f) => PopupMenuItem(
                                        value: f['id'],
                                        child: Text(f['name']),
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      /* --------- Lebegő gomb -------- */
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: AppStyle.accentWhite),
        onPressed: () async {
          final choice = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: AppStyle.cardColor,
            builder:
                (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetItem('Új jegyzet', Icons.note_add, 'note'),
                    _sheetItem('Új mappa', Icons.create_new_folder, 'folder'),
                  ],
                ),
          );
          if (choice == 'note') {
            final ok = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddNotePage()),
            );
            if (ok == true) fetchNotes();
          } else if (choice == 'folder') {
            final ok = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFolderPage()),
            );
            if (ok == true) fetchFolders();
          }
        },
      ),
    );
  }

  ListTile _sheetItem(String txt, IconData ic, String val) => ListTile(
    leading: Icon(ic, color: AppStyle.accentWhite),
    title: Text(txt, style: const TextStyle(color: AppStyle.accentWhite)),
    onTap: () => Navigator.pop(context, val),
  );
}
