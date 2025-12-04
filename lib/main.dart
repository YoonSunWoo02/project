import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 1. 사용할 화면들을 모두 가져오기 (Import)
import 'screens/login/login_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login/signup_screen.dart';
import 'screens/parent/add_child_screen.dart';
import 'screens/login/child_login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'setting/lock_screen.dart';

// 게임 화면들 Import (파일 이름이 맞는지 확인하세요!)
import 'screens/games/math_game_screen.dart';
import 'screens/games/color_game_screen.dart';
import 'screens/games/memory_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 파이어베이스 초기화
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Pretendard', // (만약 폰트 설정하셨다면 유지)
      ),

      // 2. 앱의 첫 시작 화면 설정
      // (IntroScreen이나 LoginScreen 중 원하시는 것으로 설정)
      home: const IntroScreen(),

      // 🔥 3. 여기가 핵심! 주소 등록 (Routes)
      routes: {
        // 경로 이름 : (context) => 이동할 화면 위젯()
        '/login-parent': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/add-child': (context) => const AddChildScreen(),
        '/login-child': (context) => const ChildLoginScreen(),

        // 메인 메뉴
        '/menu': (context) => const MainMenuScreen(),

        // 부모님 보호 화면 (리포트)
        '/lock': (context) => const LockScreen(),

        // 🎮 게임 화면들 (이게 없어서 에러가 났던 겁니다!)
        '/game-math': (context) => const MathGameScreen(),
        '/game-color': (context) => const ColorGameScreen(),
        '/game-memory': (context) => const MemoryGameScreen(),

        // 설정 화면 (아직 안 만들었으면 주석 처리 하거나 빈 화면 연결)
        '/settings': (context) =>
            const Scaffold(body: Center(child: Text("설정 화면 준비중"))),
      },
    );
  }
}
