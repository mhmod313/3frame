import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUploadPage extends StatefulWidget {
  @override
  _AdminUploadPageState createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends State<AdminUploadPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  bool _isUploading = false;
  final double _borderRadius = 24.0;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
      });

      try {
        final supabase = Supabase.instance.client;
        final file = File(pickedFile.path);
        final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // 1. Upload to Storage
        final uploadedPath = await supabase.storage
            .from('3frame')
            .upload(fileName, file, fileOptions: FileOptions(upsert: true));

        // 2. Get Public URL
        final publicUrl = supabase.storage
            .from('3frame')
            .getPublicUrl(uploadedPath);

        // 3. Save to Database
        await supabase.from('images').insert({
          'image_url': publicUrl,
          'created_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _imageUrl = publicUrl;
          _isUploading = false;
        });

        _showSuccessDialog(context, publicUrl);
      } catch (e) {
        setState(() => _isUploading = false);
        _showErrorDialog(context, e.toString());
        debugPrint('Upload Error: $e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('تم بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم رفع الصورة بنجاح إلى السيرفر.'),
            SizedBox(height: 10),
            SelectableText(
              url,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('حدث خطأ'),
          ],
        ),
        content: Text('فشل في رفع الصورة: تأكد من الاتصال بالانترنيت'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('رفع الصور...', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Upload Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload,
                            size: 64, color: Color(0xFF6A11CB)),
                        SizedBox(height: 16),
                        Text(
                          'رفع صورة جديدة',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),
                        _buildUploadButton(),
                        SizedBox(height: 20),
                        if (_imageFile != null) _buildImagePreview(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                if (_imageUrl != null) _buildSuccessSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _pickImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6A11CB),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: _isUploading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 10),
            Text('جاري الرفع...'),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate,color: Colors.white,),
            SizedBox(width: 10),
            Text('اختر صورة',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'معاينة الصورة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      children: [
        Icon(Icons.check_circle, size: 50, color: Colors.green),
        SizedBox(height: 16),
        Text(
          'تم رفع الصورة بنجاح',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            _imageUrl!,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}