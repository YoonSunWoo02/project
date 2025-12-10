import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  // 🔥 [수정 1] 역할(role) 상관없이 실제 로그인이 되어있는지만 확인!
  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    // role 확인 부분 삭제함 (아이가 하고 왔어도 부모 계정은 살아있으니까요)

    if (mounted) {
      setState(() {
        if (user != null) {
          _currentUser = user; // 유저 정보가 있으면 로그인 된 것으로 인정
        } else {
          _currentUser = null;
        }
      });
    }
  }

  // 로그인 로직
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("이메일과 비밀번호를 입력해주세요.")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final parentUid = credential.user!.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('parentUid', parentUid);
      await prefs.setString('userRole', 'parent'); // 부모님 이름표 부착

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/parent/home',
        (route) => false,
      );
    } catch (e) {
      String errorMessage = "로그인 실패";
      if (e.toString().contains('user-not-found')) {
        errorMessage = "존재하지 않는 계정입니다.";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "비밀번호가 틀렸습니다.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 로그아웃 로직
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _currentUser = null;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('부모님 로그인')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_currentUser == null)
                _buildLoginForm()
              else
                _buildAlreadyLoggedInView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF5A67D8).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            size: 60,
            color: Color(0xFF5A67D8),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '환영합니다!\n아이의 기록을 확인해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),

        _buildCustomTextField(
          controller: _emailController,
          label: '이메일',
          icon: Icons.email_rounded,
          isObscure: false,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _passwordController,
          label: '비밀번호',
          icon: Icons.key_rounded,
          isObscure: true,
        ),

        const SizedBox(height: 40),

        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(onPressed: _login, child: const Text('로그인')),

        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup/parent');
          },
          child: const Text(
            '계정이 없으신가요? 회원가입 하기',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAlreadyLoggedInView() {
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
        const Text(
          '이미 로그인되어 있어요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '${_currentUser?.email}\n계정으로 계속하시겠습니까?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 50),

        ElevatedButton(
          onPressed: () async {
            // 🔥 [수정 2] 부모님 모드로 복귀할 때, 이름표를 다시 'parent'로 확실하게 붙여줌!
            // 아이가 게임해서 'child'로 바뀌었을 수 있기 때문입니다.
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userRole', 'parent');

            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/parent/home',
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A67D8),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            '네, 계속할게요 (홈으로)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: _logout,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            '아니요, 로그아웃 할게요',
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

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isObscure,
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
        obscureText: isObscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          labelText: label,
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
