import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model.dart';

import 'DashboardTab.dart';
import 'add_order/add_order.dart';
import 'order_storge.dart';

import 'orders_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  String _q = '';
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f4ff),
      body: _navIndex == 0 ? _ordersBody(provider) : const DashboardTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xff6c63ff).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xff6c63ff),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Order'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddOrderScreen()),
              ),
            )
          : null,
    );
  }

  Widget _ordersBody(OrdersProvider provider) {
    final all = _q.isEmpty ? provider.orders : provider.search(_q);
    final newO = all.where((o) => o.status == OrderStatus.newOrder).toList();
    final inP = all.where((o) => o.status == OrderStatus.inProgress).toList();
    final done = all.where((o) => o.status == OrderStatus.delivered).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff5f4ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff6c63ff),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sew Keeper',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${provider.totalCount} orders',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  'Remaining: ${provider.totalRemaining.toStringAsFixed(0)} usd',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone or description...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xff6c63ff),
                    ),
                    suffixIcon: _q.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _q = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tab,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(text: 'All${all.length}'),
                  Tab(text: 'New${newO.length}'),
                  Tab(text: 'Process${inP.length}'),
                  Tab(text: 'Done${done.length}'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          OrdersList(orders: all),
          OrdersList(orders: newO),
          OrdersList(orders: inP),
          OrdersList(orders: done),
        ],
      ),
    );
  }
}
