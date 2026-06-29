import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class OrdersProvider extends ChangeNotifier {
  List<TailorOrder> _orders = [];

  List<TailorOrder> get orders => _orders;

  // ── Stats ──────────────────────────────────────────────────────────────────
  int get totalCount => _orders.length;
  int get newCount =>
      _orders.where((o) => o.status == OrderStatus.newOrder).length;
  int get inProgressCount =>
      _orders.where((o) => o.status == OrderStatus.inProgress).length;
  int get deliveredCount =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get overdueCount => _orders.where((o) => o.isOverdue).length;
  double get totalRevenue => _orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0, (s, o) => s + o.price);
  double get totalPaid => _orders.fold(0, (s, o) => s + o.paid);
  double get totalRemaining => _orders.fold(0, (s, o) => s + o.remaining);
  double get pendingRevenue => _orders
      .where((o) => o.status != OrderStatus.delivered)
      .fold(0, (s, o) => s + o.price);

  // ── CRUD ───────────────────────────────────────────────────────────────────
  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tailor_orders');
    if (data == null) return;
    try {
      final list = jsonDecode(data) as List;
      _orders = list.map((e) => TailorOrder.fromMap(e)).toList();
      _sort();
      notifyListeners();
    } catch (_) {
      await prefs.remove('tailor_orders');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tailor_orders',
      jsonEncode(_orders.map((e) => e.toMap()).toList()),
    );
  }

  void _sort() =>
      _orders.sort((a, b) => b.receiveDate.compareTo(a.receiveDate));

  Future<void> addOrder(TailorOrder o) async {
    _orders.insert(0, o);
    await _save();
    notifyListeners();
  }

  Future<void> updateOrder(TailorOrder o) async {
    final i = _orders.indexWhere((x) => x.id == o.id);
    if (i != -1) {
      _orders[i] = o;
      _sort();
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> updateStatus(String id, OrderStatus s) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i != -1) {
      _orders[i] = _orders[i].copyWith(status: s);
      await _save();
      notifyListeners();
    }
  }

  List<TailorOrder> search(String q) {
    if (q.isEmpty) return _orders;
    final lq = q.toLowerCase();
    return _orders
        .where(
          (o) =>
              o.customerName.toLowerCase().contains(lq) ||
              o.phone.contains(lq) ||
              o.description.toLowerCase().contains(lq),
        )
        .toList();
  }

  // ── Monthly revenue for chart ───────────────────────────────────────────────
  /// Returns list of {month, revenue} for last 6 months
  List<Map<String, dynamic>> get monthlyRevenue {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - 5 + i);
      final rev = _orders
          .where(
            (o) =>
                o.status == OrderStatus.delivered &&
                o.deliveryDate.year == m.year &&
                o.deliveryDate.month == m.month,
          )
          .fold<double>(0, (s, o) => s + o.price);
      return {'month': m, 'revenue': rev};
    });
  }
}
