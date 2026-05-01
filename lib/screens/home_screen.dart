import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';
import 'video_screen.dart';
import 'pdf_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final Doctor doctor;

  const HomeScreen({super.key, required this.doctor});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _logout(context),
                      icon: Icon(Icons.logout, color: Color(0xFFE94560)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'مرحباً',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          doctor.fullName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اختر نوع المحاضرة',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 50),
                        _buildOptionCard(
                          context,
                          icon: Icons.video_library,
                          title: 'محاضرات فيديو',
                          subtitle: 'عرض وتشغيل ملفات الفيديو',
                          gradientColors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoScreen(doctor: doctor),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 30),
                        _buildOptionCard(
                          context,
                          icon: Icons.picture_as_pdf,
                          title: 'محاضرات PDF',
                          subtitle: 'عرض وتشغيل ملفات PDF',
                          gradientColors: [Color(0xFF7B2FF7), Color(0xFFE94560)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFScreen(doctor: doctor),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
