/*  lib/screens/add_note.dart
    – CYBER-ORB  NOTE  CREATOR  */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../styles/app_styles.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  /* ─── controllers & state ─── */
  final _titleC = TextEditingController();
  final _contentC = TextEditingController();

  bool _pinned = false;
  String _importance = 'normal'; // low | normal | high
  String? _selectedFolder; // null → no folder
  List _folders = [];

  String _msg = '';

  /* ───────────────── HELPERS ───────────────── */

  /// neat InputDecoration in one place – Orbitron label
  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.orbitron(color: AppStyle.accentYellow),
  );

  /// string label → numeric priority
  int _prio(String label) => switch (label) {
    'high' => 2,
    'normal' => 1,
    _ => 0,
  };

  /// colored dot item for priority dropdown
  DropdownMenuItem<String> _prioItem(String value) {
    final col = AppStyle.importanceColor(
      value,
    ); // low→green / normal→yellow / high→red
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
          Text(value, style: GoogleFonts.orbitron()),
        ],
      ),
    );
  }

  /* ───────────────── REST ───────────────── */

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    final r = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (r.statusCode == 200) setState(() => _folders = jsonDecode(r.body));
  }

  Future<void> _submit() async {
    final title = _titleC.text.trim();
    final content = _contentC.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() => _msg = 'Tölts ki minden mezőt!');
      return;
    }

    final r = await http.post(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'pinned': _pinned,
        'priority': _prio(_importance),
        'folderId': _selectedFolder, // lehet null
      }),
    );

    if (r.statusCode == 200) {
      if (context.mounted) Navigator.pop(context, true);
    } else {
      setState(() => _msg = 'Hiba (${r.statusCode})');
    }
  }

  /* ───────────────── UI ───────────────── */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        backgroundColor: AppStyle.background,
        title: Text(
          'NEW // NOTE',
          style: GoogleFonts.orbitron(
            color: AppStyle.accentGreen,
            letterSpacing: 1.4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /* —— TITLE —— */
            TextField(
              controller: _titleC,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: _input('Cím'),
            ),
            const SizedBox(height: 10),

            /* —— CONTENT —— */
            TextField(
              controller: _contentC,
              maxLines: 6,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: _input('Tartalom'),
            ),

            /* —— FOLDER —— */
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedFolder,
              dropdownColor: AppStyle.surface,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: _input('Mappa'),
              hint: Text(
                'Mappa (opcionális)',
                style: GoogleFonts.orbitron(color: AppStyle.textSecondary),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('Nincs mappa', style: GoogleFonts.orbitron()),
                ),
                ..._folders.map<DropdownMenuItem<String>>(
                  (f) => DropdownMenuItem<String>(
                    value: f['id'].toString(),
                    child: Text(f['name'], style: GoogleFonts.orbitron()),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _selectedFolder = v),
            ),

            /* —— PIN  +  PRIORITY —— */
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                /* pin */
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Kitűzve:', style: GoogleFonts.orbitron()),
                    Switch(
                      value: _pinned,
                      activeColor: AppStyle.accentYellow,
                      onChanged: (v) => setState(() => _pinned = v),
                    ),
                  ],
                ),
                /* prio */
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Fontosság:', style: GoogleFonts.orbitron()),
                    const SizedBox(width: 6),
                    DropdownButton<String>(
                      value: _importance,
                      dropdownColor: AppStyle.surface,
                      style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                      items: [
                        _prioItem('low'),
                        _prioItem('normal'),
                        _prioItem('high'),
                      ],
                      onChanged: (v) => setState(() => _importance = v!),
                    ),
                  ],
                ),
              ],
            ),

            /* —— SAVE —— */
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text('MENTÉS', style: GoogleFonts.orbitron()),
            ),
            if (_msg.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_msg, style: GoogleFonts.orbitron(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
