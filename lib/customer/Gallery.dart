import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<String>> _imageUrls;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final Color _primaryColor = Color(0xFF6AC5C5);
  final Color _secondaryColor = Color(0xFF2E3B4E);

  @override
  void initState() {
    super.initState();
    _imageUrls = fetchImageUrls();
    _scrollController.addListener(_onScroll);
  }

  Future<List<String>> fetchImageUrls() async {
    try {
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient.from('images').select('image_url');

      return response.map((item) {
        String url = item['image_url'] as String;
        url = url.replaceAll('3frame/3frame', '3frame');

        if (!url.startsWith('https')) {
          return supabaseClient.storage.from('3frame').getPublicUrl(url);
        }
        return url;
      }).toList();
    } catch (e) {
      print('Error fetching image URLs: $e');
      throw Exception('Error fetching image URLs: تأكد من الاتصال بالانترنيت');
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
          FutureBuilder<List<String>>(
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
            Icon(Icons.error_outline,
                color: _primaryColor,
                size: 60),
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
              onPressed: () => setState(() => _imageUrls = fetchImageUrls()),
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
            Icon(Icons.photo_library,
                color: _primaryColor,
                size: 60),
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

  Widget _buildGalleryGrid(List<String> images) {
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
            return _buildGalleryItem(images[index], index);
          },
          childCount: images.length,
        ),
      ),
    );
  }

  Widget _buildGalleryItem(String imageUrl, int index) {
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                Icon(Icons.broken_image,
                    color: _primaryColor,
                    size: 40),
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