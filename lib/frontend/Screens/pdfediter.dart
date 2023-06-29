import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class PDFEditorPage extends StatefulWidget {
  const PDFEditorPage({super.key});

  @override
  State<PDFEditorPage> createState() => _PDFEditorPageState();
}

class _PDFEditorPageState extends State<PDFEditorPage> {
  Uint8List? pdfBytes;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    pdfBytes = await _readPdfBytes();
    setState(() {});
  }

  Future<Uint8List> _readPdfBytes() async {
    final data = await rootBundle.load('assets/template.pdf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> _savePdf() async {
    if (pdfBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/template.pdf';
      final file = File(path);
      await file.writeAsBytes(pdfBytes!);
      print('PDF file saved at $path');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Opens an existing document from the list of bytes
    PdfDocument? document;
    if (pdfBytes != null) {
      document = PdfDocument(inputBytes: pdfBytes);
    }

    return Scaffold(
      appBar: AppBar(title: Text('PDF Editor')),
      body: Container(), // replace with your body
      floatingActionButton: FloatingActionButton(
        onPressed: _savePdf,
        child: Icon(Icons.save),
      ),
    );
  }
}
