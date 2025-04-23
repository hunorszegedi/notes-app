/* lib/screens/notes_home.dart */
import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'add_note.dart';
import 'add_folder.dart';
import 'note_detail.dart';
import 'manage_folders.dart';
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

  /* ------------ segédfüggvény: "" -> null, int -> String ------------ */
  String? _normalize(dynamic id) {
    if (id == null) return null;
    final s = id.toString();
    return s.isEmpty ? null : s;
  }

  String _fid(dynamic folder) => _normalize(folder['id']) ?? '';

  /* -------------------- API-k -------------------- */
  Future<void> fetchNotes() async {
    final r = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes'),
    );
    if (r.statusCode == 200) setState(() => notes = jsonDecode(r.body));
  }

  Future<void> fetchFolders() async {
    final r = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (r.statusCode == 200) setState(() => folders = jsonDecode(r.body));
  }

  Future<void> assignNote(String id, String? folderId) async {
    final n = notes.firstWhere((e) => e['id'] == id);
    await http.put(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': n['title'],
        'content': n['content'],
        'pinned': n['pinned'],
        'importance': n['importance'],
        'folderId': folderId, // lehet null
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
    // szűrés
    final vis =
        selectedFolderId == null
            ? notes
            : notes
                .where((n) => _normalize(n['folderId']) == selectedFolderId)
                .toList();

    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        title: const Text('NOTES'),
        backgroundColor: AppStyle.backgroundColor,
      ),

      /* ------------------ Szűrő ------------------ */
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String?>(
              isExpanded: true,
              value:
                  folders.any((f) => _fid(f) == selectedFolderId)
                      ? selectedFolderId
                      : null, // ha közben törölték
              dropdownColor: AppStyle.cardColor,
              iconEnabledColor: AppStyle.accentWhite,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Összes / nincs mappa'),
                ),
                ...folders.map(
                  (f) =>
                      DropdownMenuItem(value: _fid(f), child: Text(f['name'])),
                ),
              ],
              onChanged: (v) => setState(() => selectedFolderId = v),
            ),
          ),

          /* ----------------- Lista ----------------- */
          Expanded(
            child:
                vis.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: vis.length,
                      itemBuilder: (_, i) {
                        final n = vis[i];
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
                            title: Text(n['title'] ?? ''),
                            subtitle: Text(firstLine),
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
                              onSelected:
                                  (fid) => assignNote(n['id'], _normalize(fid)),
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppStyle.accentWhite,
                              ),
                              itemBuilder:
                                  (_) => [
                                    const PopupMenuItem(
                                      value: null,
                                      child: Text('Összes / nincs mappa'),
                                    ),
                                    ...folders.map(
                                      (f) => PopupMenuItem(
                                        value: _fid(f),
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

      /* -------------- FAB + bottom-sheet -------------- */
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
                    _sheetItem('Mappák kezelése', Icons.folder_open, 'manage'),
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
          } else if (choice == 'manage') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageFoldersPage()),
            );
            fetchFolders();
            fetchNotes();
          }
        },
      ),
    );
  }

  ListTile _sheetItem(String t, IconData i, String v) => ListTile(
    leading: Icon(i, color: AppStyle.accentWhite),
    title: Text(t, style: const TextStyle(color: AppStyle.accentWhite)),
    onTap: () => Navigator.pop(context, v),
  );
}
