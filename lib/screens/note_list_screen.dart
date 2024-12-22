import 'package:flutter/material.dart';
import 'package:test/model/note.dart';
import 'package:test/services/api_services.dart';
import 'package:test/screens/add_note_screen.dart';
import 'package:test/screens/edit_note_screen.dart';
import 'package:test/controller/note_search_delegate.dart';
import 'package:intl/intl.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  final ApiService apiService = ApiService();
  String _selectedPriority = '';

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
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final fetchedNotes = await apiService.fetchNotes();
    setState(() {
      notes = fetchedNotes;
      filteredNotes = _filterNotesByPriority(fetchedNotes);
    });
  }

  List<Note> _filterNotesByPriority(List<Note> allNotes) {
    if (_selectedPriority.isEmpty) {
      return allNotes;
    }
    return allNotes
        .where((note) => note.priority == _selectedPriority)
        .toList();
  }

  Future<void> _onRefresh() async {
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(
                  apiService: apiService,
                  onNoteUpdated: _loadNotes,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <String>['Low', 'High', 'Very High'].map((priority) {
                  return ChoiceChip(
                    label: Text(priority),
                    selected: _selectedPriority == priority,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = selected ? priority : '';
                        filteredNotes = _filterNotesByPriority(notes);
                      });
                    },
                    selectedColor: _getColor(priority),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNoteScreen(
                            note: note,
                            onNoteUpdated: _loadNotes,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: _getColor(
                          note.color),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title.isNotEmpty ? note.title : 'Untitled',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            if (note.description.isNotEmpty)
                              Text(
                                note.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                            const Spacer(),
                            Text(
                              note.priority,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getColor(
                                    note.priority), // Màu của mức độ ưu tiên
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(note.date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(onNoteAdded: _loadNotes),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
