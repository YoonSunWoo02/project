import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // 배경: 연한 회색
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 로고 및 타이틀 영역
              const Icon(
                Icons.volunteer_activism_rounded,
                size: 80,
                color: Color(0xFF5A67D8),
              ),
              const SizedBox(height: 20),
              const Text(
                "GrowUp",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5A67D8),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "우리 아이 성장 도우미",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),

              // 2. 역할 선택 카드 (부모님)
              _buildRoleCard(
                context,
                title: "부모님이에요",
                icon: Icons.face_rounded,
                color: const Color(0xFF5A67D8),
                onTap: () => Navigator.pushNamed(context, '/login/parent'),
              ),
              const SizedBox(height: 20),

              // 3. 역할 선택 카드 (어린이)
              _buildRoleCard(
                context,
                title: "어린이에요",
                icon: Icons.child_care_rounded,
                color: Colors.orangeAccent,
                onTap: () => Navigator.pushNamed(context, '/login/child'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // 둥글게
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15), // 그림자 색상을 버튼 색과 맞춤
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
