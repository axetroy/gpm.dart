library config;

import 'dart:io' show Platform;

import 'package:path/path.dart' as path;

String getHomeDir() {
  String os = Platform.operatingSystem;
  String home = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (Platform.isLinux) {
    home = envVars['HOME'];
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'];
  }
  return home;
}

final String NAME = 'gpmx';
final String HOME = getHomeDir();
final String ROOT = path.join(HOME, '$NAME');
final String CONFIG = path.join(ROOT, '$NAME.config.json');
final String TEMP = path.join(ROOT, 'temp');
final String LOCK = path.join(ROOT, '$NAME.lock.json');

final config = {
  "name": NAME,
  "paths": {
    "home": HOME,
    "root": ROOT,
    "config": CONFIG,
    "temp": TEMP,
    "lock": LOCK
  }
};