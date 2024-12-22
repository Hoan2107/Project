import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/model/note.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.110.65:3001/api/Notes_list';

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((note) => Note.fromMap(note)).toList();
      } else {
        throw Exception('Không thể tải danh sách ghi chú');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách ghi chú: $e');
    }
  }

  Future<Note> addNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toMap()),
      );
      if (response.statusCode == 201) {
        return Note.fromMap(json.decode(response.body));
      } else {
        throw Exception('Không thể thêm ghi chú');
      }
    } catch (e) {
      throw Exception('Không thể thêm ghi chú: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );
      if (response.statusCode != 200) {
        throw Exception('Không thể xóa ghi chú');
      }
    } catch (e) {
      throw Exception('Không thể xóa ghi chú: $e');
    }
  }

  Future<Note> editNote(String id, Note note) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toMap()),
      );

      if (response.statusCode == 200) {
        return Note.fromMap(json.decode(response.body));
      } else {
        throw Exception('Không thể sửa ghi chú');
      }
    } catch (e) {
      throw Exception('Không thể sửa ghi chú: $e');
    }
  }
}
