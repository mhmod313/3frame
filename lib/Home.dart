import 'package:flutter/material.dart';
import 'admin/uploadimage.dart';
import 'customer/Gallery.dart';
import 'admin/homeadmin.dart';
import 'customer/homecustomer.dart';
import 'model/button.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  TextEditingController passwordController = TextEditingController();
  final String adminPassword = "646364663";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _colorAnimation = ColorTween(
      begin: Color(0xFF6A11CB),
      end: Color(0xFF2575FC),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF434343), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "الدخول كمسؤول",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    hintText: "كلمة المرور",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("إلغاء", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (passwordController.text == adminPassword) {
                          Navigator.pop(context);
                          _navigateToPage(HomeAdmin());
                          passwordController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("كلمة المرور غير صحيحة"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text("تأكيد", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorAnimation.value!, _colorAnimation.value!.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Background Animated Elements
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _animation.value,
                          child: Image.asset(
                            "assets/images/3frame.png",
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              "3Frame Studio",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "تصميمات احترافية بلمسة فنية",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Buttons Container
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Admin Button
                            _buildAuthButton(
                              context,
                              title: "دخول كمسؤول",
                              icon: Icons.admin_panel_settings_outlined,
                              onPressed: _showPasswordDialog,
                              color: Colors.deepPurpleAccent,
                            ),

                            SizedBox(height: 20),

                            // Customer Button
                            _buildAuthButton(
                              context,
                              title: "دخول كعميل",
                              icon: Icons.person_outline,
                              onPressed: () => _navigateToPage(HomeCustomer()),
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onPressed,
        required Color color,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 28),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}