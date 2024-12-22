import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/model/note.dart';
import 'package:test/services/api_services.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  final Future<void> Function() onNoteUpdated;

  const EditNoteScreen({
    super.key,
    required this.note,
    required this.onNoteUpdated,
  });

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'Low';
  String _selectedColor = 'white';
  DateTime selectedDate = DateTime.now();
  late ApiService _apiService;

  static final Map<String, Color> _colorMap = {
    'white': Colors.white,
    'red': Colors.red.shade300,
    'yellow': Colors.yellow.shade300,
    'green': Colors.green.shade300,
    'blue': Colors.blue.shade300,
  };

  Color _getColor(String key) {
    return _colorMap[key] ?? Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _titleController.text = widget.note.title;
    _descriptionController.text = widget.note.description;
    _selectedPriority = widget.note.priority;
    _selectedColor = widget.note.color;
    selectedDate = widget.note.date;
  }

  void _selectColor(String color) {
    setState(() {
      _selectedColor = color;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _editNote() async {
    Note updatedNote = Note(
      id: widget.note.id,
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _selectedPriority,
      color: _selectedColor,
      date: selectedDate,
    );

    try {
      await _apiService.editNote(widget.note.id, updatedNote);
      widget.onNoteUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ghi chú đã được cập nhật thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật ghi chú')),
      );
    }
  }

  Future<void> _deleteNote() async {
    try {
      await _apiService.deleteNote(widget.note.id);
      widget.onNoteUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ghi chú đã được xóa thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi xóa ghi chú')),
      );
    }
  }

  void _confirmDeleteNote() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa ghi chú'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteNote();
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteNote,
            tooltip: 'Xóa ghi chú',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _editNote,
            tooltip: 'Lưu ghi chú',
          ),
        ],
      ),
      body: Container(
        color: _getColor(_selectedColor),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              value: _selectedPriority,
              onChanged: (newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
              items: <String>['Low', 'High', 'Very High']
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Chọn màu sắc tương ứng:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ['white', 'red', 'yellow', 'green', 'blue']
                  .map(
                    (color) => GestureDetector(
                      onTap: () => _selectColor(color),
                      child: CircleAvatar(
                        backgroundColor: _getColor(color),
                        radius: 20,
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Ngày: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
