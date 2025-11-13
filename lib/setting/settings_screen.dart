// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // (임시) 설정값 상태
  bool _isBgmOn = true;
  bool _isSfxOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: const Color(0xFF5A67D8),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. 배경 음악 설정
          SwitchListTile(
            title: const Text(
              '배경 음악',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(_isBgmOn ? '켜짐' : '꺼짐'),
            value: _isBgmOn,
            onChanged: (bool value) {
              setState(() {
                _isBgmOn = value;
                // TODO: 실제 배경 음악 On/Off 로직 연결
                print('배경 음악: $_isBgmOn');
              });
            },
            secondary: Icon(
              _isBgmOn ? Icons.music_note : Icons.music_off,
              color: const Color(0xFF5A67D8),
            ),
            activeColor: const Color(0xFF5A67D8),
          ),

          const Divider(),

          // 2. 효과음 설정
          SwitchListTile(
            title: const Text(
              '효과음',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(_isSfxOn ? '켜짐' : '꺼짐'),
            value: _isSfxOn,
            onChanged: (bool value) {
              setState(() {
                _isSfxOn = value;
                // TODO: 실제 효과음 On/Off 로직 연결
                print('효과음: $_isSfxOn');
              });
            },
            secondary: Icon(
              _isSfxOn ? Icons.volume_up : Icons.volume_off,
              color: const Color(0xFF5A67D8),
            ),
            activeColor: const Color(0xFF5A67D8),
          ),
        ],
      ),
    );
  }
}
