import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/schedule/screens/smart_schedule_and_weather_screen.dart';
import 'package:urban_plants/features/garden/screens/my_garden_screen.dart';
import 'package:urban_plants/features/treatment/screens/safe_first_protocol_screen.dart';
import 'package:urban_plants/features/voice/screens/voice_assistant_screen.dart';
import 'package:urban_plants/features/profile/screens/profile_screen.dart';
import 'package:urban_plants/features/diagnosis/screens/ai_camera_scanner_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeDashboardScreen({super.key, required this.userData});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const SmartScheduleAndWeatherScreen(),
      const MyGardenScreen(),
      const SafeFirstProtocolScreen(),
      const VoiceAssistantScreen(),
      ProfileScreen(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // NÚT CAMERA NỔI GÓC PHẢI (endFloat) - HOÀN TOÀN KHÔNG CHE CHỮ TRUNG TÂM VÀ KHÔNG ĐÈ TAB PHÁC ĐỒ
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AICameraScannerScreen()),
          );
        },
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 26),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.neutralMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            activeIcon: Icon(Icons.wb_sunny),
            label: 'Thời tiết',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.yard_outlined),
            activeIcon: Icon(Icons.yard),
            label: 'Vườn của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Phác đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_none_outlined),
            activeIcon: Icon(Icons.mic),
            label: 'Giọng nói',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
