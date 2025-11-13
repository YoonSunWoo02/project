// lib/screens/color_game_screen.dart
import 'package:flutter/material.dart';

// 1. 게임 객체를 위한 간단한 데이터 모델
class GameObject {
  final String name;
  final IconData icon;
  final Color colorValue;
  final String colorName; // '빨강', '노랑', '초록' (DragTarget과 매칭)

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
  // 2. 게임 문제 목록 (FR-CS1: 다양한 색깔과 모양의 물체)
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
  ];

  int currentObjectIndex = 0; // 현재 문제 인덱스
  String feedbackMessage = ''; // 피드백 메시지

  // 3. 다음 문제로 넘어가는 함수
  void _nextProblem() {
    setState(() {
      feedbackMessage = '정답이에요! 🎉'; // FR3: 정답 피드백

      // 다음 문제가 있으면 인덱스 증가, 없으면 처음으로
      if (currentObjectIndex < gameObjects.length - 1) {
        currentObjectIndex++;
      } else {
        currentObjectIndex = 0; // (임시) 모든 문제를 풀면 처음으로
      }
    });

    // 1초 후에 피드백 메시지 숨기기
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // 위젯이 아직 화면에 있는지 확인
        setState(() {
          feedbackMessage = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 현재 화면에 표시할 게임 객체
    final GameObject currentObject = gameObjects[currentObjectIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('색깔 / 모양 분류'),
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
          children: [
            // 1. 지시문
            Text(
              feedbackMessage.isNotEmpty
                  ? feedbackMessage
                  : '색깔 또는 모양이 같은 것을 찾아\n아래 상자로 옮겨 보아요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: feedbackMessage.isNotEmpty ? Colors.blue : Colors.black,
              ),
            ),

            // 2. 드래그할 객체 (Draggable)
            Center(
              // 💡 Draggable<String>: 'String' 타입의 데이터를 전달
              child: Draggable<String>(
                // 💡 data: '노랑', '빨강' 등 현재 객체의 'colorName' (String)을 전달
                data: currentObject.colorName,

                feedback: _buildDraggableChild(currentObject, isFeedback: true),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildDraggableChild(currentObject),
                ),
                child: _buildDraggableChild(currentObject),
              ),
            ),

            // 3. 분류 상자 (DragTarget)
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

  // 드래그할 객체 UI
  Widget _buildDraggableChild(GameObject obj, {bool isFeedback = false}) {
    // 💡 'feedback' 위젯은 Material 위젯으로 감싸야 화면에 제대로 표시됩니다.
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

  // 색깔 분류 상자 (DragTarget) 위젯
  Widget _buildColorTargetBox(String colorName, Color color) {
    // 💡 DragTarget<String>: 'String' 타입의 데이터만 받음
    return DragTarget<String>(
      // 1. onWillAccept: 드롭을 허용할지 결정
      onWillAcceptWithDetails: (data) {
        // 💡 data에서 .data를 뽑아내서 비교
        print('onWillAccept: (data = ${data.data}), (target = $colorName)');
        return data.data == colorName;
      },

      // 2. onAccept: onWillAccept가 true일 때만 실행됨 (드롭 성공)
      onAcceptWithDetails: (data) {
        // 💡 (디버깅) 드롭 성공 시 콘솔에 출력합니다.
        print('onAccept: SUCCESS! Dropped $data onto $colorName');

        _nextProblem(); // 정답 처리 및 다음 문제 호출
      },

      // 3. builder: 상자의 UI
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty; // 드래그 중인 아이템이 위에 있음

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
