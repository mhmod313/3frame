import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditeGalleryPage extends StatefulWidget {
  @override
  _EditeGalleryPageState createState() => _EditeGalleryPageState();
}

class _EditeGalleryPageState extends State<EditeGalleryPage> {
  late Future<List<Map<String, dynamic>>> _imageUrls;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final Color _primaryColor = Color(0xFF6AC5C5);
  final Color _secondaryColor = Color(0xFF2E3B4E);
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _imageUrls = _fetchImageUrls();
    _scrollController.addListener(_onScroll);
  }

  Future<List<Map<String, dynamic>>> _fetchImageUrls() async {
    try {
      final response = await _supabase.from('images').select('id, image_url');

      return response.map((item) {
        String url = item['image_url'] as String;

        // تنظيف المسار من أي تكرار
        url = url.replaceAll('3frame/3frame', '3frame');

        // إذا كان الرابط ليس رابطًا كاملاً، نحصل على الرابط العام
        if (!url.startsWith('http')) {
          url = _supabase.storage.from('3frame').getPublicUrl(url);
        }

        return {
          'id': item['id'],
          'url': url,
          'path': item['image_url'], // حفظ المسار الأصلي للتخزين
        };
      }).toList();
    } catch (e) {
      print('Error fetching image URLs: $e');
      throw Exception('Error fetching image URLs: تأكد من الاتصال بالإنترنت');
    }
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: _secondaryColor,
            elevation: 10,
            shadowColor: _primaryColor.withOpacity(0.3),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Image.asset(
                'assets/images/3frame.png',
                fit: BoxFit.fitWidth,
                color: _primaryColor.withOpacity(0.2),
                colorBlendMode: BlendMode.overlay,
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _imageUrls,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _primaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: _buildErrorView(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyView(),
                );
              }

              return _buildGalleryGrid(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _secondaryColor,
            _secondaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: _primaryColor, size: 60),
            SizedBox(height: 20),
            Text(
              'حدث خطأ في تحميل المعرض',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                error,
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => setState(() => _imageUrls = _fetchImageUrls()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                elevation: 5,
                shadowColor: _primaryColor.withOpacity(0.5),
              ),
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _secondaryColor,
            _secondaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, color: _primaryColor, size: 60),
            SizedBox(height: 20),
            Text(
              'المعرض فارغ حالياً',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'سيتم إضافة الصور قريباً',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(List<Map<String, dynamic>> images) {
    return SliverPadding(
      padding: EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildGalleryItem(images[index]['url'], images[index]['id'],
                images[index]['path'], index);
          },
          childCount: images.length,
        ),
      ),
    );
  }

  Widget _buildGalleryItem(
      String imageUrl, int imageId, String storagePath, int index) {
    final double scale = 1 - (_scrollOffset / 1000).clamp(0.0, 0.1);
    final double opacity = 1 - (_scrollOffset / 500).clamp(0.3, 1.0);

    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: opacity,
      child: GestureDetector(
        onTap: () => _openImageDetail(context, imageUrl),
        child: Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: imageUrl,
                    child: _buildNetworkImage(imageUrl),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'الصورة ${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => _confirmDeleteImage(imageId, storagePath),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
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

  Future<void> _confirmDeleteImage(int imageId, String storagePath) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _secondaryColor,
        title: Text('حذف الصورة', style: TextStyle(color: Colors.white)),
        content: Text('هل أنت متأكد أنك تريد حذف هذه الصورة؟',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: _primaryColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // عرض مؤشر تحميل
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(color: _primaryColor),
          ),
        );

        // استخراج المسار النسبي فقط
        String cleanPath = storagePath;

        // إذا كان الرابط كاملًا
        if (cleanPath.contains('supabase.co/storage/v1/object/public/3frame/')) {
          cleanPath = cleanPath.split('public/3frame/').last;
        }

        // إزالة أي '3frame/' مكررة
        cleanPath = cleanPath.replaceAll('3frame/', '');

        print('المسار النهائي للحذف: $cleanPath');

        // 1. حذف الصورة من التخزين
        final storageDeleteResult = await _supabase.storage
            .from('3frame')
            .remove([cleanPath]);

        print('نتيجة حذف التخزين: $storageDeleteResult');

        // 2. حذف السجل من قاعدة البيانات
        final dbDeleteResult = await _supabase
            .from('images')
            .delete()
            .eq('id', imageId);

        print('نتيجة حذف قاعدة البيانات: $dbDeleteResult');

        // إغلاق مؤشر التحميل
        Navigator.pop(context);

        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('تم حذف الصورة بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );

        // تحديث قائمة الصور
        setState(() {
          _imageUrls = _fetchImageUrls();
        });
      } catch (e) {
        // إغلاق مؤشر التحميل في حالة الخطأ
        Navigator.pop(context);

        // عرض رسالة خطأ مفصلة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('حدث خطأ أثناء حذف الصورة: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );

        print('Error deleting image: $e');
      }
    }
  }
  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _secondaryColor,
                _secondaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: _primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _secondaryColor,
                _secondaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: _primaryColor, size: 40),
                SizedBox(height: 10),
                Text(
                  'تعذر تحميل الصورة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openImageDetail(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(
                  opacity: animation.value,
                  child: child,
                );
              },
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: imageUrl,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: FloatingActionButton(
                      backgroundColor: _primaryColor,
                      child: Icon(Icons.download, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }
}
