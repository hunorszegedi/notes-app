import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles/app_styles.dart';

class ManageFoldersPage extends StatefulWidget {
  const ManageFoldersPage({super.key});

  @override
  State<ManageFoldersPage> createState() => _ManageFoldersPageState();
}

class _ManageFoldersPageState extends State<ManageFoldersPage> {
  List folders = [];

  /* --------- lekérés --------- */
  Future<void> _fetch() async {
    final res = await http.get(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders'),
    );
    if (res.statusCode == 200) setState(() => folders = jsonDecode(res.body));
  }

  /* --------- törlés --------- */
  Future<void> _delete(String id) async {
    final ok = await http.delete(
      Uri.parse('https://app-in-progress-457709.lm.r.appspot.com/folders/$id'),
    );
    if (ok.statusCode == 200) _fetch();
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      appBar: AppBar(title: const Text('Mappák kezelése')),
      body:
          folders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: folders.length,
                itemBuilder: (_, i) {
                  final f = folders[i];
                  return ListTile(
                    title: Text(
                      f['name'],
                      style: const TextStyle(color: AppStyle.textPrimary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final yes = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Biztos törlöd?'),
                                content: const Text(
                                  'A mappa jegyzetei is törlődni fognak!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Mégse'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Törlés'),
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
