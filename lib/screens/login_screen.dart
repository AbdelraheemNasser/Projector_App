import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال اسم المستخدم وكلمة المرور'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    // Authenticate with hardcoded accounts
    final doctor = DoctorAccounts.authenticate(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (doctor != null) {
      // Save login session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', doctor.username);
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(doctor: doctor),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('اسم المستخدم أو كلمة المرور غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                      ),
                    ),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'مرحباً بعودتك دكتور',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E2E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Color(0xFF00D4FF).withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'اسم المستخدم',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.person_outline, color: Color(0xFF00D4FF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E2E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Color(0xFF00D4FF).withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00D4FF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  _isLoading
                      ? CircularProgressIndicator(color: Color(0xFF00D4FF))
                      : Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7B2FF7).withOpacity(0.5),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
