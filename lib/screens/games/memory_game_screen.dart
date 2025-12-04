import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/record_service.dart';

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
  late List<CardItem> cards;
  int? firstFlippedIndex;
  int? secondFlippedIndex;

  // 🔥 [수정] 처음에 보여주는 동안 터치 막기 위해 true로 시작
  bool isChecking = true;

  final List<IconData> iconPool = [
    Icons.pets,
    Icons.star,
    Icons.favorite,
    Icons.apple,
    Icons.lightbulb,
    Icons.anchor,
  ];

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

      // 🔥 [수정] 처음에는 모든 카드를 뒤집은 상태(앞면)로 시작!
      cards = gameIcons
          .map((icon) => CardItem(icon: icon, isFlipped: true))
          .toList();

      firstFlippedIndex = null;
      secondFlippedIndex = null;
      _isGameEnded = false;
      _mistakeCount = 0;
      isChecking = true; // 1초 동안은 터치 금지
    });

    // 🔥 [추가] 1초 후에 카드를 모두 덮어버리기 (게임 시작)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          for (var card in cards) {
            card.isFlipped = false; // 뒷면으로
          }
          isChecking = false; // 이제 터치 가능!
        });
      }
    });
  }

  void _onCardTapped(int index) {
    if (cards[index].isMatched || isChecking || cards[index].isFlipped) {
      return;
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎉 성공했어요!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('모든 카드의 짝을 맞췄어요!', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                '틀린 횟수: $_mistakeCount번',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A67D8),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '다시 하기',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('기억력 게임'),
        backgroundColor: const Color(0xFF5A67D8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '짝을 찾아보세요!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '실수: $_mistakeCount',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
      child: Card(
        elevation: 4,
        color: card.isMatched ? Colors.grey.shade300 : Colors.blue,
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
                        ? Colors.black.withOpacity(0.5)
                        : Colors.white,
                  ),
                )
              : Center(
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
