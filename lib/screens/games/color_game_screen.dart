import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/record_service.dart';

class GameObject {
  final String name;
  final IconData icon;
  final Color colorValue;
  final String colorName;

  GameObject({
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.colorName,
  });
}

class ColorGameScreen extends StatefulWidget {
  const ColorGameScreen({super.key});

  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen> {
  final List<GameObject> gameObjects = [
    GameObject(
      name: '별',
      icon: Icons.star,
      colorValue: Colors.yellow.shade600,
      colorName: '노랑',
    ),
    GameObject(
      name: '하트',
      icon: Icons.favorite,
      colorValue: Colors.red.shade600,
      colorName: '빨강',
    ),
    GameObject(
      name: '네잎클로버',
      icon: Icons.grass,
      colorValue: Colors.green.shade600,
      colorName: '초록',
    ),
    GameObject(
      name: '해',
      icon: Icons.wb_sunny,
      colorValue: Colors.yellow.shade600,
      colorName: '노랑',
    ),
    GameObject(
      name: '사과',
      icon: Icons.apple,
      colorValue: Colors.red.shade600,
      colorName: '빨강',
    ),
    GameObject(
      name: '바나나',
      icon: Icons.straighten,
      colorValue: Colors.yellow.shade600,
      colorName: '노랑',
    ),
    GameObject(
      name: '나뭇잎',
      icon: Icons.eco,
      colorValue: Colors.green.shade600,
      colorName: '초록',
    ),
  ];

  late GameObject currentObject;
  String feedbackMessage = '';

  bool _isGameEnded = false;

  // 🔥 [수정] 시작 점수는 10점!
  int _currentScore = 10;
  int _solvedCount = 0;
  final int _targetCount = 10;

  @override
  void initState() {
    super.initState();
    _pickRandomProblem();
  }

  void _pickRandomProblem() {
    setState(() {
      currentObject = gameObjects[Random().nextInt(gameObjects.length)];
    });
  }

  void _handleCorrect() {
    setState(() {
      _solvedCount++;
      feedbackMessage = '정답이에요! 🎉';

      if (_solvedCount < _targetCount) {
        _pickRandomProblem();
      } else {
        if (_isGameEnded) return;
        _isGameEnded = true;

        RecordService().saveRecord(
          gameTitle: '색깔 / 모양 분류',
          score: _currentScore,
          result: '성공',
        );

        feedbackMessage =
            '와! $_targetCount문제를 모두 풀었어요!\n최종 점수: $_currentScore점';
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isGameEnded) {
        setState(() {
          feedbackMessage = '';
        });
      }
    });
  }

  // 🔥 [수정] 틀렸을 때 1점 감점
  void _handleWrong() {
    setState(() {
      if (_currentScore > 0) {
        _currentScore--; // 1점 빼기
      }
      feedbackMessage = '틀렸어요 😭 1점이 깎였어요.';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isGameEnded) {
        setState(() {
          feedbackMessage = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('색깔 / 모양 분류', selectionColor: Colors.white),
        backgroundColor: const Color(0xFF5A67D8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // 점수판
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '남은 문제: ${_targetCount - _solvedCount}개',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    // 점수 표시
                    Text(
                      '점수: $_currentScore점',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  feedbackMessage.isNotEmpty
                      ? feedbackMessage
                      : '같은 색깔 상자에 넣어주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: feedbackMessage.contains('틀렸어요')
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ],
            ),

            _isGameEnded
                ? ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('게임 종료 (나가기)'),
                  )
                : Center(
                    child: Draggable<String>(
                      data: currentObject.colorName,
                      feedback: _buildDraggableChild(
                        currentObject,
                        isFeedback: true,
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildDraggableChild(currentObject),
                      ),
                      child: _buildDraggableChild(currentObject),
                    ),
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorTargetBox('빨강', Colors.red.shade400),
                _buildColorTargetBox('노랑', Colors.yellow.shade400),
                _buildColorTargetBox('초록', Colors.green.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableChild(GameObject obj, {bool isFeedback = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isFeedback ? Colors.grey.withOpacity(0.5) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(obj.icon, color: obj.colorValue, size: 150),
      ),
    );
  }

  Widget _buildColorTargetBox(String colorName, Color color) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        if (_isGameEnded) return;

        if (data.data == colorName) {
          _handleCorrect();
        } else {
          _handleWrong(); // 틀리면 감점
        }
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isHovering ? color.withOpacity(0.8) : color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isHovering ? Colors.black : Colors.grey,
              width: isHovering ? 4 : 2,
            ),
          ),
          child: Center(
            child: Text(
              colorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
