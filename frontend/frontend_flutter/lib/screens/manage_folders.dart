import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../styles/app_styles.dart';

class ManageFoldersPage extends StatefulWidget {
  const ManageFoldersPage({super.key});

  @override
  State<ManageFoldersPage> createState() => _ManageFoldersPageState();
}

class _ManageFoldersPageState extends State<ManageFoldersPage> {
  List folders = [];

  /* ── REST ── */
  Future<void> _fetch() async {
    final r = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (r.statusCode == 200) setState(() => folders = jsonDecode(r.body));
  }

  Future<void> _delete(String id) async {
    final r = await http.delete(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders/$id'),
    );
    if (r.statusCode == 200) _fetch();
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  /* ───────────────────────── UI ── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(
        backgroundColor: AppStyle.background,
        title: Text(
          'FOLDER // MANAGER',
          style: GoogleFonts.orbitron(
            color: AppStyle.accentGreen,
            letterSpacing: 1.4,
          ),
        ),
      ),

      body:
          folders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemCount: folders.length,
                itemBuilder: (_, i) {
                  final f = folders[i];
                  return ListTile(
                    leading: const Icon(
                      Icons.folder,
                      color: AppStyle.accentYellow,
                    ),
                    title: Text(
                      f['name'],
                      style: GoogleFonts.orbitron(color: AppStyle.textPrimary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppStyle.accentRed),
                      tooltip: 'Delete folder',
                      onPressed: () async {
                        final yes = await showDialog<bool>(
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
                                  'All notes in the folder will also be lost!',
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
                        if (yes == true) _delete(f['id']);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
