import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'utils.dart';


Future<List<List<Any>>> uReadCsv(String fileName) async {
  var path = await uGetFileFullPath(fileName);
  final input = File(path).openRead();
  final listData =
      await input
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();

  //var rData = await uReadFromFile(fileName);
  //var file = File(path);
  //var rData = file.readAsStringSync();

  /*
  List<List<Any>> listData =
      CsvToListConverter(
        fieldDelimiter: ",",
        eol: "\n",
        shouldParseNumbers: false,
      ).convert(rData).toList();
      */
  return listData;
}

Future<void> uWriteCsv(String fileName, List<List<Any>> toWrite) async {
  var res = ListToCsvConverter().convert(toWrite);

  await uWriteToFile(fileName, res);
}
