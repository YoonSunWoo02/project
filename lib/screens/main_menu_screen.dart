import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 [추가] 앱바 생성 (main.dart의 테마 설정을 자동으로 따라가서 둥글고 파랗게 나옴)
      appBar: AppBar(
        title: const Text('GrowUp'), // 앱 이름 표시
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded), // 둥근 뒤로가기 아이콘
          onPressed: () {
            // 🔥 IntroScreen('/')으로 이동하고 이전 기록 지우기
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 캐릭터 및 인사말 영역
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.face_retouching_natural_rounded,
                    size: 80,
                    color: Color(0xFF5A67D8),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "만나서 반가워요!\n무엇을 해볼까요?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildGameCard(
                    context,
                    title: '숫자 연산',
                    description: '숫자를 이용하여\n간단한 연산을 해보아요!',
                    icon: Icons.calculate_rounded,
                    color: Colors.orangeAccent,
                    route: '/game/math',
                  ),
                  const SizedBox(height: 20),
                  _buildGameCard(
                    context,
                    title: '색깔 / 모양 분류',
                    description: '그림의 색깔과 모양을 구분하여\n맞춰보아요!',
                    icon: Icons.palette_rounded,
                    color: Colors.pinkAccent,
                    route: '/game/color',
                  ),
                  const SizedBox(height: 20),
                  _buildGameCard(
                    context,
                    title: '기억력 게임 (직소 퍼즐)',
                    description: '카드의 위치를 기억해서\n짝을 맞춰보세요!',
                    icon: Icons.extension_rounded,
                    color: Colors.lightBlueAccent,
                    route: '/game/memory',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
