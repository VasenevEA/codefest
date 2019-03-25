import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get getlocalPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File>   getFile(String name) async {
  final path = await getlocalPath;
  return File('$path/$name');
}

Future<File> writeFile(String name, String content) async {
  final file = await getFile(name);

  // Write the file
  return file.writeAsString('$content');
}