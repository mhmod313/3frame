import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String? _sessionType;
  bool _isSubmitting = false;

  final List<String> _sessionTypes = [
    'تصوير',
    'مونتاج',
    'برمجة',
    'تصميم جرافيك',
    'استشارة فنية'
  ];

  Future<void> _selectStartTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _startTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء تحديد وقت البداية أولاً')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime!,
      firstDate: _startTime!,
      lastDate: DateTime(_startTime!.year + 1),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime!.add(Duration(hours: 1))),
      );
      if (time != null) {
        final endTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        if (endTime.isBefore(_startTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('وقت النهاية يجب أن يكون بعد وقت البداية')),
          );
          return;
        }

        setState(() {
          _endTime = endTime;
        });
      }
    }
  }

  Future<bool> _isTimeSlotAvailable() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('bookings')
        .select()
        .gte('end_time', _startTime!.toIso8601String())
        .lte('start_time', _endTime!.toIso8601String());

    return response.isEmpty;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null || _sessionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isAvailable = await _isTimeSlotAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('هذا الموعد محجوز مسبقاً، الرجاء اختيار وقت آخر')),
        );
        return;
      }

      final supabase = Supabase.instance.client;
      await supabase.from('bookings').insert({
        'client_name': _nameController.text,
        'phone_number': _phoneController.text,
        'start_time': _startTime!.toIso8601String(),
        'end_time': _endTime!.toIso8601String(),
        'session_type': _sessionType,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الحجز بنجاح!')),
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() {
        _startTime = null;
        _endTime = null;
        _sessionType = null;
        _nameController.clear();
        _phoneController.clear();
      });
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
        title: Text('حجز موعد', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'حجز جديد',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A11CB),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الاسم';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _phoneController,
                          label: 'رقم الهاتف',
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildDropdownButtonFormField(),
                        SizedBox(height: 24),
                        _buildTimePickerButton(
                          context,
                          title: 'وقت البداية',
                          selectedTime: _startTime,
                          onTap: _selectStartTime,
                        ),
                        SizedBox(height: 16),
                        _buildTimePickerButton(
                          context,
                          title: 'وقت النهاية',
                          selectedTime: _endTime,
                          onTap: _selectEndTime,
                        ),
                        SizedBox(height: 30),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_startTime != null && _endTime != null)
                  _buildBookingSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _sessionType,
      decoration: InputDecoration(
        labelText: 'نوع الجلسة',
        prefixIcon: Icon(Icons.work_outline, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _sessionTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _sessionType = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار نوع الجلسة';
        }
        return null;
      },
    );
  }

  Widget _buildTimePickerButton(
      BuildContext context, {
        required String title,
        required DateTime? selectedTime,
        required Function(BuildContext) onTap,
      }) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600]),
            SizedBox(width: 16),
            Text(
              selectedTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(selectedTime)
                  : title,
              style: TextStyle(
                color: selectedTime != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6A11CB),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
          'تأكيد الحجز',
          style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final duration = _endTime!.difference(_startTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الحجز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A11CB),
              ),
            ),
            SizedBox(height: 12),
            _buildSummaryRow('نوع الجلسة:', _sessionType ?? 'غير محدد'),
            _buildSummaryRow('وقت البداية:',
                DateFormat('yyyy-MM-dd HH:mm').format(_startTime!)),
            _buildSummaryRow('وقت النهاية:',
                DateFormat('yyyy-MM-dd HH:mm').format(_endTime!)),
            _buildSummaryRow('المدة:', '$hours ساعة $minutes دقيقة'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}