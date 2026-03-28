import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<Uint8List?> loadPlatformFileBytes(PlatformFile f) async {
  if (f.bytes != null) return Uint8List.fromList(f.bytes!);
  return null;
}
