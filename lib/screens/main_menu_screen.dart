// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import '../widgets/game_selection_card.dart'; // GameSelectionCard import
import 'dart:math'; // (추가) 부모님 보호 모드를 위해 Random import

// (수정) StatelessWidget -> StatefulWidget
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // (추가) BottomNavigationBar의 탭 이벤트를 처리할 함수
  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0: // Lock
        // (추가) 부모님 보호 모드 실행
        _showParentalGate(context);
        break;
      case 1: // Home
        // 이미 홈 화면이므로 아무것도 하지 않음
        break;
      case 2: // Settings
        // (추가) 설정 화면으로 이동
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  // (추가) 부모님 보호 모드 다이얼로그
  void _showParentalGate(BuildContext context) {
    final Random random = Random();
    int num1 = random.nextInt(10) + 5; // 5~14
    int num2 = random.nextInt(10) + 5; // 5~14
    int correctAnswer = num1 + num2;

    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('🔒 부모님 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('아이가 실수로 접근하는 것을 방지하기 위해, 다음 덧셈 문제를 풀어주세요:\n'),
              Text(
                '$num1 + $num2 = ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: answerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: '정답을 입력하세요'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(dialogContext); // 다이얼로그 닫기
              },
            ),
            ElevatedButton(
              child: Text('확인'),
              onPressed: () {
                if (answerController.text == correctAnswer.toString()) {
                  // 정답!
                  Navigator.pop(dialogContext); // 다이얼로그 닫기
                  Navigator.pushNamed(context, '/lock'); // 부모님 설정 화면으로 이동
                } else {
                  // 오답
                  // (간단한 알림. SnackBar 등으로 개선 가능)
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 현재 'Home' 탭이 선택되었음을 의미
        onTap: _onBottomNavTapped, // (수정) 탭 이벤트 연결
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Lock'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  '무엇을 해볼까요?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 40),

                // (기존 게임 카드들 - 변경 없음)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
