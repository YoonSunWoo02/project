// lib/screens/memory_game_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// 1. 카드 아이템의 상태를 관리할 모델
class CardItem {
  final IconData icon; // 카드 앞면 아이콘
  bool isFlipped; // 뒤집혔는지 여부
  bool isMatched; // 짝을 맞췄는지 여부

  CardItem({
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<CardItem> cards; // 게임 카드 리스트
  int? firstFlippedIndex; // 첫 번째로 뒤집은 카드의 인덱스
  int? secondFlippedIndex; // 두 번째로 뒤집은 카드의 인덱스
  bool isChecking = false; // 현재 짝이 맞는지 확인 중(클릭 방지)

  // (추가) 게임에 사용할 아이콘 목록 (6쌍 = 12개 카드)
  final List<IconData> iconPool = [
    Icons.pets,
    Icons.star,
    Icons.favorite,
    Icons.apple,
    Icons.lightbulb,
    Icons.anchor,
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame(); // 새 게임 시작
  }

  // (수정) 새 게임 시작 함수
  void _startNewGame() {
    setState(() {
      // 아이콘 목록을 두 배로 만들어 짝을 맞춤
      List<IconData> gameIcons = [...iconPool, ...iconPool];
      gameIcons.shuffle(Random()); // 아이콘 섞기

      // 섞인 아이콘으로 카드 리스트 생성
      cards = gameIcons.map((icon) => CardItem(icon: icon)).toList();

      firstFlippedIndex = null;
      secondFlippedIndex = null;
      isChecking = false;
    });
  }

  // (수정) 카드 탭(Tap) 이벤트 처리
  void _onCardTapped(int index) {
    // 이미 짝을 맞췄거나, 2개가 뒤집혀 확인 중이거나, 이미 뒤집힌 카드는 무시
    if (cards[index].isMatched || isChecking || cards[index].isFlipped) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true; // 탭한 카드 뒤집기

      if (firstFlippedIndex == null) {
        // 1. 첫 번째 카드일 경우
        firstFlippedIndex = index;
      } else {
        // 2. 두 번째 카드일 경우
        secondFlippedIndex = index;
        isChecking = true; // 확인 시작 (클릭 방지)

        // 짝이 맞는지 확인
        _checkForMatch();
      }
    });
  }

  // (수정) 짝이 맞는지 확인하는 함수
  void _checkForMatch() {
    final int index1 = firstFlippedIndex!;
    final int index2 = secondFlippedIndex!;

    // 두 카드의 아이콘이 같은지 비교
    if (cards[index1].icon == cards[index2].icon) {
      // 3. 짝이 맞을 경우
      setState(() {
        cards[index1].isMatched = true;
        cards[index2].isMatched = true;
      });
      _resetFlippedCards(); // 인덱스 초기화

      // (추가) 모든 짝을 맞췄는지 확인
      if (cards.every((card) => card.isMatched)) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showSuccessDialog();
        });
      }
    } else {
      // 4. 짝이 틀릴 경우
      // 1초 후에 다시 뒤집음
      Timer(const Duration(seconds: 1), () {
        setState(() {
          cards[index1].isFlipped = false;
          cards[index2].isFlipped = false;
        });
        _resetFlippedCards(); // 인덱스 초기화
      });
    }
  }

  // (추가) 뒤집은 카드 인덱스 초기화
  void _resetFlippedCards() {
    setState(() {
      firstFlippedIndex = null;
      secondFlippedIndex = null;
      isChecking = false; // 클릭 방지 해제
    });
  }

  // 성공 시 다이얼로그
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎉 성공했어요!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A67D8),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '다음 단계로 넘어 가기',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  _startNewGame(); // 새 게임 시작
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('홈으로 돌아가기'),
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 게임 화면 닫고 메뉴로
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('기억력 게임'),
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
          children: [
            // 1. 지시문
            const Text(
              '같은 그림의 카드를 찾아보아요!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 2. 게임 판 (GridView)
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 x 4 그리드
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: cards.length, // 12개 카드
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (수정) 카드 1개를 만드는 위젯
  Widget _buildCard(int index) {
    CardItem card = cards[index];

    // GestureDetector: '탭' 이벤트를 감지
    return GestureDetector(
      onTap: () {
        _onCardTapped(index);
      },
      child: Card(
        elevation: 4,
        color: card.isMatched ? Colors.grey.shade300 : Colors.blue,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(turns: animation, child: child);
          },
          // (수정) 뒤집혔거나 짝이 맞으면 아이콘, 아니면 물음표
          child: (card.isFlipped || card.isMatched)
              ? Center(
                  // 카드 앞면
                  key: ValueKey('front_$index'),
                  child: Icon(
                    card.icon,
                    size: 40,
                    color: card.isMatched
                        ? Colors.black.withOpacity(0.5)
                        : Colors.white,
                  ),
                )
              : Center(
                  // 카드 뒷면
                  key: ValueKey('back_$index'),
                  child: const Icon(
                    Icons.question_mark,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
