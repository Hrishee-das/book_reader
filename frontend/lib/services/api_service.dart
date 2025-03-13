import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ApiService {
  //Enter your base here :)
  //http://YourAddress:5000/api
  //In console hit command ipconfig, copy IPv4 Address
  static const String baseUrl = "http://192.168.121.124:5000/api";

  // Fetch Books
  static Future<List> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  // Upload Book
  static Future<void> uploadBook(Function refreshBooks) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/books/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('book', file.path));
      var response = await request.send();
      if (response.statusCode == 200) refreshBooks();
    }
  }

  // Delete Book
  static Future<void> deleteBook(String bookId, Function refreshBooks) async {
    final response = await http.delete(Uri.parse('$baseUrl/books/$bookId'));
    if (response.statusCode == 200) refreshBooks();
  }

  // Signup User
  static Future<Map<String, dynamic>?> signupUser(
    String name,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
      }),
    );

    return response.statusCode == 201 ? json.decode(response.body) : null;
  }

  // Login User
  static Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    return response.statusCode == 200 ? json.decode(response.body) : null;
  }
}
