import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomerFeedbackPage extends StatefulWidget {
  @override
  _CustomerFeedbackPageState createState() => _CustomerFeedbackPageState();
}

class _CustomerFeedbackPageState extends State<CustomerFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء اختيار تقييم')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('feedbacks').insert({
        'feedback': _feedbackController.text,
        'rating': _rating,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': supabase.auth.currentUser?.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('شكراً لك! تم إرسال ملاحظاتك بنجاح')),
      );

      _feedbackController.clear();
      setState(() => _rating = 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: تأكد من الاتصال بالانترنيت')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملاحظات والتقييم',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'شاركنا رأيك',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'نقدر ملاحظاتك لتحسين تجربتك',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'كيف تقيم تجربتك مع التطبيق؟',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      _rating == 0
                          ? 'لم يتم التقييم'
                          : 'تقييمك: ${_rating.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'ملاحظاتك أو اقتراحاتك',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال ملاحظاتك';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A11CB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'إرسال الملاحظات',
                    style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}