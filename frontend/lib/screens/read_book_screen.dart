import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:epub_view/epub_view.dart'; // Add this package for EPUB support

class ReadBookScreen extends StatefulWidget {
  final String fileUrl;

  ReadBookScreen({required this.fileUrl});

  @override
  _ReadBookScreenState createState() => _ReadBookScreenState();
}

class _ReadBookScreenState extends State<ReadBookScreen> {
  String? localFilePath;
  String extractedText = "";
  bool isSpeaking = false;
  FlutterTts flutterTts = FlutterTts();
  EpubController? epubController; // Controller for EPUB rendering
  bool isEpub = false; // Dynamically set based on file extension

  @override
  void initState() {
    super.initState();
    _determineFileType(); // Determine if the file is EPUB or PDF
    _downloadAndOpenFile();
  }

  void _determineFileType() {
    // Check if the file URL ends with .epub
    if (widget.fileUrl.toLowerCase().endsWith('.epub')) {
      setState(() {
        isEpub = true;
      });
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
        setState(() {
          localFilePath = filePath;
        });

        if (isEpub) {
          // Initialize EPUB controller
          try {
            epubController = EpubController(
              document: EpubDocument.openFile(file),
            );
          } catch (e) {
            print("Error opening EPUB file: $e");
          }
        } else {
          _extractTextFromPdf(file); // Extract text for PDF
        }
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  Future<void> _extractTextFromPdf(File file) async {
    try {
      final PdfDocument document = PdfDocument(
        inputBytes: file.readAsBytesSync(),
      );
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      setState(() {
        extractedText = text;
      });
    } catch (e) {
      print("Error extracting text: $e");
    }
  }

  Future<void> _speakText() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(extractedText);
      setState(() => isSpeaking = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Read Book")),
      body: Column(
        children: [
          Expanded(
            child:
                localFilePath != null
                    ? isEpub
                        ? EpubView(controller: epubController!)
                        : PDFView(filePath: localFilePath!)
                    : Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: extractedText.isNotEmpty ? _speakText : null,
              child: Text(isSpeaking ? "Stop Reading" : "Read Aloud"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    epubController?.dispose(); // Dispose EPUB controller
    super.dispose();
  }
}
