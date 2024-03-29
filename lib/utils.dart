import 'dart:io';

import 'package:path/path.dart';

bool partialPathExistence(String path) => Directory(normalize(path)).existsSync()
    ? true
    : Directory(normalize(path)).parent.path != normalize(path) &&
        partialPathExistence(Directory(normalize(path)).parent.path);
