import 'package:flutter/material.dart';
import '../core/color_extensions.dart';
import 'dashboard_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final pages = [
    const DashboardPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),

      body: pages[index],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacityValue(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white12),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(Icons.home, 0),
            _item(Icons.history, 1),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, int i) {
    bool active = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Icon(
        icon,
        color: active ? Colors.orange : Colors.grey,
        size: active ? 28 : 22,
      ),
    );
  }
}