import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../styles/app_styles.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key});

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  final _nameC = TextEditingController();
  String _msg = '';

  /* ───────────────── SEND ── */
  Future<void> _submitFolder() async {
    final name = _nameC.text.trim();

    if (name.isEmpty) {
      setState(() => _msg = 'Please enter a folder name!');
      return;
    }

    final r = await http.post(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (r.statusCode == 200) {
      if (context.mounted) Navigator.pop(context, true);
    } else {
      setState(() => _msg = 'ERROR (${r.statusCode})');
    }
  }

  /* ───────────────── UI ── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        backgroundColor: AppStyle.background,
        title: Text(
          'NEW // FOLDER',
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
            /* ---- NAME ---- */
            TextField(
              controller: _nameC,
              style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
              decoration: InputDecoration(
                labelText: 'Folder name',
                labelStyle: GoogleFonts.orbitron(color: AppStyle.textSecondary),
                filled: true,
                fillColor: AppStyle.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /* ---- SAVE ---- */
            ElevatedButton(
              onPressed: _submitFolder,
              child: Text('SAVE', style: GoogleFonts.orbitron()),
            ),

            if (_msg.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_msg, style: GoogleFonts.orbitron(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
}
