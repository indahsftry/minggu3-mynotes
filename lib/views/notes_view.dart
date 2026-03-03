import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final user = FirebaseAuth.instance.currentUser!;

  final DatabaseReference notesRef = FirebaseDatabase.instance.ref("notes");

  Future<void> showAddDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

              await notesRef.push().set({
                'text': controller.text.trim(),
                'owners': {user.uid: true},
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> showShareDialog(String key) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Share Note"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Friend Email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();

              if (email.isEmpty) return;

              final snapshot = await FirebaseDatabase.instance
                  .ref("users")
                  .orderByChild("email")
                  .equalTo(email)
                  .get();

              if (!snapshot.exists) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("User not found")));
                return;
              }

              final data = snapshot.value as Map<dynamic, dynamic>;

              final friendUid = data.keys.first;

              await FirebaseDatabase.instance
                  .ref("notes/$key/owners/$friendUid")
                  .set(true);

              Navigator.pop(context);
            },
            child: const Text("Share"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: notesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No notes yet"));
          }

          final Map<dynamic, dynamic> data =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          final currentUser = FirebaseAuth.instance.currentUser;

          final userNotes = data.entries.where((e) {
            final owners = e.value['owners'];
            if (owners == null || currentUser == null) {
              return false;
            }
            return owners[currentUser.uid] == true;
          }).toList();

          if (userNotes.isEmpty) {
            return const Center(child: Text("No notes yet"));
          }

          return ListView(
            children: userNotes.map((note) {
              final key = note.key.toString();
              final text = note.value['text'];

              return ListTile(
                title: Text(text),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => showShareDialog(key),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await notesRef.child(key).remove();
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
