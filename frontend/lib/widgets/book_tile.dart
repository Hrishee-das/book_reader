import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/read_book_screen.dart';

class BookTile extends StatelessWidget {
  final Map book;
  final Function refreshBooks;

  BookTile({required this.book, required this.refreshBooks});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete '${book['title']}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ApiService.deleteBook(book['_id'], refreshBooks); // Delete book
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(book['title']),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _confirmDelete(context),
      ),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ReadBookScreen(
                    fileUrl: 'http://192.168.121.124:5000/' + book['filePath'],
                  ),
            ),
          ),
    );
  }
}
