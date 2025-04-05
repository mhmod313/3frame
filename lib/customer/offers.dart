import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = true;
  final _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadOffers({int page = 1}) async {
    try {
      final limit = 10;
      final offset = (page - 1) * limit;

      final response = await _supabase
          .from('offers')
          .select('*')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      setState(() {
        if (page == 1) {
          _offers = response.toList();
        } else {
          _offers.addAll(response.toList());
        }
        _hasMore = response.length == limit;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحميل العروض:تأكد من الاتصال بالانترنيت '),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      setState(() => _currentPage++);
      _loadOffers(page: _currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('العروض الحالية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange[400]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _offers.isEmpty) {
      return _buildShimmerLoader();
    }

    if (_offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/no_offers.png', width: 200),
            SizedBox(height: 20),
            Text('لا توجد عروض متاحة حالياً', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOffers(page: 1),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _offers.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _offers.length) {
            return _buildLoadingIndicator();
          }
          return _buildOfferCard(_offers[index]);
        },
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final expiryDate = DateTime.parse(offer['expiry_date']);
    final daysRemaining = expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining <= 3;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () {
          // يمكنك إضافة تفاعل عند النقر على العرض هنا
        },
        child: Stack(
          children: [
            // صورة الخلفية (يمكن استبدالها بصور حقيقية)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange[100]!,
                    Colors.orange[50]!,
                  ],
                ),
              ),
            ),

            // محتوى العرض
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان وعلامة التشويق
                  Row(
                    children: [
                      if (isExpiringSoon)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'تنتهي قريباً',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          offer['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // وصف العرض
                  Expanded(
                    child: Text(
                      offer['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: 12),

                  // السعر والخصم
                  Row(
                    children: [
                      Text(
                        '${offer['original_price']} ر.س',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${_calculateDiscountedPrice(offer['original_price'], offer['discount_percentage'])} ر.س',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange[800],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${offer['discount_percentage']}% خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // تاريخ الانتهاء وشريط التقدم
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: 1 - (daysRemaining / 30),
                        backgroundColor: Colors.grey[300],
                        color: isExpiringSoon ? Colors.red : Colors.green,
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ينتهي في ${DateFormat('yyyy/MM/dd').format(expiryDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$daysRemaining أيام متبقية',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpiringSoon ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDiscountedPrice(double originalPrice, double discount) {
    return originalPrice * (1 - discount / 100);
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}