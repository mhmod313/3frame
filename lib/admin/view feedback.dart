import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class FeedbackDisplayPage extends StatefulWidget {
  @override
  _FeedbackDisplayPageState createState() => _FeedbackDisplayPageState();
}

class _FeedbackDisplayPageState extends State<FeedbackDisplayPage> {
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;
  double _averageRating = 0;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    try {
      final feedbackResponse = await _supabase
          .from('feedbacks')
          .select('*')
          .order('created_at', ascending: false);

      // الطريقة الجديدة لحساب المتوسط
      final ratingsResponse = await _supabase
          .from('feedbacks')
          .select('rating');

      double calculateAverage(List<Map<String, dynamic>> ratings) {
        if (ratings.isEmpty) return 0;
        final sum = ratings
            .map((r) => r['rating'] as num)
            .reduce((a, b) => a + b);
        return sum / ratings.length;
      }

      setState(() {
        _feedbacks = List<Map<String, dynamic>>.from(feedbackResponse);
        _averageRating = calculateAverage(
            List<Map<String, dynamic>>.from(ratingsResponse));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل الملاحظات: تأكد من الاتصال بالانترنيت')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملاحظات العملاء',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: _feedbacks.isEmpty
                ? Center(
              child: Text(
                'لا توجد ملاحظات بعد',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _feedbacks.length,
              itemBuilder: (context, index) {
                return _buildFeedbackCard(_feedbacks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'متوسط التقييم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 32),
                SizedBox(width: 8),
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/5',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${_feedbacks.length} تقييم${_feedbacks.length != 1 ? 'ات' : ''}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final date = DateTime.parse(feedback['created_at']);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRatingStars(feedback['rating']),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (feedback['feedback'] != null && feedback['feedback'].isNotEmpty)
              Text(
                feedback['feedback'],
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 8),
            if (feedback['user_id'] != null)
              FutureBuilder(
                future: _getUserEmail(feedback['user_id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox();
                  }
                  return Text(
                    snapshot.data ?? 'مستخدم مجهول',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating
                ? Icons.star
                : i - 0.5 <= rating
                ? Icons.star_half
                : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<String?> _getUserEmail(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('email')
          .eq('id', userId)
          .single();

      return response['email'];
    } catch (e) {
      return null;
    }
  }
}