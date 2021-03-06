import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as path;

Future<List<FileSystemEntity>> readdir(String dirStr) {
  final dir = new Directory(dirStr);
  var files = <FileSystemEntity>[];
  var completer = new Completer();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files)
  );
  return completer.future;
}

Future<Directory> ensuredir(String dirStr) async {
  var isExistComplete = new Completer();
  Directory dir = new Directory(dirStr);
  dir.exists()
      .then((isExist) {
    isExistComplete.complete(isExist);
  })
      .catchError(() {
    isExistComplete.complete(false);
  });

  bool isExist = await isExistComplete.future;

  if (isExist == false) await dir.create();
  return dir;
}

Future<File> ensurefile(String fileStr) async {
  var isExistComplete = new Completer();
  File file = new File(fileStr);
  file.exists()
      .then((isExist) {
    isExistComplete.complete(isExist);
  })
      .catchError(() {
    isExistComplete.complete(false);
  });

  bool isExist = await isExistComplete.future;

  if (isExist == false) await file.create();
  return file;
}

Future<Directory> removedir(String dirStr) async {
  final dir = await ensuredir(dirStr);
  await dir.delete(recursive: true);
  return dir;
}

Future<Directory> createTemp(String dirStr) async {
  Directory dir = new Directory(dirStr);
  return await dir.createTemp('gpm-');
}

Future<Object> readJson(String file) async {
  String contents = await new File(file).readAsString();
  Object output = {};
  try {
    output = new JsonDecoder().convert(contents);
  } catch (err) {

  }
  return output;
}

Future<File> writeJson(String file, Object object) async {
  File jsonFile = await ensurefile(file);
  return jsonFile.writeAsString(new JsonEncoder.withIndent('  ').convert(object));
}

Future isExistDir(String dirStr) async {
  var isExistComplete = new Completer();
  Directory dir = new Directory(dirStr);
  dir.exists()
      .then((isExist) => isExistComplete.complete(isExist))
      .catchError(() => isExistComplete.complete(false));
  return await isExistComplete.future;
}

Future isGitRepoDir(String dirStr) async {
  return await isExistDir(path.join(dirStr, '.git'));
}