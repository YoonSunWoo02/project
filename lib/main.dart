// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/get_started_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/memory_game_screen.dart';
import 'screens/color_game_screen.dart';
import 'screens/math_game_screen.dart';
import 'setting/lock_screen.dart';
import 'setting/settings_screen.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '만화경 학습 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansKR',
        scaffoldBackgroundColor: const Color(0xFFF9FAFF),
      ),
      debugShowCheckedModeBanner: false,

      // 시작 화면 설정
      home: const GetStartedScreen(),

      // 화면 이동 경로 설정
      routes: {
        '/menu': (context) => const MainMenuScreen(),
        '/game-memory': (context) => const MemoryGameScreen(),
        '/game-color': (context) => const ColorGameScreen(),
        '/game-math': (context) => const MathGameScreen(),
        '/settings': (context) =>
            const SettingsScreen(), // ◀◀◀ 3. Settings 경로 추가
        '/lock': (context) => const LockScreen(),
      },
    );
  }
}
