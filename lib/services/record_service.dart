import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRecord({
    required String gameTitle,
    required int score,
    required String result,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parentUid = prefs.getString('parentUid');
      final childId = prefs.getString('childId');
      final role = prefs.getString('userRole');

      // 🕵️‍♂️ 디버깅용 로그: 내 정보가 잘 들어있나 확인!
      print("---------------------------------------");
      print("📝 [저장 시도] 게임: $gameTitle, 점수: $score");
      print("🧐 현재 내 정보: 역할($role), 부모ID($parentUid), 아이ID($childId)");

      // 조건 확인: 역할이 'child'이고, 부모/아이 ID가 모두 있어야 함
      if (role == 'child' && parentUid != null && childId != null) {
        await _db
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .collection('records')
            .add({
              'gameTitle': gameTitle,
              'score': score,
              'result': result,
              'timestamp': FieldValue.serverTimestamp(),
            });

        print("✅ 데이터베이스 저장 성공!");
      } else {
        // 여기가 문제의 원인일 확률 99%!
        print("❌ 저장 실패: 로그인 정보가 부족합니다.");
        print("👉 해결법: 앱을 껐다 켜고 '아이 연결(로그인)'을 다시 해주세요.");
      }
      print("---------------------------------------");
    } catch (e) {
      print("❌ 에러 발생: $e");
    }
  }
}
