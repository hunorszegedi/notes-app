/* lib/screens/notes_home.dart */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../styles/app_styles.dart';
import 'add_note.dart';
import 'add_folder.dart';
import 'note_detail.dart';
import 'manage_folders.dart';

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});
  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  String priorityToLabel(int priority) {
    switch (priority) {
      case 2:
        return 'high';
      case 1:
        return 'normal';
      case 0:
      default:
        return 'low';
    }
  }

  List notes = [];
  List folders = [];

  String? selectedFolderId; // null = "Összes"
  String searchQuery = '';
  String importanceFilter = 'all'; // all | high | normal | low

  String? _normalize(dynamic id) {
    if (id == null) return null;
    final s = id.toString();
    return s.isEmpty ? null : s;
  }

  String _fid(dynamic f) => _normalize(f['id']) ?? '';

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
        'priority': n['priority'],
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
    // apply filters: folder, search, importance
    List filtered =
        notes.where((n) {
          final byFolder =
              selectedFolderId == null ||
              _normalize(n['folderId']) == selectedFolderId;
          final q = searchQuery.toLowerCase();
          final bySearch =
              q.isEmpty ||
              (n['title'] ?? '').toString().toLowerCase().contains(q) ||
              (n['content'] ?? '').toString().toLowerCase().contains(q);
          final imp = priorityToLabel(n['priority'] ?? 1);
          final byImportance =
              importanceFilter == 'all' || imp == importanceFilter;
          return byFolder && bySearch && byImportance;
        }).toList();

    // pinned first
    final pinned = filtered.where((n) => n['pinned'] == true).toList();
    final others = filtered.where((n) => n['pinned'] != true).toList();

    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        title: const Text('NOTES', style: TextStyle(letterSpacing: 2)),
        backgroundColor: AppStyle.background,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => importanceFilter = v),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'all', child: Text('Minden')),
                  PopupMenuItem(value: 'high', child: Text('High priority')),
                  PopupMenuItem(
                    value: 'normal',
                    child: Text('Normal priority'),
                  ),
                  PopupMenuItem(value: 'low', child: Text('Low priority')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // folder filter dropdown
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String?>(
              isExpanded: true,
              value:
                  folders.any((f) => _fid(f) == selectedFolderId)
                      ? selectedFolderId
                      : null,
              dropdownColor: AppStyle.surface,
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
          // on-screen search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Keresés...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                if (pinned.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'PINNED',
                      style: TextStyle(fontFamily: 'DotMatrix'),
                    ),
                  ),
                  _noteGrid(pinned),
                ],
                if (others.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'ALL NOTES',
                      style: TextStyle(fontFamily: 'DotMatrix'),
                    ),
                  ),
                  _noteGrid(others),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.accentRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final choice = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: AppStyle.surface,
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

  Widget _noteGrid(List list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (_, i) => _noteCard(list[i]),
      ),
    );
  }

  Widget _noteCard(Map n) {
    final first = (n['content'] ?? '').split('\n').first;
    final imp = priorityToLabel(n['priority'] ?? 1);
    final col = AppStyle.importanceColor(imp);
    return InkWell(
      onTap: () async {
        final ch = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(note: n, folders: folders),
          ),
        );
        if (ch == true) fetchNotes();
      },
      child: Card(
        color: n['pinned'] == true ? AppStyle.accentRed : AppStyle.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n['title'] ?? '',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                first,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      imp,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: AppStyle.fontMono,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppStyle.textPrimary,
                    ),
                    onSelected: (value) async {
                      if (value == 'toggle_pin') {
                        final updated = Map<String, dynamic>.from(n);
                        updated['pinned'] = !(n['pinned'] == true);
                        await http.put(
                          Uri.parse(
                            'https://app-in-progress-457709.lm.r.appspot.com/notes/${n['id']}',
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(updated),
                        );
                        fetchNotes();
                      } else if (value == 'delete') {
                        await http.delete(
                          Uri.parse(
                            'https://app-in-progress-457709.lm.r.appspot.com/notes/${n['id']}',
                          ),
                        );
                        fetchNotes();
                      } else if (value == 'set_low' ||
                          value == 'set_normal' ||
                          value == 'set_high') {
                        final updated = Map<String, dynamic>.from(n);
                        updated['priority'] =
                            value == 'set_low'
                                ? 0
                                : value == 'set_normal'
                                ? 1
                                : 2;
                        await http.put(
                          Uri.parse(
                            'https://app-in-progress-457709.lm.r.appspot.com/notes/${n['id']}',
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(updated),
                        );
                        fetchNotes();
                      } else {
                        assignNote(n['id'], _normalize(value));
                      }
                    },
                    itemBuilder:
                        (_) => [
                          const PopupMenuItem<String>(
                            value: 'info',
                            enabled: false,
                            child: Text('Melyik mappába szeretnéd?'),
                          ),
                          const PopupMenuItem<String>(
                            value: null,
                            child: Text('Nincs mappa'),
                          ),
                          ...folders.map(
                            (f) => PopupMenuItem<String>(
                              value: _fid(f),
                              child: Text(f['name']),
                            ),
                          ),
                          const PopupMenuDivider(),

                          // Prioritás beállítás
                          const PopupMenuItem<String>(
                            value: 'info2',
                            enabled: false,
                            child: Text('Prioritás módosítása:'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'set_low',
                            child: Text('Alacsony (low)'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'set_normal',
                            child: Text('Normál (normal)'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'set_high',
                            child: Text('Magas (high)'),
                          ),

                          const PopupMenuDivider(),

                          PopupMenuItem<String>(
                            value: 'toggle_pin',
                            child: Text(
                              n['pinned'] == true
                                  ? 'Levétel a főoldalról'
                                  : 'Kitűzés',
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              'Törlés',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _sheetItem(String t, IconData i, String v) => ListTile(
    leading: Icon(i, color: AppStyle.textPrimary),
    title: Text(t, style: const TextStyle(color: AppStyle.textPrimary)),
    onTap: () => Navigator.pop(context, v),
  );
}

class _NoteSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
  );
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );
  @override
  Widget buildResults(BuildContext context) => const SizedBox();
  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox();
  @override
  void close(BuildContext context, String result) =>
      super.close(context, query);
}
