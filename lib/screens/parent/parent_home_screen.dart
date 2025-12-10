import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'child_detail_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final _nameController = TextEditingController();
  String? parentUid;

  @override
  void initState() {
    super.initState();
    _getParentUid();
  }

  Future<void> _getParentUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        parentUid = user.uid;
      });
    }
  }

  Future<void> _addChild() async {
    if (_nameController.text.isEmpty || parentUid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .add({
            'name': _nameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      _nameController.clear();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
    }
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이 등록'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: '아이 이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(onPressed: _addChild, child: const Text('등록')),
        ],
      ),
    );
  }

  // 🔥 로그아웃 함수 (이제 뒤로가기랑 다름!)
  Future<void> _logout() async {
    // 1. 진짜로 로그아웃 처리
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    // 2. 첫 화면으로 이동
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // 🔥 그냥 나가기 함수 (로그인 유지됨)
  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자녀 목록'),
        // 1. [왼쪽] 뒤로가기 버튼 (로그인 유지하고 나감)
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: '나가기',
        ),
        // 2. [오른쪽] 로그아웃 버튼 (따로 만듦)
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: '로그아웃',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: parentUid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(parentUid)
                  .collection('children')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('등록된 아이가 없습니다.\n+ 버튼을 눌러 아이를 등록해주세요.'),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final childId = docs[index].id;
                    final childName = data['name'] ?? '이름 없음';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A67D8).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_rounded,
                            color: Color(0xFF5A67D8),
                            size: 28,
                          ),
                        ),
                        title: Text(
                          childName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildDetailScreen(
                                parentUid: parentUid!,
                                childId: childId,
                                childName: childName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddChildDialog,
        backgroundColor: const Color(0xFF5A67D8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
