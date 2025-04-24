import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

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
  // delete sfx
  final AudioPlayer _deleteSfx = AudioPlayer();

  // state variables
  List notes = [];
  List folders = [];
  String? selectedFolderId; // null → összes
  String searchQuery = '';
  String importanceFilter = 'all'; // all | high | normal | low

  // helper functions
  String? _norm(dynamic id) {
    final s = id?.toString() ?? '';
    return s.isEmpty ? null : s;
  }

  String _fid(dynamic f) => _norm(f['id']) ?? '';

  String _prioLabel(int p) => switch (p) {
    2 => 'high',
    1 => 'normal',
    _ => 'low',
  };

  // REST API functions
  Future<void> _fetchNotes() async {
    final r = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes'),
    );
    if (r.statusCode == 200) setState(() => notes = jsonDecode(r.body));
  }

  Future<void> _fetchFolders() async {
    final r = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (r.statusCode == 200) setState(() => folders = jsonDecode(r.body));
  }

  Future<void> _updateNote(Map n) async {
    await http.put(
      Uri.parse(
        'https://app-in-progress-457709.lm.r.appspot.com/notes/${n['id']}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(n),
    );
    _fetchNotes();
  }

  Future<void> _deleteNote(String id) async {
    await _deleteSfx.play(AssetSource('sfx/delete.mp3'));
    await http.delete(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes/$id'),
    );
    _fetchNotes();
  }

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _fetchFolders();
  }

  /* ───────────────────────── UI ── */
  @override
  Widget build(BuildContext context) {
    // check if folders are loaded
    final filtered =
        notes.where((n) {
          final byFolder =
              selectedFolderId == null ||
              _norm(n['folderId']) == selectedFolderId;
          final byText =
              searchQuery.isEmpty ||
              (n['title'] ?? '').toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              (n['content'] ?? '').toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
          final byPrio =
              importanceFilter == 'all' ||
              _prioLabel(n['priority'] ?? 1) == importanceFilter;
          return byFolder && byText && byPrio;
        }).toList();

    final pinned = filtered.where((n) => n['pinned'] == true).toList();
    final others = filtered.where((n) => n['pinned'] != true).toList();

    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        backgroundColor: AppStyle.background,
        title: Text(
          'NOTES',
          style: GoogleFonts.orbitron(
            color: AppStyle.accentGreen,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppStyle.accentGreen),
            onSelected: (v) => setState(() => importanceFilter = v),
            itemBuilder:
                (_) => [
                  _prioMenuItem(
                    value: 'all',
                    label: 'All notes',
                    color: Colors.grey.shade600,
                  ),
                  _prioMenuItem(
                    value: 'low',
                    label: 'Low priority',
                    color: AppStyle.accentGreen,
                  ),
                  _prioMenuItem(
                    value: 'normal',
                    label: 'Normal priority',
                    color: AppStyle.accentYellow,
                  ),
                  _prioMenuItem(
                    value: 'high',
                    label: 'High priority',
                    color: AppStyle.accentRed,
                  ),
                ],
          ),
        ],
      ),

      body: Column(
        children: [
          // folder selector & search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String?>(
              isExpanded: true,
              dropdownColor: AppStyle.surface,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              value:
                  folders.any((f) => _fid(f) == selectedFolderId)
                      ? selectedFolderId
                      : null,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All / no folder'),
                ),
                ...folders.map(
                  (f) =>
                      DropdownMenuItem(value: _fid(f), child: Text(f['name'])),
                ),
              ],
              onChanged: (v) => setState(() => selectedFolderId = v),
            ),
          ),

          // search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.orbitron(color: AppStyle.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppStyle.accentGreen,
                ),
                filled: true,
                fillColor: AppStyle.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),

          // search results
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                if (pinned.isNotEmpty) ...[
                  _sectionHeader('PINNED'),
                  _noteGrid(pinned),
                ],
                if (others.isNotEmpty) ...[
                  _sectionHeader('ALL NOTES'),
                  _noteGrid(others),
                ],
              ],
            ),
          ),
        ],
      ),

      // floating action button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final choice = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: AppStyle.surface,
            builder:
                (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetItem('New Note', Icons.note_add, 'note'),
                    _sheetItem('New Folder', Icons.create_new_folder, 'folder'),
                    _sheetItem('Manage Folders', Icons.folder_open, 'manage'),
                  ],
                ),
          );

          if (choice == 'note') {
            if (await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNotePage()),
                ) ==
                true)
              _fetchNotes();
          } else if (choice == 'folder') {
            if (await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFolderPage()),
                ) ==
                true)
              _fetchFolders();
          } else if (choice == 'manage') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageFoldersPage()),
            );
            _fetchFolders();
            _fetchNotes();
          }
        },
      ),
    );
  }

  // section header for pinned and all notes
  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      t,
      style: GoogleFonts.orbitron(color: AppStyle.accentGreen, fontSize: 18),
    ),
  );

  Widget _noteGrid(List list) => Padding(
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

  Widget _noteCard(Map n) {
    final firstLine = (n['content'] ?? '').split('\n').first;
    final prioLabel = _prioLabel(n['priority'] ?? 1);
    final prioColour = AppStyle.importanceColor(prioLabel);

    return Card(
      color: n['pinned'] == true ? AppStyle.accentYellow : AppStyle.surface,
      child: InkWell(
        /* ---- kopp → részletes szerkesztő ---- */
        onTap: () async {
          if (await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteDetailPage(note: n, folders: folders),
                ),
              ) ==
              true)
            _fetchNotes();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n['title'] ?? '',
                style: GoogleFonts.orbitron(
                  color: AppStyle.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                firstLine,
                style: GoogleFonts.orbitron(
                  color: AppStyle.textSecondary,
                  fontSize: 12,
                ),
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
                      color: prioColour,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prioLabel,
                      style: GoogleFonts.orbitron(
                        color: AppStyle.textPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppStyle.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => _showOptions(n),
                    tooltip: 'Műveletek',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // show options for note (edit, delete, etc.)
  Future<void> _showOptions(Map note) async {
    final currentPrio = note['priority'] ?? 1;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.surface,
      isScrollControlled: true,
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder:
                (_, controller) => ListView(
                  controller: controller,
                  children: [
                    ListTile(
                      title: Text(
                        'Select folder:',
                        style: GoogleFonts.orbitron(),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.inbox),
                      title: Text('No folder', style: GoogleFonts.orbitron()),
                      onTap: () {
                        _updateNote({...note, 'folderId': null});
                        Navigator.pop(context);
                      },
                    ),
                    ...folders.map(
                      (f) => ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(f['name'], style: GoogleFonts.orbitron()),
                        onTap: () {
                          _updateNote({...note, 'folderId': _fid(f)});
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: Icon(
                        note['pinned'] == true
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                      ),
                      title: Text(
                        note['pinned'] == true ? 'Unpin' : 'Pin',
                        style: GoogleFonts.orbitron(),
                      ),
                      onTap: () {
                        _updateNote({
                          ...note,
                          'pinned': !(note['pinned'] == true),
                        });
                        Navigator.pop(context);
                      },
                    ),

                    const Divider(),

                    ListTile(
                      title: Text(
                        'Priority',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (final p in [
                      {'v': 0, 'l': 'low'},
                      {'v': 1, 'l': 'normal'},
                      {'v': 2, 'l': 'high'},
                    ])
                      RadioListTile(
                        value: p['v'],
                        groupValue: currentPrio,
                        title: Text(
                          p['l'] as String,
                          style: GoogleFonts.orbitron(),
                        ),
                        onChanged: (_) {
                          _updateNote({...note, 'priority': p['v']});
                          Navigator.pop(context);
                        },
                      ),

                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: AppStyle.accentRed,
                      ),
                      title: Text(
                        'Delete',
                        style: GoogleFonts.orbitron(color: AppStyle.accentRed),
                      ),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                backgroundColor: AppStyle.surface,
                                title: Text(
                                  'CONFIRM DELETE?',
                                  style: GoogleFonts.orbitron(
                                    color: AppStyle.accentRed,
                                  ),
                                ),
                                content: Text(
                                  'This note will be permanently deleted.',
                                  style: GoogleFonts.orbitron(
                                    color: AppStyle.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text(
                                      'CANCEL',
                                      style: GoogleFonts.orbitron(),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      'DELETE',
                                      style: GoogleFonts.orbitron(
                                        color: AppStyle.accentRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          _deleteNote(note['id']);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  // sheet item for floating action button
  ListTile _sheetItem(String t, IconData i, String v) => ListTile(
    leading: Icon(i, color: AppStyle.textPrimary),
    title: Text(t, style: GoogleFonts.orbitron(color: AppStyle.textPrimary)),
    onTap: () => Navigator.pop(context, v),
  );

  // priority menu item for popup menu
  PopupMenuItem<String> _prioMenuItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(label, style: GoogleFonts.orbitron()),
        ],
      ),
    );
  }
}
