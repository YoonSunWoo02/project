import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. 파이어베이스 기능 가져오기
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parent/add_child_screen.dart'; // 임시로 로그인 성공 시 이동할 곳
import '../parent/parent_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔥 진짜 로그인 함수로 교체됨
  void _tryLogin() async {
    if (_formKey.currentState!.validate()) {
      // 키보드 내리기
      FocusScope.of(context).unfocus();

      try {
        // A. 로그인 시도
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // B. 로그인 성공 시 -> 아이 정보가 있는지 확인
        if (credential.user != null) {
          // DB에서 내(uid) 밑에 있는 'children' 폴더를 열어봅니다.
          final childrenSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .collection('children')
              .get();

          if (!mounted) return; // 화면이 꺼졌으면 중단

          if (childrenSnapshot.docs.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('로그인 성공!')));
            // [수정] 자녀 목록 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ParentHomeScreen()),
            );
          } else {
            // 자녀가 없으면 등록 화면으로 (기존 유지)
            Navigator.pushReplacementNamed(context, '/add-child');
          }
        }
      } on FirebaseAuthException catch (e) {
        // 실패 처리 (기존과 동일)
        String errorMessage = '로그인 실패';
        if (e.code == 'user-not-found') {
          errorMessage = '등록되지 않은 이메일입니다.';
        } else if (e.code == 'wrong-password') {
          errorMessage = '비밀번호가 틀렸습니다.';
        } else if (e.code == 'invalid-email') {
          errorMessage = '이메일 형식이 잘못되었습니다.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = '이메일 혹은 비밀번호가 틀렸습니다.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알 수 없는 에러: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),

                  // 이메일 입력
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                      if (!value.contains('@')) return '유효한 이메일 형식이 아닙니다.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 비밀번호 입력
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return '비밀번호를 입력해주세요.';
                      if (value.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 로그인 버튼
                  ElevatedButton(
                    onPressed: _tryLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 회원가입 버튼
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('계정이 없으신가요? 회원가입'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
