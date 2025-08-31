import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BeforeCameraPage extends StatelessWidget {
  const BeforeCameraPage({super.key});

  static const Color brandYellow = Color(0xFFF7C316);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: brandYellow,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      // ロゴ画像を表示
                      Image.asset(
                        'assets/logo.png', // プロジェクトの assets に配置してください
                        height: 130,
                      ),
                      SizedBox(height: size.height * 0.15),
                      const Text(
                        'solmeへようこそ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'まずはあなたの分身を作成しましょう',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: size.height * 0.3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '撮影する',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D000000),
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        iconSize: 36,
                        onPressed: () => context.push('/camera'),
                        // onPressed: () => context.push('/home'),
                        icon: const Icon(Icons.photo_camera_outlined,
                            color: Colors.amber),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//onPressed: () => context.push('/camera'),
