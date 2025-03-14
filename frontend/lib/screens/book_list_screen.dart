import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/drawer.dart';
import '../widgets/book_tile.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  String userName = "";
  String userEmail = "";
  List books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchBooks();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    String storedName = prefs.getString('userName') ?? "Unknown";
    String storedEmail = prefs.getString('userEmail') ?? "Unknown";

    setState(() {
      userName = storedName;
      userEmail = storedEmail;
    });
  }

  void fetchBooks() async {
    setState(() {
      _isLoading = true;
    });
    List fetchedBooks = await ApiService.fetchBooks();
    setState(() {
      books = fetchedBooks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quest'), backgroundColor: Color(0xFF1976D2)),
      drawer: AppDrawer(name: userName, email: userEmail),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? Center(
                child: Text(
                  "No books found. Upload one!",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                itemCount: books.length,
                itemBuilder:
                    (context, index) =>
                        BookTile(book: books[index], refreshBooks: fetchBooks),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ApiService.uploadBook(fetchBooks),
        child: Icon(Icons.upload_file, color: Colors.white), // White icon
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }
}
