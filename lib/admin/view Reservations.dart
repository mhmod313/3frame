import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBookingsPage extends StatefulWidget {
  @override
  _AdminBookingsPageState createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  List<Map<String, dynamic>> _pendingBookings = [];
  List<Map<String, dynamic>> _acceptedBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // جلب الحجوزات المعلقة
      final pendingResponse = await supabase
          .from('bookings')
          .select()
          .eq('status', 'pending');

      // جلب الحجوزات المقبولة
      final acceptedResponse = await supabase
          .from('bookings')
          .select()
          .eq('status', 'accepted');

      setState(() {
        _pendingBookings = List<Map<String, dynamic>>.from(pendingResponse);
        _acceptedBookings = List<Map<String, dynamic>>.from(acceptedResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في جلب الحجوزات: تأكد من الاتصال بالانترنيت')),
      );
    }
  }

  Future<void> _updateBookingStatus(int id, String status) async {
    final action = status == 'accepted' ? 'قبول' : 'رفض';

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد $action الحجز'),
        content: Text('هل أنت متأكد أنك تريد $action هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('bookings')
            .update({'status': status})
            .eq('id', id.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم $action الحجز بنجاح')),
        );

        await _fetchBookings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء $action الحجز: تأكد من الاتصال بالانترنيت')),
        );
      }
    }
  }

  Future<void> _deleteBooking(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد حذف الحجز'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا الحجز؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final supabase = Supabase.instance.client;
        await supabase
            .from('bookings')
            .delete()
            .eq('id', id.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الحجز بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        await _fetchBookings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حذف الحجز: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة الحجوزات'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'الحجوزات المعلقة (${_pendingBookings.length})'),
              Tab(text: 'الحجوزات المقبولة (${_acceptedBookings.length})'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildBookingsList(_pendingBookings, isPending: true),
            _buildBookingsList(_acceptedBookings, isPending: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, {required bool isPending}) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'لا توجد حجوزات ${isPending ? 'معلقة' : 'مقبولة'}',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, isPending: isPending);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, {required bool isPending}) {
    final startTime = DateTime.parse(booking['start_time']);
    final endTime = DateTime.parse(booking['end_time']);
    final duration = endTime.difference(startTime);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
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
                Text(
                  booking['client_name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    booking['session_type'],
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getSessionColor(booking['session_type']),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'رقم الهاتف: ${booking['phone_number']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(DateFormat('yyyy-MM-dd').format(startTime)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}'),
                SizedBox(width: 16),
                Text('(${duration.inHours} ساعة ${duration.inMinutes.remainder(60)} دقيقة)'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (isPending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text('قبول', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _updateBookingStatus(booking['id'], 'accepted'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text('رفض', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _deleteBooking(booking['id']),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete, color: Colors.white),
                      label: Text('حذف', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _deleteBooking(booking['id']),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSessionColor(String sessionType) {
    switch (sessionType) {
      case 'تصوير':
        return Colors.blue;
      case 'مونتاج':
        return Colors.purple;
      case 'برمجة':
        return Colors.orange;
      case 'تصميم جرافيك':
        return Colors.green;
      case 'استشارة فنية':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}