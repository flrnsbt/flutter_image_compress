import 'main/main_base.dart'
    if (dart.library.io) 'main/main_io.dart'
    if (dart.library.js_interop) 'main/main_web.dart';

Future<void> main() async {
  await runMain();
}
