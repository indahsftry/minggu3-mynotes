import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotesService {
  static const _key = 'notes';

  Future<List<String>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_key);

    if (notesJson == null) {
      return [];
    }

    return List<String>.from(jsonDecode(notesJson));
  }

  Future<void> createNote(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    notes.add(text);

    await prefs.setString(_key, jsonEncode(notes));
  }

  Future<void> deleteNote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    notes.removeAt(index);

    await prefs.setString(_key, jsonEncode(notes));
  }
}
