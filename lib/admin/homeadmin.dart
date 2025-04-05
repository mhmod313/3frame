import 'package:flutter/material.dart';
import 'package:frame3/admin/view%20Reservations.dart';
import 'package:frame3/admin/view%20feedback.dart';

import 'editegallary.dart';
import 'send offers.dart';
import 'uploadimage.dart';

class HomeAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header Section
          _buildHeader(context),
          SizedBox(height: 40),
          // Admin Features Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildAdminButton(
                    context,
                    icon: Icons.add_photo_alternate,
                    title: "رفع صورة",
                    color: Color(0xFF6AC5C5),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AdminUploadPage()));
                    },
                  ),
                  _buildAdminButton(
                    context,
                    icon: Icons.calendar_today,
                    title: "عرض الحجوزات",
                    color: Color(0xFFF5A623),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AdminBookingsPage()));
                    },
                  ),
                  _buildAdminButton(
                    context,
                    icon: Icons.mode_edit_outlined,
                    title: "تعديل المعرض",
                    color: Color(0xFF75E464),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => EditeGalleryPage()));
                    },
                  ),
                  _buildAdminButton(
                    context,
                    icon: Icons.notes,
                    title: "عرض الملاحظات",
                    color: Color(0xFFE46472),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FeedbackDisplayPage()));
                    },
                  ),
                  _buildAdminButton(
                    context,
                    icon: Icons.notifications_active,
                    title: "ارسال عرض",
                    color: Color(0xFF7D8AE7),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AddOfferPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "مرحباً، المسؤول",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 8),
          Text(
            "لوحة التحكم الإدارية",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
