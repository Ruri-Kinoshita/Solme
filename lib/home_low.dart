import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:solme/constant/app_color.dart';

class HomePage_Low extends StatelessWidget {
  const HomePage_Low({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // ステータスバーの色をAppBarと同じにする
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.brand.secondary, // ステータスバーの背景色
      statusBarIconBrightness: Brightness.light, // ステータスバーのアイコン（時間や電池残量など）の色を白に
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      // appBarを追加してステータスバーを含めて同じ色にする
      appBar: AppBar(
        backgroundColor: Color(0xFFFFC916),
        elevation: 0,
        title: Image.asset(
          'assets/solme_white.png',
          width: 165.6,
          height: 60,
        ),
        centerTitle: true,
        toolbarHeight: 100, // ヘッダーの高さ調整
        actions: [
          IconButton(
              onPressed: () => context.push('/home_high'),
              // onPressed: () => context.push('/home_high'),
              icon: const Icon(Icons.remove)),
          IconButton(
              onPressed: () => context.push('/home'),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: 340,
            color: const Color(0xFFFFDD6D).withOpacity(0.2),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 30,
                  ),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // コメントとアバター横並び
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 185,
                            height: 194,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFDD6D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                "...",
                                style: TextStyle(
                                    color: Color(0xFF000000), fontSize: 15),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 76),
                              Image.asset(
                                'assets/img0_s.png',
                                width: 190.35,
                                height: 270,
                              ),
                            ],
                          )
                        ],
                      ),

                      // 今週の記録見出し

                      const SizedBox(height: 70),
                      // ダミーの棒グラフ
                      Image.asset(
                        'assets/graph_2.png',
                        width: 429,
                        height: 263.9,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Align(
            alignment: const Alignment(0.55, -0.8),
            child: Container(
              width: 92,
              height: 26,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFFFC916),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "継続0日目",
                  style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
          ),

          Positioned(
            top: 340,
            left: 264,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/sunrise.png',
                      width: 45,
                      height: 34,
                    ),
                    const Text(
                      "05:02",
                      style: TextStyle(color: Color(0xFF935B3E), fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Row(
                  children: [
                    Image.asset(
                      'assets/sunset.png',
                      width: 44,
                      height: 33,
                    ),
                    const Text(
                      "18:13",
                      style: TextStyle(color: Color(0xFF935B3E), fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 日光時間 (ダミー)
          Align(
            alignment: const Alignment(-0.8, -0.2),
            child: Image.asset(
              'assets/timer_0.png', //TODO: 画像を変数化
              width: 240,
              height: 240,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: size.width,
              height: 70,
              decoration: BoxDecoration(
                color: Color(0xFFFFC916),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
