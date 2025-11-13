// lib/screens/math_game_screen.dart
import 'dart:math'; // min 함수와 Random을 위해 import
import 'package:flutter/material.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  // --- 게임 상태 변수 ---
  late int _correctAnswer;
  late List<int> _options;
  late String _problemText = ''; // 빈 문자열로 초기화

  // --- 레벨 시스템 변수 ---
  int _currentLevel = 1;
  int _correctAnswersInLevel = 0;
  final int _problemsPerLevel = 3; // 레벨당 문제 수

  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _currentLevel = 1;
      _correctAnswersInLevel = 0;
      _generateNewProblem();
    });
  }

  void _generateNewProblem() {
    int num1, num2;
    String operator;

    if (_currentLevel == 1) {
      // 레벨 1: 덧셈
      num1 = _random.nextInt(9) + 1;
      num2 = _random.nextInt(9) + 1;
      _correctAnswer = num1 + num2;
      operator = '+';
    } else if (_currentLevel == 2) {
      // 레벨 2: 뺄셈
      num1 = _random.nextInt(11) + 10;
      num2 = _random.nextInt(num1 + 1);
      _correctAnswer = num1 - num2;
      operator = '-';
    } else {
      // 레벨 3: 곱셈
      num1 = _random.nextInt(8) + 2;
      num2 = _random.nextInt(8) + 2;
      _correctAnswer = num1 * num2;
      operator = 'x';
    }

    // 보기 생성
    _options = [_correctAnswer];
    while (_options.length < 3) {
      int wrongAnswerRange;
      if (_currentLevel == 1)
        wrongAnswerRange = 18;
      else if (_currentLevel == 2)
        wrongAnswerRange = 20;
      else
        wrongAnswerRange = 81;

      int wrongAnswer = _random.nextInt(wrongAnswerRange) + 1;

      if (wrongAnswer != _correctAnswer && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();

    setState(() {
      _problemText = '$num1 $operator $num2 = ?';
      feedbackMessage = '';
      // 💡 (수정) 버튼이 다시 눌릴 수 있도록 피드백 색상도 초기화합니다.
      feedbackColor = Colors.transparent;
    });
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _correctAnswer) {
      // --- 정답일 경우 ---
      setState(() {
        feedbackMessage = '정답입니다! 딩동댕! 🔔';
        feedbackColor = Colors.green;
      });

      // 1초 대기 후 다음 동작
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;

        _correctAnswersInLevel++; // 새 문제 로드 직전에 증가

        if (_correctAnswersInLevel >= _problemsPerLevel) {
          // --- 레벨 통과 ---
          if (_currentLevel < 3) {
            // 다음 레벨로
            setState(() {
              _currentLevel++;
              _correctAnswersInLevel = 0;
              feedbackMessage = '레벨 $_currentLevel';
              feedbackColor = Colors.blue;
            });
            Future.delayed(const Duration(seconds: 1), _generateNewProblem);
          } else {
            // --- 3레벨 모두 클리어 ---
            _showGameClearDialog();
          }
        } else {
          // --- 현재 레벨의 다음 문제 ---
          _generateNewProblem();
        }
      });
    } else {
      // --- 오답일 경우 ---
      setState(() {
        feedbackMessage = '틀렸어요. 다시 생각해볼까요? ❌';
        feedbackColor = Colors.red;
      });
    }
  }

  // 3레벨 모두 클리어 시 다이얼로그
  void _showGameClearDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎉 모든 레벨 클리어!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A67D8),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '다시 하기 (레벨 1)',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('홈으로 돌아가기'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLevelUpMessage = feedbackColor == Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text('숫자 퀴즈 - 레벨 $_currentLevel'),
        backgroundColor: const Color(0xFF5A67D8),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Lock'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 지시문 및 피드백
            Column(
              children: [
                const SizedBox(height: 10),
                // (추가) 레벨 진행도 표시
                if (!isLevelUpMessage)
                  Builder(
                    builder: (context) {
                      final int displayProblemNum = min(
                        _correctAnswersInLevel + 1,
                        _problemsPerLevel,
                      );

                      return Text(
                        '문제 $displayProblemNum / $_problemsPerLevel',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 10),
                // 피드백 메시지 표시 영역
                Text(
                  feedbackMessage.isEmpty
                      ? '주어진 연산의 결과를 고르세요!'
                      : feedbackMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: feedbackMessage.isEmpty
                        ? Colors.black
                        : feedbackColor,
                  ),
                  key: ValueKey(feedbackMessage),
                ),
              ],
            ),

            // 2. 문제 표시 영역
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                _problemText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),

            // 3. 선택 버튼 영역
            Column(
              children: _options.map((option) {
                return _buildAnswerButton(option);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 답변 버튼 위젯 (변경 없음)
  Widget _buildAnswerButton(int answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF0F4FF),
          foregroundColor: Colors.black87,
          minimumSize: const Size(double.infinity, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        onPressed: () {
          // (수정) 버튼 클릭 방지 로직
          if (feedbackColor == Colors.transparent ||
              feedbackColor == Colors.red) {
            _checkAnswer(answer);
          }
        },
        child: Text(
          '$answer',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
