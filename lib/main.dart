import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 화면들 Import
import 'screens/intro_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/login/child_login_screen.dart';
import 'screens/login/parent_login_screen.dart';
import 'screens/login/parent_signup_screen.dart';
import 'screens/parent/parent_home_screen.dart';
import 'screens/games/math_game_screen.dart';
import 'screens/games/color_game_screen.dart';
import 'screens/games/memory_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A67D8),
          background: const Color(0xFFF5F7FA),
          primary: const Color(0xFF5A67D8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Pretendard',

        // 🔥 [수정] 앱바 스타일: 아래쪽을 더 둥글게(30px) 만들어서 꽉 찬 느낌 주기
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5A67D8),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0, // 스크롤 시 색상 변경 방지
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),

        // 버튼 스타일
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A67D8),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const IntroScreen(),
        '/login/child': (context) => const ChildLoginScreen(),
        '/login/parent': (context) => const ParentLoginScreen(),
        '/signup/parent': (context) => const ParentSignupScreen(),
        '/parent/home': (context) => const ParentHomeScreen(),
        '/menu': (context) => const MainMenuScreen(),
        '/game/math': (context) => const MathGameScreen(),
        '/game/color': (context) => const ColorGameScreen(),
        '/game/memory': (context) => const MemoryGameScreen(),
      },
    );
  }
}
