// lib/screens/get_started_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // ◀◀◀ 1. 부모님 보호 모드를 위해 Random import

// (수정) StatelessWidget -> StatefulWidget
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  // ◀◀◀ 2. 'main_menu_screen.dart'에서 복사해온 함수들

  // BottomNavigationBar의 탭 이벤트를 처리할 함수
  void _onBottomNavTapped(int index) {
    // 현재 화면(GetStartedScreen)에서는 Home(1) 탭에 있습니다.
    switch (index) {
      case 0: // Lock
        _showParentalGate(context);
        break;
      case 1: // Home
        // 이미 홈(시작) 화면이므로, 메뉴로 이동시킵니다.
        Navigator.pushReplacementNamed(context, '/menu');
        break;
      case 2: // Settings
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  // 부모님 보호 모드 다이얼로그
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
                Navigator.pop(dialogContext);
              },
            ),
            ElevatedButton(
              child: Text('확인'),
              onPressed: () {
                if (answerController.text == correctAnswer.toString()) {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(context, '/lock'); // 부모님 설정 화면으로
                } else {
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

  // ◀◀◀ 3. 기존 build 메서드는 이 안에 있습니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. GrowUp 로고
              const Text(
                'GrowUp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A8A),
                ),
              ),

              // 2. 중앙 일러스트 및 텍스트
              Column(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 150,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '여러 가지 놀이를 해보며\n기초 지식을 쌓아볼까요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

              // 3. 시작하기 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A67D8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/menu');
                },
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ◀◀◀ 4. BottomNavigationBar 수정
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 'Home'이 선택된 상태
        onTap: _onBottomNavTapped, // ◀◀◀ 5. onTap 이벤트 연결
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Lock'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
