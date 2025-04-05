import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String companyEmail = "3framecompany@gmail.com";
  final String phoneNumber = "+963951562341";
  final String address = "القطيفة - ساحة النهر - جانب جامع الهدى";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("تواصل معنا", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Team Section
            Text(
              "فريق العمل",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            SizedBox(height: 20),
            _buildTeamMemberCard(
              name: "مصعب حورية",
              role: "مصور فوتوغرافي محترف",
              description: "متخصص في التصوير الفوتوغرافي بجميع أنواعه، يمتلك عينًا فنية لالتقاط اللحظات المميزة",
              icon: Icons.camera_alt,
              color: Color(0xFF6AC5C5),
            ),
            _buildTeamMemberCard(
              name: "أحمد عبد الدايم",
              role: "مونتاج وتعديل الفيديوهات",
              description: "خبير في تحرير الفيديوهات والمؤثرات البصرية، يحول اللقطات إلى قصص مرئية مؤثرة",
              icon: Icons.videocam,
              color: Color(0xFFF5A623),
            ),
            _buildTeamMemberCard(
              name: "محمود إسماعيل",
              role: "هندسة برمجيات وحلول تقنية",
              description: "مطور حلول برمجية مبتكرة، يصمم أنظمة تلبي احتياجات العملاء بدقة عالية",
              icon: Icons.code,
              color: Color(0xFFE46472),
            ),
            _buildTeamMemberCard(
              name: "  راما عيوش & سلام سعدالله",
              role: "تصميم جرافيك",
              description: "مصمم إبداعي يبتكر هويات بصرية مميزة ويحول الأفكار إلى تصاميم جذابة",
              icon: Icons.design_services,
              color: Color(0xFF7D8AE7),
            ),

            // Contact Info Section
            SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "معلومات التواصل",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6A11CB)),
                    ),
                    SizedBox(height: 15),
                    _buildContactInfoRow(Icons.email, "البريد الإلكتروني", companyEmail, () {
                    }),
                    _buildContactInfoRow(Icons.phone, "رقم الهاتف", phoneNumber, () {
                    }),
                    _buildContactInfoRow(Icons.location_on, "العنوان", address, () {
                    }),
                  ],
                ),
              ),
            ),

            // Social Media Section
            SizedBox(height: 30),
            Text(
              "تابعنا على وسائل التواصل",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook, Colors.blue[700]!,
                    onTap: () => _launchURL('https://www.facebook.com/share/1HBE8aH5oQ/')),
                SizedBox(width: 15),
                _buildSocialIcon(Icons.camera_alt_outlined, Color(0xFFE1306C),
                    onTap: () => _launchURL('https://instagram.com/_3frame')),
                SizedBox(width: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(color: color, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
      // Consider showing a snackbar to the user
    }
  }

  Widget _buildContactInfoRow(IconData icon, String title, String value, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF6A11CB)),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        radius: 25,
        child: Icon(icon, color: color),
      ),
    );
  }

  // دالة جديدة لفتح الروابط

}