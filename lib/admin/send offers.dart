import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddOfferPage extends StatefulWidget {
  @override
  _AddOfferPageState createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool _isSending = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Color(0xFF6A11CB),
      end: Color(0xFF2575FC),
    ).animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _addNewOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    _animationController.stop();

    try {
      final response = await Supabase.instance.client
          .from('offers')
          .insert({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'original_price': double.parse(_priceController.text),
        'discount_percentage': double.parse(_discountController.text),
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'expiry_date': DateTime.now()
            .add(Duration(days: int.parse(_durationController.text)))
            .toIso8601String(),
      })
          .select(); // ⬅️ تأكد من استخدام select() للتحقق من نجاح العملية

      if (response.isEmpty) { // ⬅️ التحقق من أن البيانات أُضيفت بالفعل
        throw Exception('لم يتم إضافة البيانات بشكل صحيح.');
      }

      if (mounted) {
        _showSuccessAnimation();
        _clearForm();
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إضافة العرض: تأكد من الاتصال بالانترنيت'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _animationController.repeat(reverse: true);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _discountController.clear();
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.green[50],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animation/notification.json',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'تمت إضافة العرض بنجاح!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'تم',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة عرض جديد',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _colorAnimation.value!,
                            _colorAnimation.value!.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _colorAnimation.value!.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer,
                              color: Colors.white,
                              size: 40),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'سيتم نشر هذا العرض لجميع المستخدمين',
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
                },
              ),
              SizedBox(height: 30),

              // حقل عنوان العرض
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان العرض',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان للعرض';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // حقل وصف العرض
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف العرض',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف للعرض';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مدة العرض (أيام)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال مدة العرض';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days <= 0) {
                    return 'المدة يجب أن تكون رقم صحيح أكبر من الصفر';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // حقل السعر الأصلي
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'السعر الأصلي',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال السعر الأصلي';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // حقل نسبة الخصم
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'نسبة الخصم (%)',
                  prefixIcon: Icon(Icons.discount),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نسبة الخصم';
                  }
                  final discount = double.tryParse(value);
                  if (discount == null || discount <= 0 || discount >= 100) {
                    return 'النسبة يجب أن تكون بين 1 و 99';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // زر الإضافة
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isSending ? 1.0 : _scaleAnimation.value,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _addNewOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSending ? Colors.grey : _colorAnimation.value,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: _colorAnimation.value!.withOpacity(0.3),
                      ),
                      child: _isSending
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('جاري الإضافة...'),
                        ],
                      )
                          : Text(
                        'إضافة العرض',
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}