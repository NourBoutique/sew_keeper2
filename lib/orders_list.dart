import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../model.dart';

import 'add_order/order_details_screen.dart';
import 'order_storge.dart';

class OrdersList extends StatelessWidget {
  final List<TailorOrder> orders;
  const OrdersList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.content_cut, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No orders found',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final TailorOrder order;
  const _OrderCard({required this.order});

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

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.newOrder:
        return Icons.fiber_new_rounded;
      case OrderStatus.inProgress:
        return Icons.cut_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
    }
  }

  Color _colorOf(OrderStatus s) {
    switch (s) {
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
    final provider = context.read<OrdersProvider>();
    final fmt = DateFormat('dd MMM yyyy');

    return Dismissible(
      key: Key(order.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async => _confirmDelete(context),
      onDismissed: (_) => provider.deleteOrder(order.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _statusColor.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(left: BorderSide(color: _statusColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_statusIcon, color: _statusColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (order.phone.isNotEmpty)
                            Text(
                              order.phone,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _pill(
                          '${order.price.toStringAsFixed(0)} USD',
                          Colors.green,
                        ),
                        const SizedBox(height: 4),
                        if (order.remaining > 0)
                          _pill(
                            'Due: ${order.remaining.toStringAsFixed(0)} USD',
                            Colors.red,
                          ),
                      ],
                    ),
                  ],
                ),
                // Description
                if (order.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    order.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                // Dates
                Row(
                  children: [
                    _dateChip(
                      Icons.calendar_today,
                      'Received',
                      fmt.format(order.receiveDate),
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _dateChip(
                      Icons.event_available,
                      'Delivery',
                      fmt.format(order.deliveryDate),
                      order.isOverdue ? Colors.red : Colors.green,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                // Overdue
                if (order.isOverdue) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Overdue!',
                          style: TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
                // Notes
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Quick status buttons
                const SizedBox(height: 10),
                Row(
                  children: OrderStatus.values.map((s) {
                    final selected = order.status == s;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => provider.updateStatus(order.id, s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? _colorOf(s)
                                : _colorOf(s).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : _colorOf(s),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12),
    ),
  );

  Widget _dateChip(IconData icon, String label, String value, Color color) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      );

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Order?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete\n${order.customerName}\'s order?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
