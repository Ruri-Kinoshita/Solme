import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BunsinPage extends StatelessWidget {
  const BunsinPage({super.key});

  static const Color brandYellow = Color(0xFFF7C316);
  static const Color textBrown = Color(0xFF5C3A2E);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 190),
              Center(
                child: const Text(
                  'あなたの分身が誕生しました！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // 黄色の円＋アセット画像
              Container(
                width: size.width * 0.55,
                height: size.width * 0.55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: brandYellow,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/img3.png', // ← assets に配置した画像
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 72),
                  ),
                ),
              ),
              const Spacer(),
              // ピル型ボタン
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: brandYellow, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () => context.goNamed('home'), // 遷移先に合わせる
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    child: Text(
                      'solmeを始める',
                      style: TextStyle(
                        color: brandYellow,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 44),
            ],
          ),
        ),
      ),
    );
  }
}
