import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _emailController = TextEditingController(); // 부모님 이메일
  final _nameController = TextEditingController(); // 아이 이름
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 🔥 부모님 찾기 및 아이 이름 확인 함수
  Future<void> _connectToParent() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 이름을 모두 입력해주세요.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1단계: 이메일로 부모님 계정(User) 찾기
      final parentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // 하나만 찾기
          .get();

      if (parentSnapshot.docs.isEmpty) {
        throw Exception('등록되지 않은 부모님 이메일입니다.');
      }

      final parentDoc = parentSnapshot.docs.first;
      final parentUid = parentDoc.id;

      // 2단계: 그 부모님 밑에 '입력한 이름'을 가진 아이가 있는지 확인! (핵심)
      final childSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .where('name', isEqualTo: name) // 🔥 이름이 똑같은지 비교!
          .limit(1)
          .get();

      if (childSnapshot.docs.isEmpty) {
        // 부모님은 찾았는데, 그 이름의 아이가 없는 경우
        throw Exception('"$name" 어린이를 찾을 수 없어요.\n부모님 앱에서 이름을 먼저 등록해주세요!');
      }

      // 3단계: 찾았다! 로그인 정보 기기에 저장
      final childDoc = childSnapshot.docs.first;
      final childId = childDoc.id; // 이미 등록된 아이의 ID를 가져옴

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('parentUid', parentUid); // 부모님 ID 저장
      await prefs.setString('childId', childId); // 아이 ID 저장
      await prefs.setString('userRole', 'child'); // 역할: 어린이

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name 어린이 환영해요! 신나게 놀아봐요!')));

      // 4단계: 메인 메뉴로 이동
      Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
    } catch (e) {
      // 에러 메시지 보여주기
      String message = e.toString().replaceAll(
        'Exception: ',
        '',
      ); // 'Exception:' 글자 떼기
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 화면 터치시 키보드 내리기
      child: Scaffold(
        appBar: AppBar(title: const Text('부모님과 연결하기')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '엄마, 아빠의 이메일과\n내 이름을 입력해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // 이메일 입력
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '부모님 이메일',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // 이름 입력
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '내 이름 (부모님이 등록한 이름)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.face),
                ),
              ),

              const SizedBox(height: 40),

              // 연결 버튼
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _connectToParent,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '연결하고 시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
