import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 로그인 정보 가져오기
import 'package:cloud_firestore/cloud_firestore.dart'; // DB 저장하기
import 'parent_home_screen.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // 아이 나이 선택 (기본값 3세)
  int _selectedAge = 3;
  bool _isLoading = false; // 저장 중 로딩 표시용

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 🔥 아이 정보 저장 함수 (여기가 핵심!)
  void _saveChildInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // ... (파이어베이스 저장 로직 그대로 유지) ...
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('children')
              .add({
                'name': _nameController.text,
                'age': _selectedAge,
                'createdAt': FieldValue.serverTimestamp(),
              });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${_nameController.text} 어린이 등록 완료!')),
            );

            // 2. [수정] 저장 후 'ParentHomeScreen'으로 이동하도록 변경!
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ParentHomeScreen()),
            );
          }
        }
      } catch (e) {
        // 에러 났을 때
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // 로딩 끝
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('아이 등록')),
        // 1. 🔥 여기에 SingleChildScrollView 추가!
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "우리 아이 정보를\n입력해주세요",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "아이에게 딱 맞는 학습 콘텐츠를 추천해드려요.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // 1. 아이 이름
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '아이 이름 (또는 별명)',
                      prefixIcon: Icon(Icons.face),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '아이 이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 2. 나이 선택
                  const Text(
                    "아이 나이",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      int age = index + 3;
                      bool isSelected = _selectedAge == age;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAge = age;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[200],
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.blueAccent, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              "$age세",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // 2. 🔥 [수정] Spacer()는 스크롤뷰 안에서 에러가 납니다.
                  // 대신 넉넉한 여백(SizedBox)을 주세요.
                  const SizedBox(height: 50),

                  // 3. 완료 버튼
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _saveChildInfo,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '등록 완료 & 시작하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                  // 키보드가 올라왔을 때 가려지지 않도록 하단 여백 추가
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
