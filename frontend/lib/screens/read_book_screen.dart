import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:epub_view/epub_view.dart';

class ReadBookScreen extends StatefulWidget {
  final String fileUrl;

  ReadBookScreen({required this.fileUrl});

  @override
  _ReadBookScreenState createState() => _ReadBookScreenState();
}

class _ReadBookScreenState extends State<ReadBookScreen> {
  String? localFilePath;
  bool isSpeaking = false;
  FlutterTts flutterTts = FlutterTts();
  EpubController? epubController;
  bool isEpub = false;
  bool _isLoading = true;
  int _currentPage = 1; // Track current page for PDF extraction
  int _totalPages = 0; // Total pages of the PDF
  bool _readingInProgress = false; // Flag to control reading loop

  @override
  void initState() {
    super.initState();
    _determineFileType();
    _downloadAndOpenFile();
  }

  void _determineFileType() {
    if (widget.fileUrl.toLowerCase().endsWith('.epub')) {
      setState(() => isEpub = true);
    }
  }

  Future<void> _downloadAndOpenFile() async {
    try {
      var response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(tempDir.path, path.basename(widget.fileUrl));
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        setState(() => localFilePath = filePath);

        if (isEpub) {
          try {
            epubController = EpubController(
              document: EpubDocument.openFile(file),
            );
          } catch (e) {
            print("Error opening EPUB file: $e");
          }
        } else {
          final PdfDocument document = PdfDocument(
            inputBytes: file.readAsBytesSync(),
          );
          _totalPages = document.pages.count; // Get total number of pages
          document.dispose();
        }
      }
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to download file.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speakText() async {
    if (isSpeaking) {
      _readingInProgress = false; // Stop the reading loop
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      _readingInProgress = true;
      setState(() => isSpeaking = true);
      _readPageChunks(); // Start reading chunks
    }
  }

  Future<void> _readPageChunks() async {
    if (!_readingInProgress) return; // Stop if reading is cancelled
    if (_currentPage > _totalPages) {
      setState(() => isSpeaking = false); // Stop when all pages are read
      _currentPage = 1; // Reset for next reading
      return;
    }

    try {
      final PdfDocument document = PdfDocument(
        inputBytes: File(localFilePath!).readAsBytesSync(),
      );
      String text = PdfTextExtractor(
        document,
      ).extractText(startPageIndex: _currentPage, endPageIndex: _currentPage);
      document.dispose();

      if (text.isNotEmpty) {
        await flutterTts.setLanguage("en-US");
        await flutterTts.setPitch(1.0);
        await flutterTts.speak(text);

        await flutterTts.awaitSpeakCompletion(
          true,
        ); // Wait for speech to complete
      }

      _currentPage++;
      _readPageChunks(); // Read the next page
    } catch (e) {
      print("Error extracting/speaking page: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error reading page.")));
      setState(() => isSpeaking = false);
      _readingInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Read Book"),
        backgroundColor: Color(0xFF1976D2),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        localFilePath != null
                            ? isEpub
                                ? EpubView(controller: epubController!)
                                : PDFView(filePath: localFilePath!)
                            : Center(child: Text("Error loading book")),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed:
                          localFilePath != null && !isEpub
                              ? _speakText
                              : null, // Disable for EPUB
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isSpeaking ? "Stop Reading" : "Read Aloud"),
                    ),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    epubController?.dispose();
    super.dispose();
  }
}
