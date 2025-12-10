import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/record_service.dart';

// ... (CardItem 클래스 유지) ...
class CardItem {
  final IconData icon;
  bool isFlipped;
  bool isMatched;
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
  // ... (기존 상태 변수 및 로직 함수들 유지) ...
  late List<CardItem> cards;
  int? firstFlippedIndex;
  int? secondFlippedIndex;
  bool isChecking = true;
  final List<IconData> iconPool = [
    Icons.pets_rounded,
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.apple_rounded,
    Icons.lightbulb_rounded,
    Icons.anchor_rounded,
  ]; // 아이콘 둥근 버전으로 교체
  bool _isGameEnded = false;
  int _mistakeCount = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      List<IconData> gameIcons = [...iconPool, ...iconPool];
      gameIcons.shuffle(Random());
      cards = gameIcons
          .map((icon) => CardItem(icon: icon, isFlipped: true))
          .toList();
      firstFlippedIndex = null;
      secondFlippedIndex = null;
      _isGameEnded = false;
      _mistakeCount = 0;
      isChecking = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted)
        setState(() {
          for (var card in cards) {
            card.isFlipped = false;
          }
          isChecking = false;
        });
    });
  }

  void _onCardTapped(int index) {
    if (cards[index].isMatched || isChecking || cards[index].isFlipped) return;
    setState(() {
      cards[index].isFlipped = true;
      if (firstFlippedIndex == null) {
        firstFlippedIndex = index;
      } else {
        secondFlippedIndex = index;
        isChecking = true;
        _checkForMatch();
      }
    });
  }

  void _checkForMatch() {
    final int index1 = firstFlippedIndex!;
    final int index2 = secondFlippedIndex!;
    if (cards[index1].icon == cards[index2].icon) {
      setState(() {
        cards[index1].isMatched = true;
        cards[index2].isMatched = true;
      });
      _resetFlippedCards();
      if (cards.every((card) => card.isMatched)) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showSuccessDialog();
        });
      }
    } else {
      setState(() {
        _mistakeCount++;
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          cards[index1].isFlipped = false;
          cards[index2].isFlipped = false;
        });
        _resetFlippedCards();
      });
    }
  }

  void _resetFlippedCards() {
    setState(() {
      firstFlippedIndex = null;
      secondFlippedIndex = null;
      isChecking = false;
    });
  }

  void _showSuccessDialog() {
    if (_isGameEnded) return;
    setState(() {
      _isGameEnded = true;
    });
    RecordService().saveRecord(
      gameTitle: '기억력 게임',
      score: _mistakeCount,
      result: '성공',
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
              Icon(
                Icons.celebration_rounded,
                size: 60,
                color: Color(0xFF5A67D8),
              ),
              SizedBox(height: 10),
              Text(
                '🎉 와! 성공했어요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('모든 카드의 짝을 맞췄어요!', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '총 틀린 횟수: $_mistakeCount번',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
                },
                child: const Text('다시 하기'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('기억력 게임 (직소 퍼즐)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 상단 정보 표시줄 디자인
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                  const Text(
                    '짝을 찾아보세요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A67D8),
                    ),
                  ),
                  Text(
                    '실수: $_mistakeCount',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16, // 간격 넓힘
                  mainAxisSpacing: 16,
                ),
                itemCount: cards.length,
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

  Widget _buildCard(int index) {
    CardItem card = cards[index];
    return GestureDetector(
      onTap: () {
        _onCardTapped(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          // 🔥 [디자인] 카드 스타일: 둥글고 그림자 있음
          color: card.isMatched
              ? Colors.grey[100]
              : (card.isFlipped ? Colors.white : const Color(0xFF5A67D8)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (card.isFlipped || card.isMatched)
                  ? Colors.black.withOpacity(0.05)
                  : const Color(0xFF5A67D8).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: card.isFlipped && !card.isMatched
              ? Border.all(color: const Color(0xFF5A67D8), width: 2)
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(turns: animation, child: child);
          },
          child: (card.isFlipped || card.isMatched)
              ? Center(
                  key: ValueKey('front_$index'),
                  child: Icon(
                    card.icon,
                    size: 40,
                    color: card.isMatched
                        ? Colors.grey[400]
                        : const Color(0xFF5A67D8),
                  ),
                )
              : Center(
                  key: ValueKey('back_$index'),
                  child: const Icon(
                    Icons.question_mark_rounded,
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
        ),
      ),
    );
  }
}
