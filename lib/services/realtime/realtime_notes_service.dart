import 'package:firebase_database/firebase_database.dart';

class RealtimeNotesService {
  final database = FirebaseDatabase.instance.ref("notes");

  Future<void> createNote({
    required String userId,
    required String text,
  }) async {
    await database.push().set({
      'owners': {userId: true},
      'text': text,
    });
  }

  Stream<DatabaseEvent> allNotes() {
    return database.onValue;
  }

  Future<void> deleteNote(String key) async {
    await database.child(key).remove();
  }

  Future<void> updateNote({required String key, required String text}) async {
    await database.child(key).update({'text': text});
  }
}
