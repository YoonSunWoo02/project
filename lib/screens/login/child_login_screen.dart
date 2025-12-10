import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _savedChildName; // 🔥 저장된 아이 이름을 기억할 변수

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 화면 켜지자마자 확인
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus(); // 화면 돌아올 때마다 확인
  }

  // 🔥 로그인 상태 확인 함수
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 아이 이름이 있는지 확인
    final savedName = prefs.getString('childName');
    final savedParentUid = prefs.getString('parentUid');

    if (mounted) {
      setState(() {
        // 부모님 ID와 아이 이름이 모두 있으면 로그인된 것으로 간주!
        if (savedName != null && savedParentUid != null) {
          _savedChildName = savedName;
        } else {
          _savedChildName = null;
        }
      });
    }
  }

  // 부모님 찾기 및 연결 함수
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
      // 1. 부모 찾기
      final parentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (parentSnapshot.docs.isEmpty) throw Exception('등록되지 않은 부모님 이메일입니다.');
      final parentUid = parentSnapshot.docs.first.id;

      // 2. 아이 확인
      final childSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      if (childSnapshot.docs.isEmpty)
        throw Exception('"$name" 어린이를 찾을 수 없어요. 부모님 앱에 먼저 등록해주세요.');

      // 3. 정보 저장 (기기에 영구 저장!)
      final childId = childSnapshot.docs.first.id;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('parentUid', parentUid);
      await prefs.setString('childId', childId);
      await prefs.setString('userRole', 'child'); // 현재 역할: 어린이
      await prefs.setString('childName', name); // 🔥 이름 저장 (핵심)

      if (!mounted) return;

      // 저장 완료 후 바로 메뉴로 이동
      Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔥 로그아웃 (다른 친구로 변경)
  Future<void> _disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 저장된 정보 삭제

    setState(() {
      _savedChildName = null;
      _emailController.clear();
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('부모님과 연결하기')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔥 저장된 이름이 있으면 '환영 화면', 없으면 '입력 화면' 보여주기
              if (_savedChildName != null)
                _buildAlreadyConnectedView()
              else
                _buildConnectionForm(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. 입력창 화면 (기존 디자인)
  Widget _buildConnectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.link_rounded,
              size: 60,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          '부모님의 이메일과\n내 이름을 입력해주세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),

        _buildCustomTextField(
          controller: _emailController,
          label: '부모님 이메일',
          hint: 'example@email.com',
          icon: Icons.email_rounded,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _nameController,
          label: '내 이름',
          hint: '부모님이 등록한 이름',
          icon: Icons.face_rounded,
        ),

        const SizedBox(height: 40),

        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _connectToParent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  '연결하고 시작하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
      ],
    );
  }

  // 2. 이미 연결된 화면 (환영 화면)
  Widget _buildAlreadyConnectedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 50),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 80,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          '$_savedChildName 어린이,\n다시 왔군요!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '이어서 게임을 시작할까요?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 50),

        // 시작 버튼
        ElevatedButton(
          onPressed: () async {
            // 🔥 중요: 다시 들어올 때 역할을 'child'로 확실하게 설정해줌
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userRole', 'child');

            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/menu',
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Text(
            '네! 시작할래요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),

        // 로그아웃 버튼
        OutlinedButton(
          onPressed: _disconnect,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            '아니요, 다른 친구예요 (로그아웃)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 디자인된 텍스트 필드
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
