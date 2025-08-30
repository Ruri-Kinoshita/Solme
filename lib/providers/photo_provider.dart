import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

// 撮った写真（XFile）を保持する。なければ null。
final capturedPhotoProvider = StateProvider<XFile?>((ref) => null);
