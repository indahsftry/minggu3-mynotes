import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../services/notes/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final AuthService authService = AuthService();
  final NotesService notesService = NotesService();

  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final allNotes = await notesService.getNotes();
    setState(() {
      notes = allNotes;
    });
  }

  Future<void> addNoteDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Note"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                await notesService.createNote(controller.text.trim());

                Navigator.pop(context);
                await loadNotes();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNoteDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text("Welcome ${user?.email}"),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text("No notes yet"))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notes[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await notesService.deleteNote(index);
                            await loadNotes();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
