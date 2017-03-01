import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/command_runner.dart' show Command;
import 'package:path/path.dart' as path;

import '../config.dart' as config;
import '../utils.dart' show ensuredir, createTemp;
import '../git-url-parse/git-url-parse.dart' show gitUrlParse;


class AddCommand extends Command {
  final name = "add";
  final abbr = 'a';
  final description = "clone repo into local dir.";
  var argv = null;

  AddCommand(__argv) {
    argv = __argv;
  }

  CommitCommand() {
    argParser.addFlag('force', abbr: 'f');
  }

  Future run() async {
    final repository = argv.arguments[1];

    final gitInfo = gitUrlParse(repository);

    final Directory temp = await createTemp(config.TEMP);

    final Process process = await Process.start('git', ['clone', repository], workingDirectory: temp.path);

    process.stdout
      .transform(UTF8.decoder)
      .listen((data) {
      print(data);
    });

    process.stderr
      .transform(UTF8.decoder)
      .listen((data) {
      print(data);
    });

    final num exitCode = await process.exitCode;

    if (exitCode != 0) {
      await temp.delete(recursive: true);
      return throw new StackOverflowError();
    }

    try {
      await ensuredir(
        path.join(
          config.ROOT,
          gitInfo["resource"]
        )
      );
      final Directory ownerdir = await ensuredir(
        path.join(
          config.ROOT,
          gitInfo["resource"], gitInfo["owner"]
        )
      );

      final String targetPath = path.join(ownerdir.path, gitInfo["name"]);

      Directory targetDir = await ensuredir(targetPath);

      await targetDir.delete(recursive: true);

      await new Directory(path.normalize(
        path.join(temp.absolute.path, gitInfo["name"]))
      ).rename(targetPath);
    } catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);
    } finally {
      await temp.delete(recursive: true);
    }

    print('exit code: $exitCode');
  }
}