import 'dart:js_interop';

import 'package:apps/apps.dart' as apps;

void main(List<String> arguments) {
  print('Connected...');
  // The following lines were redundant or incorrect and have been removed.
  // print.call('Connected...'); is the same as print('Connected...');
  // print.jsify(); causes a compilation error.
}
