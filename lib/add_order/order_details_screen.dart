import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model.dart';
import 'add_order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final TailorOrder order;
  const OrderDetailsScreen({super.key, required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.newOrder:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Scaffold(
      backgroundColor: const Color(0xfff5f4ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff6c63ff),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(order.customerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AddOrderScreen(order: order)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  order.status.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (order.isOverdue) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Customer info
          _card('Customer', [
            _row(Icons.person, 'Name', order.customerName),
            if (order.phone.isNotEmpty) _row(Icons.phone, 'Phone', order.phone),
          ]),
          const SizedBox(height: 12),
          // Order info
          _card('Order', [
            _row(Icons.content_cut, 'Description', order.description),
            _row(
              Icons.calendar_today,
              'Received',
              fmt.format(order.receiveDate),
            ),
            _row(
              Icons.event_available,
              'Delivery',
              fmt.format(order.deliveryDate),
            ),
            if (order.notes != null && order.notes!.isNotEmpty)
              _row(Icons.note, 'Notes', order.notes!),
          ]),
          const SizedBox(height: 12),
          // Payment
          _card('Payment', [
            _payRow('Total Price', order.price, Colors.grey.shade700),
            _payRow('Paid', order.paid, Colors.green),
            const Divider(),
            _payRow('Remaining', order.remaining, Colors.red),
          ]),
          // Measurements
          if (_hasMeasurements) ...[
            const SizedBox(height: 12),
            _card('Measurements (cm)', [
              if (order.chest != null)
                _row(Icons.straighten, 'Chest', '${order.chest} cm'),
              if (order.waist != null)
                _row(Icons.straighten, 'Waist', '${order.waist} cm'),
              if (order.length != null)
                _row(Icons.height, 'Length', '${order.length} cm'),
              if (order.sleeve != null)
                _row(Icons.straighten, 'Sleeve', '${order.sleeve} cm'),
              if (order.shoulder != null)
                _row(Icons.straighten, 'Shoulder', '${order.shoulder} cm'),
            ]),
          ],
          const SizedBox(height: 12),
          // Timeline
          _card('Timeline', [
            _timelineStep('Order Received', true, Colors.blue),
            _timelineStep(
              'In Progress',
              order.status == OrderStatus.inProgress ||
                  order.status == OrderStatus.delivered,
              Colors.orange,
            ),
            _timelineStep(
              'Delivered',
              order.status == OrderStatus.delivered,
              Colors.green,
            ),
          ]),
        ],
      ),
    );
  }

  bool get _hasMeasurements =>
      order.chest != null ||
      order.waist != null ||
      order.length != null ||
      order.sleeve != null ||
      order.shoulder != null;

  Widget _card(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xff6c63ff),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xff6c63ff)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _payRow(String label, double amount, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          '${amount.toStringAsFixed(0)} USD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _timelineStep(String label, bool done, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? color : Colors.grey.shade300,
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: done ? FontWeight.bold : FontWeight.normal,
            color: done ? color : Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
