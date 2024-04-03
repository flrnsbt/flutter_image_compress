@JS()
library window;

import 'package:web/web.dart';
import 'dart:typed_data';

import 'dart:js_interop';

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  external JSFunction get createImageBitmap;
  external JSFunction get pica;
}

Future<ImageBitmap> convertUint8ListToBitmap(Uint8List buffer) async {
  final jsBuffer = buffer.toJS;
  final blobParts = [jsBuffer].toJS;
  final blob = Blob(blobParts);
  final JSPromise result = jsWindow.createImageBitmap
      .callAsFunction(null, blob.jsify()) as JSPromise;
  final imageBitmap = await result.toDart;

  return imageBitmap as ImageBitmap;
}

JSWindow get jsWindow => window as JSWindow;
