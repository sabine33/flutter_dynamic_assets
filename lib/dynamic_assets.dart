library dynamic_assets;

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// const dynamicAssets = DynamicAssets.loadFromUrl(''); //Stream<int>
// DynamicAssets.isFirstRun()
// DynamicAssets.isAssetsAvailable()
// DynamicAssets.getAssets();

class DynamicAssets {
  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$filename");
  }

  static Stream<double> _showDownloadProgress(int received, int total) async* {
    if (total != -1) {
      yield (received / total * 100); //.toStringAsFixed(0) + "%");
    }
  }

  File _getDownloadedFile(String name, String dir) {
    return File('$dir/$name');
  }

  ///Download assets from cloud to specified path
  //[url] is the url to download assets from
  //[dir] is the directory to download URL into
  //[filename] is the filename of the content you want to download
  Future<void> downloadAssets(String url, String? dir, String filename,
      {Function(int, int)? onReceiveProgress}) async {
    dir = dir ?? (await getApplicationDocumentsDirectory()).path;

    // if (await checkIfFileExists(dir, filename)) {
    //   print("FILE ALREADY EXISTS");
    //   print("DELETING AND REDOWNLOADING");
    //   await Directory('$dir/$filename').delete(recursive: true);
    // } else {
    //   print("File doesn't exists");
    // }

    var response = await Dio().get(
      url,
      onReceiveProgress: onReceiveProgress ?? _showDownloadProgress,
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
    var file = File('$dir/$filename');
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
  }

  Future<void> extractZip(String? dir, String filename) async {
    dir = dir ?? (await getApplicationDocumentsDirectory()).path;

    print(dir);
    final zippedFile = File('$dir/$filename');
    print(zippedFile.lengthSync());
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var filename = '$dir/${file.name}';
      if (file.isFile) {
        var outFile = File(filename);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  Future<bool> checkIfFileExists(String? dir, String filename) async {
    dir = dir ?? (await getApplicationDocumentsDirectory()).path;
    var file = File('$dir/$filename');
    return (file.exists());
  }

  Future<String> getDownloadedContentPath(String? dir, String filename) async {
    dir = dir ?? (await getApplicationDocumentsDirectory()).path;
    return '$dir/$filename';
  }

  Future<List<FileSystemEntity>> getAllFiles(
      String? dir, String? folderName, bool isRecursive) async {
    dir =
        dir ?? (await getApplicationDocumentsDirectory()).path + "/$folderName";
    Directory directory = Directory(dir);
    var fileFoldersList = await directory.list(recursive: isRecursive).toList();
    print(fileFoldersList);
    return fileFoldersList;
  }
}
