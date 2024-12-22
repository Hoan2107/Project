import 'package:flutter/material.dart';
import 'package:test/model/note.dart';
import 'package:test/services/api_services.dart';

class AddNoteScreen extends StatefulWidget {
  final Function onNoteAdded;

  const AddNoteScreen({super.key, required this.onNoteAdded});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'Low';
  DateTime? _selectedDate;
  String _selectedColor = 'white';
  late ApiService _apiService;
  Color _backgroundColor = Colors.white;

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

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  Color _getColor(String? key) {
    return _colorMap[key] ?? Colors.grey;
  }

  void _selectColor(String color) {
    setState(() {
      _selectedColor = color;
      _backgroundColor = _getColor(color);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addNote() async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String priority = _selectedPriority;
    String color = _selectedColor;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày')),
      );
      return;
    }

    Note newNote = Note(
      id: '',
      title: title,
      description: description,
      priority: priority,
      color: color,
      date: _selectedDate!,
    );

    try {
      await _apiService.addNote(newNote);
      widget.onNoteAdded();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm ghi chú thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi thêm ghi chú')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _addNote,
          ),
        ],
      ),
      body: Container(
        color: _backgroundColor,
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
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
              items: <String>['Low', 'High', 'Very High']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Chọn màu sắc tương ứng:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <String>['white', 'red', 'yellow', 'green', 'blue']
                  .map((color) => GestureDetector(
                        onTap: () => _selectColor(color),
                        child: CircleAvatar(
                          backgroundColor: _getColor(color),
                          radius: 20,
                          child: _selectedColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : Container(),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(_selectedDate == null
                    ? 'Chưa có ngày nào được chọn!'
                    : 'Ngày: ${_selectedDate!.toLocal()}'),
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
