// lib/screens/lock_screen.dart
import 'package:flutter/material.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부모님 설정'),
        backgroundColor: const Color(0xFF5A67D8),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '자녀의 학습 현황을 관리하거나 앱 설정을 변경할 수 있습니다.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const Divider(),

          // 1. 학습 리포트 (예시)
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Color(0xFF5A67D8)),
            title: const Text(
              '학습 리포트',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('게임별 진행 상황 확인하기'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 학습 리포트 화면으로 이동
              print('학습 리포트 Tapped');
            },
          ),

          // 2. 데이터 초기화 (예시)
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text(
              '게임 기록 초기화',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('모든 게임의 레벨과 점수를 초기화합니다.'),
            onTap: () {
              // TODO: 초기화 확인 다이얼로그 띄우기
              print('데이터 초기화 Tapped');
            },
          ),

          // 3. 앱 종료 (예시)
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.grey),
            title: const Text(
              '앱 종료하기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              // TODO: 앱 종료 로직 (SystemNavigator.pop())
              print('앱 종료 Tapped');
            },
          ),
        ],
      ),
    );
  }
}
