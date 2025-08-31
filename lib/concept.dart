import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConceptPage extends StatelessWidget {
  const ConceptPage({super.key});

  static const Color brandYellow = Color(0xFFF7C316);
  static const Color brandOrange = Color(0xFFE9A800); // ボタン文字色

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: brandYellow,
      body: SafeArea(
        child: Stack(
          children: [
            // 上部ロゴ＋本文
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
                      // ロゴ
                      Image.asset(
                        'assets/logo.png',
                        height: 130,
                      ),
                      SizedBox(height: size.height * 0.10),
                      // 1段目テキスト
                      const Text(
                        'あなたが日光に当たることで\n分身の健康を保つことができます',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // 2段目テキスト
                      const Text(
                        '毎日外に出て、あなたも分身も\n健康な生活をしましょう！',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: size.height * 0.20),
                    ],
                  ),
                ),
              ),
            ),

            // 画面下の白いピル形ボタン
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  // オレンジ系の柔らかい影を落とす
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66E2A100), // 影（オレンジ系）
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(36),
                      onTap: () => context.push('/bunsin'), // 遷移先は用途に合わせて
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        child: Text(
                          '分身の誕生を待つ',
                          style: TextStyle(
                            color: brandOrange,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
