// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:open_file/open_file.dart';

// Future<void> downloadAndOpenPDF(String url, BuildContext context) async {
//   try {
//     // Descarga el archivo PDF desde el servidor
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       // Obtén el directorio temporal
//       final directory = await getTemporaryDirectory();

//       // Crea el archivo PDF localmente
//       final filePath = '${directory.path}/exported_form.pdf';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);

//       // Abre el archivo PDF
//       OpenFile.open(filePath);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to download PDF: ${response.statusCode}')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error downloading PDF: $e')),
//     );
//   }
// }
