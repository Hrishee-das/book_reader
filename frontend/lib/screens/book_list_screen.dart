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

    print("📌 Retrieved User Data in BookListScreen:");
    print("User Name: $storedName");
    print("User Email: $storedEmail");

    setState(() {
      userName = storedName;
      userEmail = storedEmail;
    });
  }

  void fetchBooks() async {
    List fetchedBooks = await ApiService.fetchBooks();
    setState(() => books = fetchedBooks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ebook Reader')),
      drawer: AppDrawer(name: userName, email: userEmail),
      body:
          books.isEmpty
              ? Center(child: Text("No books found. Upload one!"))
              : ListView.builder(
                itemCount: books.length,
                itemBuilder:
                    (context, index) =>
                        BookTile(book: books[index], refreshBooks: fetchBooks),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ApiService.uploadBook(fetchBooks),
        child: Icon(Icons.upload_file),
      ),
    );
  }
}
