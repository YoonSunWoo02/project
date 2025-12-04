import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/record_service.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  // --- 게임 상태 변수 ---
  late int _correctAnswer;
  late List<int> _options;
  late String _problemText = '';

  // --- 레벨 시스템 변수 ---
  int _currentLevel = 1;
  int _correctAnswersInLevel = 0;
  final int _problemsPerLevel = 3;

  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;

  final Random _random = Random();
  bool _isGameEnded = false;

  // 🔥 [추가] 단계별 틀린 횟수 저장용 리스트 (인덱스 0: 1단계, 1: 2단계, 2: 3단계)
  List<int> _mistakesByLevel = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _currentLevel = 1;
      _correctAnswersInLevel = 0;
      _isGameEnded = false;
      _mistakesByLevel = [0, 0, 0]; // 🔥 실수 횟수 초기화
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
      if (wrongAnswer != _correctAnswer && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
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
        feedbackMessage = '정답입니다! 딩동댕! 🔔';
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
              feedbackMessage = '레벨 $_currentLevel';
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
      // ❌ [수정] 틀렸을 때 해당 단계의 실수 카운트 증가!
      setState(() {
        _mistakesByLevel[_currentLevel - 1]++; // 현재 레벨의 실수 증가
        feedbackMessage = '틀렸어요. 다시 생각해볼까요? ❌';
        feedbackColor = Colors.red;
      });
    }
  }

  void _showGameClearDialog() {
    if (_isGameEnded) return;

    setState(() {
      _isGameEnded = true;
    });

    // 🔥 [핵심] 저장할 데이터 계산
    // 1. 총 틀린 횟수
    int totalMistakes = _mistakesByLevel.reduce((a, b) => a + b);

    // 2. 상세 결과 문자열 ("1단계 1회, 2단계 0회...")
    String detailResult =
        "1단계 ${_mistakesByLevel[0]}회, 2단계 ${_mistakesByLevel[1]}회, 3단계 ${_mistakesByLevel[2]}회";

    // 저장: score에는 총 횟수, result에는 상세 내용을 넣습니다.
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎉 모든 레벨 클리어!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('수학 천재시네요! 👍', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              // 결과 창에도 틀린 횟수 보여주기
              Text(
                '총 틀린 횟수: $totalMistakes번',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detailResult.replaceAll(', ', '\n'), // 줄바꿈해서 보여주기
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
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
    // 현재 총 실수 횟수 계산 (화면 표시용)
    int currentTotalMistakes = _mistakesByLevel.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text('숫자 퀴즈 - 레벨 $_currentLevel', selectionColor: Colors.white),
        backgroundColor: const Color(0xFF5A67D8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isLevelUpMessage)
                      Text(
                        '문제 $_correctAnswersInLevel / $_problemsPerLevel', // (0부터 시작하므로 그대로 둠 or +1)
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    // 화면 우측 상단에 실수 횟수 표시
                    Text(
                      '실수: $currentTotalMistakes',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  feedbackMessage.isEmpty ? '정답을 맞춰보세요!' : feedbackMessage,
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
