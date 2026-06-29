import 'dart:convert';

enum OrderStatus { newOrder, inProgress, delivered }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'New';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.newOrder:
        return 'new';
      case OrderStatus.inProgress:
        return 'inProgress';
      case OrderStatus.delivered:
        return 'delivered';
    }
  }

  static OrderStatus fromValue(String v) {
    switch (v) {
      case 'inProgress':
        return OrderStatus.inProgress;
      case 'delivered':
        return OrderStatus.delivered;
      default:
        return OrderStatus.newOrder;
    }
  }
}

class TailorOrder {
  final String id;
  final String customerName;
  final String phone;
  final String description;
  final DateTime receiveDate;
  final DateTime deliveryDate;
  final double price;
  final double paid; // ← NEW
  final OrderStatus status;
  final String? notes;
  // measurements
  final double? chest;
  final double? waist;
  final double? length;
  final double? sleeve;
  final double? shoulder;

  const TailorOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.description,
    required this.receiveDate,
    required this.deliveryDate,
    required this.price,
    this.paid = 0,
    required this.status,
    this.notes,
    this.chest,
    this.waist,
    this.length,
    this.sleeve,
    this.shoulder,
  });

  double get remaining => price - paid;
  bool get isOverdue =>
      status != OrderStatus.delivered && deliveryDate.isBefore(DateTime.now());

  TailorOrder copyWith({
    String? customerName,
    String? phone,
    String? description,
    DateTime? receiveDate,
    DateTime? deliveryDate,
    double? price,
    double? paid,
    OrderStatus? status,
    String? notes,
    double? chest,
    double? waist,
    double? length,
    double? sleeve,
    double? shoulder,
  }) => TailorOrder(
    id: id,
    customerName: customerName ?? this.customerName,
    phone: phone ?? this.phone,
    description: description ?? this.description,
    receiveDate: receiveDate ?? this.receiveDate,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    price: price ?? this.price,
    paid: paid ?? this.paid,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    chest: chest ?? this.chest,
    waist: waist ?? this.waist,
    length: length ?? this.length,
    sleeve: sleeve ?? this.sleeve,
    shoulder: shoulder ?? this.shoulder,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'customerName': customerName,
    'phone': phone,
    'description': description,
    'receiveDate': receiveDate.toIso8601String(),
    'deliveryDate': deliveryDate.toIso8601String(),
    'price': price,
    'paid': paid,
    'status': status.value,
    'notes': notes,
    'chest': chest,
    'waist': waist,
    'length': length,
    'sleeve': sleeve,
    'shoulder': shoulder,
  };

  factory TailorOrder.fromMap(Map<String, dynamic> m) => TailorOrder(
    id: m['id'],
    customerName: m['customerName'],
    phone: m['phone'] ?? '',
    description: m['description'],
    receiveDate: DateTime.parse(m['receiveDate']),
    deliveryDate: DateTime.parse(m['deliveryDate']),
    price: (m['price'] ?? 0).toDouble(),
    paid: (m['paid'] ?? 0).toDouble(),
    status: OrderStatusX.fromValue(m['status']),
    notes: m['notes'],
    chest: m['chest']?.toDouble(),
    waist: m['waist']?.toDouble(),
    length: m['length']?.toDouble(),
    sleeve: m['sleeve']?.toDouble(),
    shoulder: m['shoulder']?.toDouble(),
  );
}
