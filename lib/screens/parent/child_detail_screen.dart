import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChildDetailScreen extends StatelessWidget {
  final String parentUid;
  final String childId;
  final String childName;

  const ChildDetailScreen({
    super.key,
    required this.parentUid,
    required this.childId,
    required this.childName,
  });

  // 아이 정보 삭제 함수
  void _deleteChild(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('아이 정보 삭제'),
        content: Text(
          '정말 "$childName" 어린이의 정보를 삭제하시겠습니까?\n모든 학습 기록이 사라지며 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(parentUid)
                    .collection('children')
                    .doc(childId)
                    .delete();

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('삭제가 완료되었습니다.')));
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _isToday(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 🔥 기억력 게임 + 숫자 퀴즈 (실수 횟수 기반 게임) 확인
  bool _isMistakeBasedGame(String title) {
    return title.contains('기억') ||
        title.contains('Memory') ||
        title.contains('숫자');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$childName의 학습 리포트'),
        backgroundColor: const Color(0xFF5A67D8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '아이 삭제',
            onPressed: () => _deleteChild(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .collection('records')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          int todayPlayCount = 0;
          Map<String, List<int>> gameScores = {
            '숫자 퀴즈': [],
            '색깔 / 모양 분류': [],
            '기억력': [],
          };

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? ts = data['timestamp'];
            final String title = data['gameTitle'] ?? '';
            final int score = data['score'] ?? 0;

            if (ts != null && _isToday(ts)) {
              todayPlayCount++;
            }

            if (title.contains('기억')) {
              gameScores['기억력']!.add(score);
            } else if (title.contains('숫자')) {
              gameScores['숫자 퀴즈']!.add(score);
            } else if (title.contains('색깔')) {
              gameScores['색깔 / 모양 분류']!.add(score);
            }
          }

          return Column(
            children: [
              _buildDashboard(todayPlayCount, gameScores),
              const Divider(height: 1, color: Colors.grey),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildRecordCard(data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            '아직 학습 기록이 없어요.\n아이가 게임을 하면 통계가 나타납니다!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(int todayCount, Map<String, List<int>> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "오늘의 학습량",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    "총 플레이 횟수",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$todayCount",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A67D8),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(
                      "회",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // 🔥 숫자 퀴즈도 이제 '실수 횟수' 기반이므로 기억력 카드 스타일로 표시
              _buildMistakeStatCard(
                '숫자 퀴즈',
                stats['숫자 퀴즈']!,
                Icons.calculate,
                Colors.blue,
              ),
              const SizedBox(width: 10),
              // 색깔 분류 (점수 기준)
              _buildScoreStatCard(
                '색깔 분류',
                stats['색깔 / 모양 분류']!,
                Icons.palette,
                Colors.orange,
              ),
              const SizedBox(width: 10),
              // 기억력 (실수 횟수 기준)
              _buildMistakeStatCard(
                '기억력',
                stats['기억력']!,
                Icons.grid_view_rounded,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. 점수 기반 통계 카드 (색깔 분류)
  Widget _buildScoreStatCard(
    String title,
    List<int> scores,
    IconData icon,
    Color color,
  ) {
    int average = 0;
    if (scores.isNotEmpty) {
      average = (scores.reduce((a, b) => a + b) / scores.length).round();
    }
    Color textColor = (scores.isNotEmpty && average < 7)
        ? Colors.red[700]!
        : Colors.black87;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title.replaceAll(' ', '\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scores.isEmpty ? "-" : "$average점",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scores.isEmpty ? Colors.grey : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. 실수 횟수 기반 통계 카드 (기억력, 숫자 퀴즈)
  Widget _buildMistakeStatCard(
    String title,
    List<int> scores,
    IconData icon,
    Color color,
  ) {
    int average = 0;
    if (scores.isNotEmpty) {
      average = (scores.reduce((a, b) => a + b) / scores.length).round();
    }
    // 색상은 아래 리스트 카드 기준과 비슷하게 (숫자 퀴즈는 2회 이상 주의, 기억력은 5회 이상 주의 등)
    // 여기서는 평균값이므로 심플하게 검정으로 두거나, 특정 기준 적용 가능
    Color textColor = Colors.black87;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title.replaceAll(' ', '\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scores.isEmpty ? "-" : "$average회",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scores.isEmpty ? Colors.grey : textColor,
              ),
            ),
            if (scores.isNotEmpty)
              const Text(
                "(평균 실수)",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> data) {
    final Timestamp? ts = data['timestamp'];
    final String dateStr = ts != null
        ? DateFormat('MM.dd HH:mm').format(ts.toDate())
        : '-';

    final String gameTitle = data['gameTitle'] ?? '게임';
    final int score = data['score'] ?? 0;
    // 🔥 [핵심] 숫자 퀴즈 상세 결과 가져오기
    final String detailResult = data['result'] ?? '';

    String scoreText;
    Color scoreColor;
    Color backgroundColor;
    Widget? subtitleWidget;

    if (gameTitle.contains('숫자')) {
      // 1. 숫자 퀴즈: 2회 이상 틀리면 빨강
      scoreText = '틀린 횟수 : $score회';
      if (score >= 2) {
        scoreColor = Colors.red[700]!;
        backgroundColor = Colors.red[50]!;
      } else {
        scoreColor = Colors.green[700]!;
        backgroundColor = Colors.green[50]!;
      }
      // 🔥 상세 내역(1단계... 2단계...) 표시
      if (detailResult.isNotEmpty) {
        subtitleWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              detailResult,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        );
      }
    } else if (gameTitle.contains('기억')) {
      // 2. 기억력: 5회 이상 틀리면 빨강
      scoreText = '틀린 횟수 : $score회';
      if (score >= 5) {
        scoreColor = Colors.red[700]!;
        backgroundColor = Colors.red[50]!;
      } else {
        scoreColor = Colors.green[700]!;
        backgroundColor = Colors.green[50]!;
      }
    } else if (gameTitle.contains('색깔')) {
      // 3. 색깔: 7점 미만이면 빨강
      scoreText = '$score점';
      if (score < 7) {
        scoreColor = Colors.red[700]!;
        backgroundColor = Colors.red[50]!;
      } else {
        scoreColor = Colors.green[700]!;
        backgroundColor = Colors.green[50]!;
      }
    } else {
      scoreText = '$score점';
      scoreColor = Colors.green[700]!;
      backgroundColor = Colors.green[50]!;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[50],
          child: Icon(
            _getIconForGame(gameTitle),
            color: const Color(0xFF5A67D8),
            size: 20,
          ),
        ),
        title: Text(
          gameTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        // subtitle이 있으면 그걸 쓰고, 없으면 날짜만
        subtitle:
            subtitleWidget ??
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            scoreText,
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForGame(String? title) {
    if (title == null) return Icons.videogame_asset;
    if (title.contains('기억')) return Icons.grid_view_rounded;
    if (title.contains('숫자')) return Icons.calculate;
    if (title.contains('색깔')) return Icons.palette;
    return Icons.videogame_asset;
  }
}
