// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import '../widgets/game_selection_card.dart';
import 'dart:math';
import 'intro_screen.dart'; // ✨ 1. IntroScreen으로 가기 위해 import 추가

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // (기존) BottomNavigationBar 탭 처리 함수
  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0: // Lock
        _showParentalGate(context);
        break;
      case 1: // Home
        break;
      case 2: // Settings
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  // (기존) 부모님 보호 모드 다이얼로그
  void _showParentalGate(BuildContext context) {
    final Random random = Random();
    int num1 = random.nextInt(10) + 5;
    int num2 = random.nextInt(10) + 5;
    int correctAnswer = num1 + num2;

    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🔒 부모님 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('아이가 실수로 접근하는 것을 방지하기 위해, 다음 덧셈 문제를 풀어주세요:\n'),
              Text(
                '$num1 + $num2 = ?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: answerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '정답을 입력하세요'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            ElevatedButton(
              child: const Text('확인'),
              onPressed: () {
                if (answerController.text == correctAnswer.toString()) {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(context, '/lock');
                } else {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('정답이 아닙니다. 다시 시도하세요.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✨ 2. 앱바(AppBar) 추가
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경 투명하게 (깔끔함 유지)
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ), // 뒤로가기 아이콘
          onPressed: () {
            // ✨ 3. IntroScreen으로 이동 (이전 기록 지우기)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const IntroScreen()),
              (route) => false, // 뒤로가기 버튼 눌러도 다시 못 돌아오게 함
            );
          },
        ),
      ),
      // 앱바가 생겼으므로 body가 살짝 내려갑니다.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백만 적용
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 앱바가 있으므로 상단 여백을 조금 줄였습니다 (40 -> 20)
                const SizedBox(height: 20),
                const Text(
                  '무엇을 해볼까요?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 40),

                // (기존 게임 카드들)
                GameSelectionCard(
                  title: '기억력 게임',
                  description: '같은 그림의 카드를 찾아 짝을 맞혀보아요!',
                  icon: Icons.grid_view_rounded,
                  color: Colors.purple.shade300,
                  onTap: () {
                    Navigator.pushNamed(context, '/game-memory');
                  },
                ),
                const SizedBox(height: 20),
                GameSelectionCard(
                  title: '색깔 / 모양 분류',
                  description: '그림의 색깔과 모양을 구분하여 맞춰보아요!',
                  icon: Icons.category,
                  color: Colors.red.shade300,
                  onTap: () {
                    Navigator.pushNamed(context, '/game-color');
                  },
                ),
                const SizedBox(height: 20),
                GameSelectionCard(
                  title: '숫자 연산',
                  description: '숫자를 이용하여 간단한 연산을 해보아요!',
                  icon: Icons.calculate,
                  color: Colors.orange.shade300,
                  onTap: () {
                    Navigator.pushNamed(context, '/game-math');
                  },
                ),
                const SizedBox(height: 40), // 하단 여백 추가
              ],
            ),
          ),
        ),
      ),
    );
  }
}
