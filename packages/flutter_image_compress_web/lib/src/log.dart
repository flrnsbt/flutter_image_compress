@JS('console')
library log;

import 'dart:js_interop';

import 'package:web/web.dart';

bool showLog = false;

void jsLog(dynamic tag, dynamic msg) {
  if (showLog) {
    console.log('[$tag] $msg'.toJS);
  }
}

void dartLog(Object? msg) {
  if (showLog) {
    // ignore: avoid_print
    print(msg.toString());
  }
}
