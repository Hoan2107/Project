import 'package:flutter/material.dart';
import 'package:test/model/note.dart';
import 'package:test/screens/edit_note_screen.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final Future<void> Function() onNoteUpdated;

  const NoteListTile({
    super.key,
    required this.note,
    required this.onNoteUpdated,
  });

  static final Map<String, Color> _colorMap = {
    'white': Colors.white,
    'red': Colors.red.shade300,
    'yellow': Colors.yellow.shade300,
    'green': Colors.green.shade300,
    'blue': Colors.blue.shade300,
    'Low': Colors.green,
    'High': Colors.yellow,
    'Very High': Colors.red,
  };

  Color _getColor(String? key) {
    return _colorMap[key] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    Color noteColor = _getColor(note.color);
    Color priorityColor = _getColor(note.priority);

    if (note.title.isEmpty) {
      return const SizedBox.shrink();
    }

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
      child: Card(
        color: noteColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                note.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              if (note.description.isNotEmpty)
                Text(
                  note.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8.0),
              Text(
                'Ngày: ${note.date.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 8.0),
              Text(
                note.priority ?? 'Low',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: priorityColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
