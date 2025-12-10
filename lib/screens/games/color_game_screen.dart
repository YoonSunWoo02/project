import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/record_service.dart';

// ... (GameObject 클래스 유지) ...
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
  // ... (기존 상태 변수 및 로직 함수들 유지) ...
  final List<GameObject> gameObjects = [
    GameObject(
      name: '별',
      icon: Icons.star_rounded,
      colorValue: const Color(0xFFFFE082),
      colorName: '노랑',
    ), // 색상 부드럽게 변경
    GameObject(
      name: '하트',
      icon: Icons.favorite_rounded,
      colorValue: const Color(0xFFFF8A80),
      colorName: '빨강',
    ),
    GameObject(
      name: '네잎클로버',
      icon: Icons.spa_rounded,
      colorValue: const Color(0xFFA5D6A7),
      colorName: '초록',
    ),
    GameObject(
      name: '해',
      icon: Icons.wb_sunny_rounded,
      colorValue: const Color(0xFFFFE082),
      colorName: '노랑',
    ),
    GameObject(
      name: '사과',
      icon: Icons.apple_rounded,
      colorValue: const Color(0xFFFF8A80),
      colorName: '빨강',
    ),
    GameObject(
      name: '바나나',
      icon: Icons.straighten_rounded,
      colorValue: const Color(0xFFFFE082),
      colorName: '노랑',
    ),
    GameObject(
      name: '나뭇잎',
      icon: Icons.eco_rounded,
      colorValue: const Color(0xFFA5D6A7),
      colorName: '초록',
    ),
  ];
  late GameObject currentObject;
  String feedbackMessage = '';
  bool _isGameEnded = false;
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
      if (mounted && !_isGameEnded)
        setState(() {
          feedbackMessage = '';
        });
    });
  }

  void _handleWrong() {
    setState(() {
      if (_currentScore > 0) _currentScore--;
      feedbackMessage = '틀렸어요 😭 1점이 깎였어요.';
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isGameEnded)
        setState(() {
          feedbackMessage = '';
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('색깔 / 모양 분류')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // 점수판 디자인 개선
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '남은 문제: ${_targetCount - _solvedCount}개',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '점수: $_currentScore점',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A67D8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  feedbackMessage.isNotEmpty
                      ? feedbackMessage
                      : '색깔이 같은 상자로 옮겨보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: feedbackMessage.contains('틀렸어요')
                        ? Colors.redAccent
                        : Colors.black87,
                  ),
                ),
              ],
            ),

            _isGameEnded
                ? ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('게임 종료 (나가기)'),
                  )
                : Center(
                    // 🔥 [디자인] 드래그 아이템을 흰색 둥근 배경 안에 넣음
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: currentObject.colorValue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
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
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorTargetBox('빨강', const Color(0xFFFF8A80)), // 부드러운 빨강
                _buildColorTargetBox('노랑', const Color(0xFFFFE082)), // 부드러운 노랑
                _buildColorTargetBox('초록', const Color(0xFFA5D6A7)), // 부드러운 초록
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableChild(GameObject obj, {bool isFeedback = false}) {
    // 피드백일 때는 아이콘만 보여줌 (배경 없이)
    if (isFeedback) {
      return Icon(obj.icon, color: obj.colorValue, size: 100);
    }
    return Icon(obj.icon, color: obj.colorValue, size: 100);
  }

  Widget _buildColorTargetBox(String colorName, Color color) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        if (_isGameEnded) return;
        if (data.data == colorName)
          _handleCorrect();
        else
          _handleWrong();
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          height: 90,
          // 🔥 [디자인] 타겟 박스: 둥근 사각형, 부드러운 색상
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isHovering ? 0.6 : 0.3),
                blurRadius: isHovering ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isHovering
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              colorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
