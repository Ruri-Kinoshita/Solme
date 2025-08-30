import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solme/providers/photo_provider.dart';

class PhotoPage extends ConsumerStatefulWidget {
  const PhotoPage({super.key});

  @override
  ConsumerState<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends ConsumerState<PhotoPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (!mounted) return;

      if (_cameras != null && _cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (!mounted) return;

        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('カメラの初期化に失敗しました: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 撮影して Riverpod に保持し、次画面へ遷移
  Future<void> _takePicture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    try {
      final image = await ctrl.takePicture();
      debugPrint('保存先: ${image.path}');

      // 撮った写真を Riverpod に保持
      ref.read(capturedPhotoProvider.notifier).state = image;

      if (!mounted) return;
      context.push('/concept'); // 遷移先はルート定義に合わせて
    } catch (e) {
      debugPrint('撮影失敗: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('撮影に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00000000),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            Stack(
              children: [
                Align(
                  alignment: const Alignment(0, -0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 350,
                      height: 467,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                const Positioned(
                  top: 100,
                  left: 20,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "アイコンを生成するため写真を撮ります",
                        style: TextStyle(
                          color: Color(0x00000000),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "丸枠に顔を収めてください",
                        style: TextStyle(
                          color: Color(0x00000000),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.3),
                  child: Container(
                    width: 180,
                    height: 234,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 6),
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(200, 300),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 55,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
