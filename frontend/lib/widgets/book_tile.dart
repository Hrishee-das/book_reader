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
          title: Text(
            "Confirm Deletion",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Are you sure you want to delete '${book['title']}'?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ApiService.deleteBook(book['_id'], refreshBooks);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // Use InkWell for better visual feedback
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ReadBookScreen(
                      fileUrl:
                          'http://192.168.121.124:5000/' + book['filePath'],
                    ),
              ),
            ),
        borderRadius: BorderRadius.circular(12), // Match Card's border radius
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Increased vertical padding
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ), // Larger title
                      maxLines: 2, // Limit to two lines
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis if too long
                    ),
                    SizedBox(height: 4), // Add some spacing
                    Text(
                      book['author'] ??
                          'Unknown Author', // Display author or "Unknown"
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
