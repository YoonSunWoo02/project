// lib/screens/intro_screen.dart
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '환영합니다!\n누가 사용하나요?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),

            // 1. 부모님 버튼
            _buildRoleButton(
              context,
              title: '부모님',
              icon: Icons.face,
              color: const Color(0xFF5A67D8),
              onTap: () {
                // 기존 로그인 화면으로 이동
                Navigator.pushNamed(context, '/login-parent');
              },
            ),
            const SizedBox(height: 20),

            // 2. 아이 버튼
            _buildRoleButton(
              context,
              title: '어린이',
              icon: Icons.child_care,
              color: Colors.orange,
              onTap: () {
                // 아이 연결 화면으로 이동
                Navigator.pushNamed(context, '/login-child');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
