import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<File> generateDoc(List<dynamic> args) async {

  final RootIsolateToken rootIsolateToken = args[3] as RootIsolateToken;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  final fontData1 = args[4];
  final fontData2 = args[5];

  var customFont1 = pw.Font.ttf(fontData1);
  var customFont2 = pw.Font.ttf(fontData2);

  final pw.Document pdf = pw.Document();

  String title = args[0];
  String content = args[1];
  List<dynamic> imagePaths = args[2];

  bool isArabicTitle = args[6];
  bool isArabicContent = args[7];

  pdf.addPage(pw.MultiPage(
    maxPages: 10000,
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
                title,
                textDirection: isArabicTitle ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                style: pw.TextStyle(
                  fontSize: 26.0,
                  letterSpacing: 0.6,
                  fontWeight: pw.FontWeight.bold,
                  font: isArabicTitle ? customFont2 : customFont1,
                )),
            pw.SizedBox(
              height: 20.0,
            ),
            ...splitTextIntoChunks(content, 700) // Split long text into chunks
                .map((chunk) => pw.Text(
              chunk,
              textDirection: isArabicContent ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              style: pw.TextStyle(
                fontSize: 18.0,
                letterSpacing: 0.8,
                height: 2.2,
                fontWeight: pw.FontWeight.bold,
                font: isArabicContent ? customFont2 : customFont1,
              ),
            )),
            if (imagePaths.isNotEmpty) ...[
              pw.SizedBox(
                height: 40.0,
              ),
              pw.Wrap(
                direction: pw.Axis.horizontal,
                children: imagePaths
                    .map((imagePath) => buildItemImage(imagePath['image']))
                    .toList(),
                spacing: 80.0, // Spacing between images
                runSpacing: 30.0, // Spacing between rows
              ),
            ],
          ]
        ),
      ]));

  return saveDocument(name: '${title}_Note.pdf', pdf: pdf);
}


List<String> splitTextIntoChunks(String text, int chunkSize) {
  List<String> chunks = [];

  for (int i = 0; i < text.length; i += chunkSize) {
    int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
    chunks.add(text.substring(i, end));
  }

  return chunks;
}


pw.Widget buildItemImage(String imagePath) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(
        width: 1.0,
        color: PdfColors.blueGrey,
      ),
    ),
    child: pw.Image(
      pw.MemoryImage((File(imagePath).readAsBytesSync()).buffer.asUint8List()),
      width: 200,
      height: 300,
      fit: pw.BoxFit.contain,
    ),
  );
}


Future<File> saveDocument({
  required String name,
  required pw.Document pdf,
}) async {
  final bytes = await pdf.save();

  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File('${dir.path}/$name');

  await file.writeAsBytes(bytes);

  return file;
}


Future openFile(File file) async {
  final String path = file.path;

  await OpenFilex.open(path);
}

