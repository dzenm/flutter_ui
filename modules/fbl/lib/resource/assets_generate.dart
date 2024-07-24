import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

///
/// Created by a0010 on 2024/4/7 11:04
///
class AssetsGenerate {

  /// [dir]资源所在文件夹
  /// [generateDir]传入生成的类所在文件夹
  void generateAssets(String dir, String generateDir) {
    List<String> allFile = [];
    String dirName = '';
    String assetsPath = path.join(path.current, dir);
    Directory directory = Directory(assetsPath);
    if (directory.existsSync()) {
      List<FileSystemEntity> files = directory.listSync();
      if (files.isNotEmpty) {
        for (var file in files) {
          if (file.statSync().type == FileSystemEntityType.file) {
            dirName = path.basename(file.parent.path);
            String fileName = path.basename(file.path);
            allFile.add(fileName);
          } else {
            generateAssets(file.path, generateDir);
          }
        }
        autoGenerate(allFile, dirName, generateDir);
      } else {
        debugPrint('该文件夹为空');
      }
    } else {
      directory.createSync();
      generateAssets(dir, generateDir);
    }
  }

  void autoGenerate(List<String> files, String dirName, String generateDir) {
    if (files.isEmpty) return;

    String utilsPath = path.join(path.current, 'lib', generateDir, '$dirName.dart');
    File file = File(utilsPath);
    if (file.existsSync()) {
      String contents = '''
  const String ${dirName}Path = 'assets/$dirName';
  class App${dirName.capitalize()} {''';
      for (var file in files) {
        String fileName = file.contains('-') ? file.hump('-').split('.').first : file.split('.').first;
        contents += "static String $fileName = '\$${dirName}Path/$file';";
      }
      contents += '}';
      file.writeAsStringSync(contents);
    } else {
      file.createSync();
      autoGenerate(files, dirName, generateDir);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String hump(String interval) {
    List<String> allChar = split(interval);
    for (var i = 1; i < allChar.length; i++) {
      allChar[i] = allChar[i].capitalize();
    }
    return allChar.join();
  }
}
