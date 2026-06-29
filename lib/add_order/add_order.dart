import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../model.dart';

import '../order_storge.dart';

class AddOrderScreen extends StatefulWidget {
  final TailorOrder? order;
  const AddOrderScreen({super.key, this.order});
  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  // measurements
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _sleeveCtrl = TextEditingController();
  final _shoulderCtrl = TextEditingController();

  DateTime _receiveDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  OrderStatus _status = OrderStatus.newOrder;

  bool get isEdit => widget.order != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final o = widget.order!;
      _nameCtrl.text = o.customerName;
      _phoneCtrl.text = o.phone;
      _descCtrl.text = o.description;
      _priceCtrl.text = o.price.toString();
      _paidCtrl.text = o.paid.toString();
      _notesCtrl.text = o.notes ?? '';
      _receiveDate = o.receiveDate;
      _deliveryDate = o.deliveryDate;
      _status = o.status;
      if (o.chest != null) _chestCtrl.text = o.chest!.toString();
      if (o.waist != null) _waistCtrl.text = o.waist!.toString();
      if (o.length != null) _lengthCtrl.text = o.length!.toString();
      if (o.sleeve != null) _sleeveCtrl.text = o.sleeve!.toString();
      if (o.shoulder != null) _shoulderCtrl.text = o.shoulder!.toString();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _descCtrl,
      _priceCtrl,
      _paidCtrl,
      _notesCtrl,
      _chestCtrl,
      _waistCtrl,
      _lengthCtrl,
      _sleeveCtrl,
      _shoulderCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool isReceive}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isReceive ? _receiveDate : _deliveryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xff6c63ff)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => isReceive ? _receiveDate = picked : _deliveryDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<OrdersProvider>();
    final data = (
      customerName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      paid: double.tryParse(_paidCtrl.text) ?? 0,
      receiveDate: _receiveDate,
      deliveryDate: _deliveryDate,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      chest: double.tryParse(_chestCtrl.text),
      waist: double.tryParse(_waistCtrl.text),
      length: double.tryParse(_lengthCtrl.text),
      sleeve: double.tryParse(_sleeveCtrl.text),
      shoulder: double.tryParse(_shoulderCtrl.text),
    );

    if (isEdit) {
      provider.updateOrder(
        widget.order!.copyWith(
          customerName: data.customerName,
          phone: data.phone,
          description: data.description,
          price: data.price,
          paid: data.paid,
          receiveDate: data.receiveDate,
          deliveryDate: data.deliveryDate,
          status: data.status,
          notes: data.notes,
          chest: data.chest,
          waist: data.waist,
          length: data.length,
          sleeve: data.sleeve,
          shoulder: data.shoulder,
        ),
      );
    } else {
      provider.addOrder(
        TailorOrder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          customerName: data.customerName,
          phone: data.phone,
          description: data.description,
          price: data.price,
          paid: data.paid,
          receiveDate: data.receiveDate,
          deliveryDate: data.deliveryDate,
          status: data.status,
          notes: data.notes,
          chest: data.chest,
          waist: data.waist,
          length: data.length,
          sleeve: data.sleeve,
          shoulder: data.shoulder,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f4ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff6c63ff),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(isEdit ? 'Edit Order' : 'New Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card('Customer Info', [
              _field(
                _nameCtrl,
                'Customer name',
                Icons.person,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _field(
                _phoneCtrl,
                'Phone',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ]),
            const SizedBox(height: 12),
            _card('Order Details', [
              _field(
                _descCtrl,
                'Description',
                Icons.content_cut,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _priceCtrl,
                      'Total price',
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      _paidCtrl,
                      'Paid',
                      Icons.payments,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 12),
            _card('Measurements (cm)', [
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _chestCtrl,
                      'Chest',
                      Icons.straighten,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _field(
                      _waistCtrl,
                      'Waist',
                      Icons.straighten,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _lengthCtrl,
                      'Length',
                      Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _field(
                      _sleeveCtrl,
                      'Sleeve',
                      Icons.straighten,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _field(
                _shoulderCtrl,
                'Shoulder',
                Icons.straighten,
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 12),
            _card('Dates', [
              _dateRow(
                'Order date',
                _receiveDate,
                Icons.calendar_today,
                const Color(0xff6c63ff),
                () => _pickDate(isReceive: true),
              ),
              const Divider(height: 24),
              _dateRow(
                'Delivery date',
                _deliveryDate,
                Icons.event_available,
                Colors.green,
                () => _pickDate(isReceive: false),
              ),
            ]),
            const SizedBox(height: 12),
            _card('Status', [
              Row(
                children: OrderStatus.values.map((s) {
                  final sel = _status == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? _statusColor(s)
                              : _statusColor(s).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _statusColor(s).withOpacity(sel ? 1 : 0.3),
                          ),
                        ),
                        child: Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : _statusColor(s),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 12),
            _card('Notes', [
              _field(_notesCtrl, 'Notes (optional)', Icons.note, maxLines: 2),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6c63ff),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: _save,
              child: Text(
                isEdit ? 'Save Changes' : 'Add Order',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 0),
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
            fontSize: 13,
            color: Color(0xff6c63ff),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xff6c63ff)),
      filled: true,
      fillColor: const Color(0xfff5f4ff),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff6c63ff)),
      ),
    ),
  );

  Widget _dateRow(
    String label,
    DateTime date,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.edit_calendar, color: color, size: 18),
      ],
    ),
  );

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.newOrder:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
    }
  }
}
