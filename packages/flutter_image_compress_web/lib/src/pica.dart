@JS()
library pica;

import 'dart:convert';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart';
import 'dart:typed_data';

import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'dart:js_interop';

import 'window.dart';
import 'log.dart' as logger;

@JS('pica.resize')
external JSPromise resize(ImageBitmap imageBitmap, HTMLCanvasElement canvas);

@JS('pica')
@staticInterop
class Pica {}

extension PicaExt on Pica {
  external JSPromise resize(ImageBitmap imageBitmap, HTMLCanvasElement canvas);

  external JSAny? init();
}


const String _kPicaCDN =
    'https://cdn.jsdelivr.net/npm/pica@9.0.1/dist/pica.min.js';

Future<Pica> _lazyLoadPica() async {

  // check if context contains pica
  final hasPica = globalContext.has('pica');
  if (!hasPica) {
    final script = HTMLScriptElement()
      ..src = _kPicaCDN
      ..type = 'text/javascript';
    document.head!.append(script);
    await script.onLoad.first;
  }
  return jsWindow.pica.callAsConstructor<Pica>();
}

Future<Uint8List> resizeWithList({
  required Uint8List buffer,
  required int minWidth,
  required int minHeight,
  CompressFormat format = CompressFormat.jpeg,
  int quality = 88,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final pica = await _lazyLoadPica();

  logger.jsLog('The pica instance', pica);
  logger.jsLog('src image buffer', buffer);
  logger.dartLog('src image buffer length: ${buffer.length}');
  final bitmap = await convertUint8ListToBitmap(buffer);

  final srcWidth = bitmap.width;
  final srcHeight = bitmap.height;

  final ratio = srcWidth / srcHeight;

  final width = srcWidth > minWidth ? minWidth : srcWidth;
  final height = width ~/ ratio;

  logger.jsLog('target size', '$width x $height');

  final canvas = HTMLCanvasElement()
    ..width = width
    ..height = height;
  await pica.resize(bitmap, canvas).toDart;
  final blob = canvas.toDataUrl(format.type, quality / 100);
  final str = blob.split(',')[1];

  bitmap.close();
  final result = base64Decode(str);
  logger.jsLog('compressed image buffer', result);
  logger.dartLog('compressed image buffer length: ${result.length}');
  logger.dartLog('compressed took ${stopwatch.elapsedMilliseconds}ms');

  return result;
}

extension CompressExt on CompressFormat {
  String get type {
    switch (this) {
      case CompressFormat.jpeg:
        return 'image/jpeg';
      case CompressFormat.png:
        return 'image/png';
      case CompressFormat.webp:
        return 'image/webp';
      case CompressFormat.heic:
        throw UnimplementedError('heic is not support web');
      default:
        return 'image/jpeg';
    }
  }
}
