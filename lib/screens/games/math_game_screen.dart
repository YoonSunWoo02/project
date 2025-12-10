import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/record_service.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  // ... (기존 상태 변수들 유지) ...
  late int _correctAnswer;
  late List<int> _options;
  late String _problemText = '';
  int _currentLevel = 1;
  int _correctAnswersInLevel = 0;
  final int _problemsPerLevel = 3;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  final Random _random = Random();
  bool _isGameEnded = false;
  List<int> _mistakesByLevel = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  // ... (기존 로직 함수들: _startNewGame, _generateNewProblem, _checkAnswer 그대로 유지) ...
  void _startNewGame() {
    setState(() {
      _currentLevel = 1;
      _correctAnswersInLevel = 0;
      _isGameEnded = false;
      _mistakesByLevel = [0, 0, 0];
      _generateNewProblem();
    });
  }

  void _generateNewProblem() {
    int num1, num2;
    String operator;
    if (_currentLevel == 1) {
      num1 = _random.nextInt(9) + 1;
      num2 = _random.nextInt(9) + 1;
      _correctAnswer = num1 + num2;
      operator = '+';
    } else if (_currentLevel == 2) {
      num1 = _random.nextInt(11) + 10;
      num2 = _random.nextInt(num1 + 1);
      _correctAnswer = num1 - num2;
      operator = '-';
    } else {
      num1 = _random.nextInt(8) + 2;
      num2 = _random.nextInt(8) + 2;
      _correctAnswer = num1 * num2;
      operator = 'x';
    }
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
      if (wrongAnswer != _correctAnswer && !_options.contains(wrongAnswer))
        _options.add(wrongAnswer);
    }
    _options.shuffle();
    setState(() {
      _problemText = '$num1 $operator $num2 = ?';
      feedbackMessage = '';
      feedbackColor = Colors.transparent;
    });
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _correctAnswer) {
      setState(() {
        feedbackMessage = '정답입니다! 딩동댕! 🎉';
        feedbackColor = Colors.green;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        _correctAnswersInLevel++;
        if (_correctAnswersInLevel >= _problemsPerLevel) {
          if (_currentLevel < 3) {
            setState(() {
              _currentLevel++;
              _correctAnswersInLevel = 0;
              feedbackMessage = '레벨 $_currentLevel 시작!';
              feedbackColor = Colors.blue;
            });
            Future.delayed(const Duration(seconds: 1), _generateNewProblem);
          } else {
            _showGameClearDialog();
          }
        } else {
          _generateNewProblem();
        }
      });
    } else {
      setState(() {
        _mistakesByLevel[_currentLevel - 1]++;
        feedbackMessage = '틀렸어요. 다시 해볼까요? 🤔';
        feedbackColor = Colors.redAccent;
      });
    }
  }

  void _showGameClearDialog() {
    if (_isGameEnded) return;
    setState(() {
      _isGameEnded = true;
    });

    int totalMistakes = _mistakesByLevel.reduce((a, b) => a + b);
    String detailResult =
        "1단계 ${_mistakesByLevel[0]}회, 2단계 ${_mistakesByLevel[1]}회, 3단계 ${_mistakesByLevel[2]}회";

    RecordService().saveRecord(
      gameTitle: '숫자 퀴즈',
      score: totalMistakes,
      result: detailResult,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // 🔥 [디자인] 다이얼로그 둥글게
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Icon(Icons.emoji_events_rounded, size: 60, color: Colors.amber),
              SizedBox(height: 10),
              Text(
                '🎉 모든 레벨 클리어!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('정말 대단해요! 수학 천재!', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '총 틀린 횟수: $totalMistakes번',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      detailResult.replaceAll(', ', '\n'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
                },
                child: const Text('다시 하기 (레벨 1)'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  '홈으로 돌아가기',
                  style: TextStyle(color: Colors.grey),
                ),
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
    int currentTotalMistakes = _mistakesByLevel.reduce((a, b) => a + b);

    return Scaffold(
      // 앱바 디자인은 main.dart 테마를 따름
      appBar: AppBar(title: Text('숫자 퀴즈 - 레벨 $_currentLevel')),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // 여백 넓게
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 정보 및 피드백 영역
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isLevelUpMessage)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '문제 $_correctAnswersInLevel / $_problemsPerLevel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '실수: $currentTotalMistakes',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  feedbackMessage.isEmpty
                      ? '주어진 연산의 결과를 고르세요!'
                      : feedbackMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: feedbackMessage.isEmpty
                        ? Colors.black87
                        : feedbackColor,
                  ),
                  key: ValueKey(feedbackMessage),
                ),
              ],
            ),

            // 🔥 [디자인] 문제 표시 영역: 아주 둥글고 흰색 배경
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A67D8).withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _problemText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5A67D8),
                ),
              ),
            ),

            // 정답 버튼 영역
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

  Widget _buildAnswerButton(int answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // 🔥 [디자인] 정답 버튼: 둥글고 부드러운 스타일
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // 배경 흰색
          foregroundColor: Colors.black87, // 글자 검은색
          shadowColor: const Color(0xFF5A67D8).withOpacity(0.2), // 그림자 색상
          elevation: 4,
          minimumSize: const Size(double.infinity, 70), // 높이 조절
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ), // 둥글게
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          if (feedbackColor == Colors.transparent ||
              feedbackColor == Colors.redAccent) {
            _checkAnswer(answer);
          }
        },
        child: Text(
          '$answer',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
