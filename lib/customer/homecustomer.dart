import 'package:flutter/material.dart';
import 'package:frame3/customer/submit%20a%20note.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Gallery.dart';
import 'Reservations.dart';
import 'contact us.dart';
import 'offers.dart';

class HomeCustomer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2E35),
              Color(0xFF0D1C22),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            SizedBox(height: 40),
            // Buttons Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildFeatureButton(
                      context,
                      icon: Icons.photo_library_outlined,
                      title: "المعرض",
                      color: Color(0xFF6AC5C5),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context)=>GalleryPage()));
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      icon: Icons.calendar_today_outlined,
                      title: "الحجز",
                      color: Color(0xFFF5A623),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context)=>BookingPage()));
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      icon: Icons.note_alt_outlined,
                      title: "الملاحظات",
                      color: Color(0xFFE46472),
                      onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerFeedbackPage()));
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      icon: Icons.local_offer_outlined,
                      title: "العروض",
                      color: Color(0xFF51F523),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context)=>OffersPage()));
                      },
                    ),
                    _buildFeatureButton(
                      context,
                      icon: Icons.contact_support_outlined,
                      title: "تواصل معنا",
                      color: Color(0xFF7D8AE7),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ContactUsPage()));
                      },
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.perm_identity, color: Colors.white70),
                  onPressed: () {},
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(
                    'assets/images/logo.jpg',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "مرحباً بك",
              style: GoogleFonts.tajawal(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "كيف يمكننا مساعدتك اليوم؟",
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}