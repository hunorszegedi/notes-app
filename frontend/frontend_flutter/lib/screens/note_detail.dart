import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../styles/app_styles.dart';

class NoteDetailPage extends StatefulWidget {
  final Map note;
  final List folders;

  const NoteDetailPage({super.key, required this.note, required this.folders});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  /* ── vezérlők & állapot ── */
  late final TextEditingController _titleC;
  late final TextEditingController _contentC;

  String? selectedFolder;
  bool pinned = false;
  int _priority = 1; // 0 low | 1 normal | 2 high

  // helper function to normalize folderId
  String? _norm(dynamic id) {
    final s = id?.toString() ?? '';
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

  /* ── REST ── */
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
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    await http.delete(
      Uri.parse(
        'https://app-in-progress-457709.lm.r.appspot.com/notes/${widget.note['id']}',
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  /* ── colored dot ── */
  /// Priority dot for the dropdown menu.
  Widget _prioDot(Color c) => Container(
    width: 10,
    height: 10,
    margin: const EdgeInsets.only(right: 6),
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  /* ─────────────────────────────── UI ── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.surface,
      appBar: AppBar(
        backgroundColor: AppStyle.background,
        title: Text(
          'DETAILS',
          style: GoogleFonts.orbitron(
            color: AppStyle.accentGreen,
            letterSpacing: 1.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppStyle.accentRed),
            tooltip: 'Delete note',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (_) => AlertDialog(
                      backgroundColor: AppStyle.surface,
                      title: Text(
                        'CONFIRM DELETE?',
                        style: GoogleFonts.orbitron(color: AppStyle.accentRed),
                      ),
                      content: Text(
                        'This note will be permanently deleted.',
                        style: GoogleFonts.orbitron(
                          color: AppStyle.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('CANCEL', style: GoogleFonts.orbitron()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
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
              if (confirm == true) _delete();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /* ---- title ---- */
            TextField(
              controller: _titleC,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: InputDecoration(
                labelText: 'TITLE',
                labelStyle: GoogleFonts.orbitron(color: AppStyle.textSecondary),
              ),
            ),

            const SizedBox(height: 10),

            /* --- content ---- */
            TextField(
              controller: _contentC,
              maxLines: 8,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: InputDecoration(
                labelText: 'CONTENT',
                labelStyle: GoogleFonts.orbitron(color: AppStyle.textSecondary),
              ),
            ),

            const SizedBox(height: 24),

            /* ---- PIN + FOLDER ---- */
            Row(
              children: [
                Text(
                  'PIN',
                  style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                ),
                Switch(
                  value: pinned,
                  activeColor: AppStyle.accentGreen,
                  inactiveTrackColor: AppStyle.textSecondary,
                  onChanged: (v) => setState(() => pinned = v),
                ),
                const Spacer(),
                DropdownButton<String?>(
                  dropdownColor: AppStyle.surface,
                  value:
                      widget.folders.any(
                            (f) => _norm(f['id']) == selectedFolder,
                          )
                          ? selectedFolder
                          : null,
                  hint: Text(
                    'FOLDER',
                    style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                  ),
                  style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No folder'),
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

            /* ---- PRIORITY ---- */
            Row(
              children: [
                Text(
                  'PRIORITY',
                  style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  dropdownColor: AppStyle.surface,
                  value: _priority,
                  style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          _prioDot(AppStyle.accentGreen),
                          const Text('LOW'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          _prioDot(AppStyle.accentYellow),
                          const Text('NORMAL'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          _prioDot(AppStyle.accentRed),
                          const Text('HIGH'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _priority = v!),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /* ---- SAVE ---- */
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.accentGreen,
                  foregroundColor: AppStyle.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('SAVE', style: GoogleFonts.orbitron()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
