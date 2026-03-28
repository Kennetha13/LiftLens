import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'platform_file_reader_stub.dart'
    if (dart.library.io) 'platform_file_reader_io.dart' as impl;

Future<Uint8List?> loadPlatformFileBytes(PlatformFile f) =>
    impl.loadPlatformFileBytes(f);
