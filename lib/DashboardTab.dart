import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'order_storge.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrdersProvider>();
    return Scaffold(
      backgroundColor: const Color(0xfff5f4ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff6c63ff),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Revenue summary
          _sectionTitle('Revenue'),
          Row(
            children: [
              _statCard(
                'Total Revenue',
                '${p.totalRevenue.toStringAsFixed(0)} USD',
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(width: 10),
              _statCard(
                'Total Paid',
                '${p.totalPaid.toStringAsFixed(0)} USD',
                Colors.blue,
                Icons.payments,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statCard(
                'Remaining',
                '${p.totalRemaining.toStringAsFixed(0)} USD',
                Colors.orange,
                Icons.account_balance_wallet,
              ),
              const SizedBox(width: 10),
              _statCard(
                'Pending Revenue',
                '${p.pendingRevenue.toStringAsFixed(0)} USD',
                const Color(0xff6c63ff),
                Icons.pending,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Orders summary
          _sectionTitle('Orders'),
          Row(
            children: [
              _statCard(
                'Total',
                '${p.totalCount}',
                Colors.grey.shade600,
                Icons.list_alt,
              ),
              const SizedBox(width: 10),
              _statCard(
                'New',
                '${p.newCount}',
                Colors.blue,
                Icons.fiber_new_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statCard(
                'In Progress',
                '${p.inProgressCount}',
                Colors.orange,
                Icons.cut,
              ),
              const SizedBox(width: 10),
              _statCard(
                'Delivered',
                '${p.deliveredCount}',
                Colors.green,
                Icons.check_circle,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (p.overdueCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${p.overdueCount} overdue order(s)!',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // Monthly chart
          _sectionTitle('Revenue (Last 6 Months)'),
          _MonthlyChart(data: p.monthlyRevenue),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xff6c63ff),
      ),
    ),
  );

  Widget _statCard(String label, String value, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
}

class _MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _MonthlyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final maxRev = data.fold<double>(
      0,
      (m, e) => e['revenue'] > m ? e['revenue'] : m,
    );
    final chartMax = maxRev == 0 ? 1.0 : maxRev;

    return Container(
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
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((e) {
                final rev = (e['revenue'] as double);
                final frac = rev / chartMax;
                final month = e['month'] as DateTime;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (rev > 0)
                          Text(
                            '${(rev / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xff6c63ff),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 120 * frac,
                          decoration: BoxDecoration(
                            color: const Color(0xff6c63ff),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM').format(month),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
