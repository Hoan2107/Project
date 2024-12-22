import 'package:flutter/material.dart';
import 'package:test/model/note.dart';
import 'package:test/services/api_services.dart';
import 'package:test/widgets/note_list_tile.dart';
import 'package:test/screens/edit_note_screen.dart';

class NoteSearchDelegate extends SearchDelegate {
  final ApiService apiService;
  final Future<void> Function() onNoteUpdated;

  NoteSearchDelegate({required this.apiService, required this.onNoteUpdated});

  // Tìm kiếm ghi chú
  Future<List<Note>> _searchNotes(String query) async {
    if (query.isEmpty) {
      return await apiService.fetchNotes();
    }
    final allNotes = await apiService.fetchNotes();
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: _searchNotes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không tìm thấy kết quả nào.'));
        } else {
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(
                        note: note,
                        onNoteUpdated: onNoteUpdated,
                      ),
                    ),
                  );
                },
                child: NoteListTile(
                  note: note,
                  onNoteUpdated: onNoteUpdated,
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: _searchNotes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có gợi ý nào.'));
        } else {
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(
                        note: note,
                        onNoteUpdated: onNoteUpdated,
                      ),
                    ),
                  );
                },
                child: NoteListTile(
                  note: note,
                  onNoteUpdated: onNoteUpdated,
                ),
              );
            },
          );
        }
      },
    );
  }
}
