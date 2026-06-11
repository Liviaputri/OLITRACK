import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/color_extensions.dart';
import '../services/notification_service.dart';
import '../widgets/history_entry_dialog.dart';
import 'history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final motorBox = Hive.box('motor');
  final historyBox = Hive.box('history');

  late AnimationController controller;
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;
  bool _reminderCheckScheduled = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    )..repeat();

    pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    pulseController.dispose();
    super.dispose();
  }

  int get km =>
      int.tryParse(motorBox.get('km', defaultValue: '0').toString()) ?? 0;

  String get motorName =>
      motorBox.get('nama', defaultValue: 'Motor Saya').toString();

  String get motorSubtitle {
    if (lastOilChangeDate != null) {
      return 'Terakhir ganti oli ${_formatDate(lastOilChangeDate!)}';
    }
    return 'Tambahkan riwayat ganti oli untuk rekomendasi lebih akurat';
  }

  int get kmSinceLastChange {
    final last = lastOilChangeKm ?? 0;
    final diff = km - last;
    return diff < 0 ? 0 : diff;
  }

  int get remainingKm {
    final next = _getNextThreshold();
    final remain = next - kmSinceLastChange;
    return remain < 0 ? 0 : remain;
  }

  String get status {
    final useKm = kmSinceLastChange;
    if (useKm < 3000) return "AMAN";
    if (useKm < 5000) return "HAMPIR GANTI";
    return "WAJIB GANTI";
  }

  @override
  Widget build(BuildContext context) {
    _scheduleReminderCheck();
    final c = statusColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B1A),
        elevation: 0,
        title: const Text(
          "MotoCare",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: _showNotificationsSheet,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacityValue(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.orange),
                ),
                tooltip: 'Notifikasi',
              ),
              if (_getNotificationCount() > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      '${_getNotificationCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          IconButton(
            onPressed: _showResetOdometerDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacityValue(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restart_alt, color: Colors.yellow),
            ),
            tooltip: 'Reset Odometer',
          ),

          IconButton(
            onPressed: _showLogoutDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacityValue(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.redAccent),
            ),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeroCard(c),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // 🔥 STATUS CARD - ENHANCED
            AnimatedBuilder(
              animation: Listenable.merge([controller, pulseAnimation]),
              builder: (context, _) {
                return Transform.scale(
                  scale: pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F1630),
                          Color(0xFF1A2847),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: c.withOpacityValue(controller.value * 0.8),
                          blurRadius: 35,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: c.withOpacityValue(0.2),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                      border: Border.all(
                        color: c.withOpacityValue(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Icon dengan animasi
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [c.withOpacityValue(0.3), c.withOpacityValue(0.1)],
                            ),
                          ),
                          child: Icon(Icons.two_wheeler, size: 60, color: c),
                        ),
                        const SizedBox(height: 16),

                        // Status Text
                        Text(
                          status,
                          style: TextStyle(
                            color: c,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // KM Information
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacityValue(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$km KM",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sejak ganti: $kmSinceLastChange KM',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Status Description
                        Text(
                          _getStatusDescription(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // 📊 PROGRESS CARD - ENHANCED
            _buildGradientSectionCard(
              accentColor: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.speed,
                    "PROGRES PEMAKAIAN OLI",
                    Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 145,
                        height: 145,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 14,
                              backgroundColor: Colors.white.withOpacityValue(0.08),
                              color: Colors.orange,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Digunakan',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sisa $remainingKm KM',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Target berikutnya: ${_getNextThreshold()} KM',
                              style: const TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacityValue(0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KM sejak ganti: $kmSinceLastChange KM',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: $status',
                                    style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ⏰ REMINDER CARD
            _buildGradientSectionCard(
              accentColor: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.notifications_active,
                    "REMINDER GANTI OLI",
                    Colors.green,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getReminderMessage(),
                    style: TextStyle(
                      color: _getReminderColor().withOpacityValue(0.95),
                      fontSize: 13,
                    ),
                  ),
                  if (lastOilChangeKm != null && lastOilChangeDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Terakhir ganti oli: $lastOilChangeKm KM • ${_formatDate(lastOilChangeDate!)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Batas berikutnya",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_getNextThreshold()} KM",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _toggleReminder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: reminderEnabled ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          reminderEnabled ? 'Matikan Reminder' : 'Aktifkan Reminder',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Batas berikutnya: ${_getNextThreshold()} KM',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _showThresholdDialog,
                        child: const Text(
                          'Ubah Batas',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _markOilChanged,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sudah Ganti Oli',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 📈 CHART CARD - ENHANCED
            _buildGradientSectionCard(
              accentColor: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan icon
                  _buildSectionHeader(
                    Icons.trending_up,
                    "RIWAYAT PEMAKAIAN OLI",
                    Colors.blue,
                  ),

                  const SizedBox(height: 24),

                  // Chart
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacityValue(0.05),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),

                        lineBarsData: [
                          LineChartBarData(
                            spots: getChartData(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.orange,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.orange.withOpacityValue(0.2),
                              cutOffY: 0,
                              applyCutOffY: true,
                            ),
                          ),
                        ],

                        lineTouchData: const LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacityValue(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Total Data", "${historyBox.length}"),
                        _buildStatItem("Rata-rata", "${_getAverageKm().toStringAsFixed(0)} KM"),
                        _buildStatItem("Maksimal", "${_getMaxKm()} KM"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 💡 INFO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacityValue(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacityValue(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacityValue(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getMaintenanceTip(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🔔 NOTIFICATION SECTION
            _buildGradientSectionCard(
              accentColor: Colors.purple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan icon
                  _buildSectionHeader(
                    Icons.notifications_active,
                    "NOTIFIKASI",
                    Colors.purple,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacityValue(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_getNotificationCount()}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notification Items
                  ..._buildNotifications(),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 📋 HISTORY SECTION
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F1630),
                    Color(0xFF1A2847),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacityValue(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.cyan.withOpacityValue(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan icon
                  _buildSectionHeader(
                    Icons.history,
                    "RIWAYAT PEMAKAIAN",
                    Colors.cyan,
                    trailing: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacityValue(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${historyBox.length}",
                              style: const TextStyle(
                                color: Colors.cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.open_in_new, size: 14, color: Colors.cyan),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // History Items
                  if (historyBox.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 40,
                              color: Colors.white30,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Belum ada riwayat",
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ..._buildHistoryItems(),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F1630),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.red.withOpacityValue(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacityValue(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Logout?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Apakah Anda yakin ingin keluar dari aplikasi?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacityValue(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Ya, Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() {
    try {
      // Clear user session/data if needed
      motorBox.delete('userId');
      
      // Navigate to login page
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle any errors
      Navigator.of(context).pop();
    }
  }

  void _showResetOdometerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1630),
          title: const Text('Reset Odometer', style: TextStyle(color: Colors.white)),
          content: const Text('Apakah Anda yakin ingin mereset odometer ke 0 KM?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetOdometer();
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _resetOdometer() {
    motorBox.put('km', 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Odometer direset ke 0 KM'), duration: Duration(seconds: 2)),
    );
    setState(() {});
  }

  List<Map<String, Object>> _notificationsData() {
    final items = <Map<String, Object>>[];
    final threshold = _getNextThreshold();
    final since = kmSinceLastChange;

    if (lastOilChangeKm == null) {
      items.add({
        'icon': Icons.info,
        'title': 'Riwayat belum lengkap',
        'message': 'Masukkan catatan ganti oli pertama agar reminder bekerja maksimal.',
        'time': 'Baru saja',
        'color': Colors.orange,
      });
    } else {
      if (!reminderEnabled) {
        items.add({
          'icon': Icons.notifications_off,
          'title': 'Reminder dimatikan',
          'message': 'Aktifkan reminder untuk mendapat notifikasi ganti oli sebelum batas.',
          'time': 'Baru saja',
          'color': Colors.white54,
        });
      } else if (km < threshold - 500) {
        items.add({
          'icon': Icons.notifications_active,
          'title': 'Reminder aktif',
          'message': 'Masih aman hingga $threshold KM. Sejak ganti: $since KM.',
          'time': 'Baru saja',
          'color': Colors.green,
        });
      } else if (km < threshold) {
        items.add({
          'icon': Icons.warning_amber,
          'title': 'KM mendekati batas',
          'message': 'Sisa kurang dari 500 KM menuju $threshold KM. Siapkan ganti oli.',
          'time': 'Baru saja',
          'color': Colors.orange,
        });
      } else {
        items.add({
          'icon': Icons.error,
          'title': 'Sudah melewati batas',
          'message': 'KM Anda sudah melewati $threshold KM. Segera ganti oli sekarang.',
          'time': 'Baru saja',
          'color': Colors.red,
        });
      }

      if (historyBox.values.isNotEmpty) {
        final lastEntry = historyBox.values
            .whereType<Map>()
            .where((item) => item['type'] == 'oil_change')
            .toList()
            .cast<Map<String, Object?>>();
        if (lastEntry.isNotEmpty) {
          final latest = lastEntry.last;
          final message = 'Terakhir ganti oli ${latest['km']} KM.';
          items.add({
            'icon': Icons.check_circle,
            'title': 'Riwayat terakhir',
            'message': message,
            'time': 'Riwayat',
            'color': Colors.blue,
          });
        }
      }
    }

    return items;
  }

  int _getNotificationCount() {
    return _notificationsData().length;
  }

  Future<void> _showUpdateKmDialog() async {
    final controller = TextEditingController(text: km.toString());
    String? errorText;

    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F1630),
              title: const Text(
                'Perbarui Odometer',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'KM saat ini',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF171F39),
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final value = int.tryParse(controller.text.trim());
                    if (value == null || value < 0) {
                      setState(() {
                        errorText = 'Masukkan angka KM yang valid';
                      });
                      return;
                    }
                    Navigator.of(context).pop(value);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (selected != null) {
      motorBox.put('km', selected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Odometer diperbarui ke $selected KM'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {});
    }
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1630),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final items = _notificationsData();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${items.length} baru',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: items.map((notif) {
                      final color = notif['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacityValue(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacityValue(0.15), width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacityValue(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  notif['icon'] as IconData,
                                  color: color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif['message'] as String,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                notif['time'] as String,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildNotifications() {
    final notifications = _notificationsData();

    return notifications.map((notif) {
      final color = notif['color'] as Color;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacityValue(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacityValue(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacityValue(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notif['icon'] as IconData,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif['message'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                notif['time'] as String,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildHistoryItems() {
    final entries = historyBox.toMap().entries.toList().reversed.toList();
    final displayEntries = entries.take(5).toList();

    return displayEntries.map((entry) {
      final key = entry.key;
      final item = entry.value;

      int kmValue = 0;
      String date = '';
      String note = '';

      if (item is Map) {
        kmValue = int.tryParse(item['km'].toString()) ?? 0;
        date = item['date']?.toString() ?? 'Tanpa tanggal';
        note = item['note']?.toString() ?? '';
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: InkWell(
          onTap: () async {
            await showHistoryEntryDialog(context, historyBox: historyBox, existing: item as Map?, key: key);
            setState(() {});
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111A2D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan.withOpacityValue(0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacityValue(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacityValue(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$kmValue',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$kmValue KM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          note,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF0F1630),
                        title: const Text('Hapus riwayat?', style: TextStyle(color: Colors.white)),
                        content: const Text('Yakin ingin menghapus entry ini?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await historyBox.delete(key);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildHeroCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withOpacityValue(0.25), const Color(0xFF0F1630)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacityValue(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: accentColor.withOpacityValue(0.2), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacityValue(0.02),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.motorcycle, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hai, $motorName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      motorSubtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacityValue(0.24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo('Odometer', '$km KM', Colors.white),
              _buildMiniInfo('Sejak ganti', '$kmSinceLastChange KM', Colors.white70),
              _buildMiniInfo('Sisa', '$remainingKm KM', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color.withOpacityValue(0.7), fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.add_road,
            label: 'Tambah Riwayat',
            color: Colors.deepPurple,
            onTap: () async {
              await showHistoryEntryDialog(context, historyBox: historyBox);
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            icon: Icons.tune,
            label: 'Ubah Batas',
            color: Colors.blueAccent,
            onTap: _showThresholdDialog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            icon: Icons.speed,
            label: 'Perbarui KM',
            color: Colors.green,
            onTap: _showUpdateKmDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacityValue(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacityValue(0.18), width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacityValue(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Cepat & mudah',
              style: TextStyle(color: Colors.white.withOpacityValue(0.7), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    Color iconColor,
    {
      Widget? trailing,
    }
  ) {
    return Row(
      mainAxisAlignment:
          trailing != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacityValue(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildGradientSectionCard({
    required Widget child,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1630),
            Color(0xFF1A2847),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacityValue(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacityValue(0.2),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  String _getStatusDescription() {
    final useKm = kmSinceLastChange;
    if (useKm < 3000) {
      return "Kondisi oli masih sangat baik";
    } else if (useKm < 5000) {
      return "Segera siapkan oli baru";
    } else {
      return "GANTI OLI SEKARANG JUGA!";
    }
  }

  int _getNextThreshold() {
    final val = motorBox.get('nextOilChangeThreshold', defaultValue: _defaultOilChangeThreshold());
    return int.tryParse(val.toString()) ?? _defaultOilChangeThreshold();
  }

  String? get lastOilChangeDate {
    return motorBox.get('lastOilChangeDate')?.toString();
  }

  int? get lastOilChangeKm {
    final value = motorBox.get('lastOilChangeKm');
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  int get nextOilChangeThreshold {
    final val = motorBox.get('nextOilChangeThreshold', defaultValue: _defaultOilChangeThreshold());
    return int.tryParse(val.toString()) ?? _defaultOilChangeThreshold();
  }

  int _defaultOilChangeThreshold() {
    final useKm = kmSinceLastChange;
    if (useKm < 3000) return 3000;
    if (useKm < 5000) return 5000;
    return 6000;
  }

  bool get reminderEnabled {
    return motorBox.get('reminderEnabled', defaultValue: false) as bool;
  }

  int? get lastReminderNotificationKm {
    final value = motorBox.get('lastReminderNotificationKm');
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  void _scheduleReminderCheck() {
    if (_reminderCheckScheduled) return;
    _reminderCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reminderCheckScheduled = false;
      _checkAndNotifyReminder();
    });
  }

  void _checkAndNotifyReminder() {
    if (!reminderEnabled) return;

    final threshold = _getNextThreshold();
    final notifyKm = threshold - 500;
    if (km < notifyKm) return;

    final lastNotifiedKm = lastReminderNotificationKm ?? -1;
    if (lastNotifiedKm >= km) return;

    NotificationService.showReminder();
    motorBox.put('lastReminderNotificationKm', km);
  }

  void _toggleReminder() {
    final enabled = !reminderEnabled;
    motorBox.put('reminderEnabled', enabled);
    final message = enabled ? 'Reminder diaktifkan' : 'Reminder dimatikan';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
    if (enabled) {
      _scheduleReminderCheck();
    }
  }

  void _markOilChanged() {
    final now = DateTime.now();
    motorBox.put('lastOilChangeDate', now.toIso8601String());
    motorBox.put('lastOilChangeKm', km);
    motorBox.put('reminderEnabled', false);
    // Setelah ganti oli, atur batas ganti oli berikutnya relatif terhadap KM sekarang
    motorBox.put('nextOilChangeThreshold', km + _defaultOilChangeThreshold());

    // Tambahkan entry riwayat untuk pencatatan ganti oli
    try {
      historyBox.add({
        'km': km,
        'date': now.toIso8601String(),
        'type': 'oil_change',
      });
    } catch (e) {
      // ignore: avoid_print
      print('Gagal menambahkan riwayat ganti oli: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catatan ganti oli tersimpan: ${DateFormat('dd MMM yyyy').format(now)} pada $km KM'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  String _getReminderMessage() {
    if (!reminderEnabled) {
      if (lastOilChangeDate != null && lastOilChangeKm != null) {
        return 'Terakhir ganti oli: ${_formatDate(lastOilChangeDate!)} pada $lastOilChangeKm KM. Aktifkan reminder jika ingin diberi tahu lagi.';
      }
      if (lastOilChangeDate != null) {
        return 'Terakhir ganti oli: ${_formatDate(lastOilChangeDate!)}. Aktifkan reminder jika ingin diberi tahu lagi.';
      }
      return 'Reminder ganti oli belum aktif. Aktifkan agar Anda mendapatkan pengingat sebelum batas ganti.';
    }

    final threshold = _getNextThreshold();
    final since = kmSinceLastChange;
    if (km < threshold - 500) {
      return 'Reminder aktif. Anda masih aman hingga $threshold KM (Sejak ganti: $since KM).';
    }
    if (km < threshold) {
      return 'Perhatian! KM Anda sudah mendekati $threshold KM (Sejak ganti: $since KM). Persiapkan ganti oli.';
    }
    return 'Oli sudah melewati batas $threshold KM (Sejak ganti: $since KM). Segera ganti oli sekarang!';
  }

  Color _getReminderColor() {
    if (!reminderEnabled) return Colors.white54;
    final threshold = _getNextThreshold();
    if (km < threshold - 500) return Colors.green;
    if (km < threshold) return Colors.orange;
    return Colors.red;
  }

  double _getAverageKm() {
    final list = historyBox.values.toList();
    if (list.isEmpty) return 0;
    
    double total = 0;
    for (var item in list) {
      if (item is Map) {
        total += double.tryParse(item['km'].toString()) ?? 0;
      }
    }
    return total / list.length;
  }

  int _getMaxKm() {
    final list = historyBox.values.toList();
    if (list.isEmpty) return 0;
    
    int max = 0;
    for (var item in list) {
      if (item is Map) {
        int value = int.tryParse(item['km'].toString()) ?? 0;
        if (value > max) max = value;
      }
    }
    return max;
  }

  void _setNextOilChangeThreshold(int threshold) {
    motorBox.put('nextOilChangeThreshold', threshold);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Batas ganti oli berikutnya diatur ke $threshold KM'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  Future<void> _showThresholdDialog() async {
    final controller = TextEditingController(text: _getNextThreshold().toString());
    String? errorText;

    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F1630),
              title: const Text(
                'Ubah batas ganti oli',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Masukkan batas KM',
                      labelStyle: const TextStyle(color: Colors.white70),
                      errorText: errorText,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final input = controller.text.trim();
                    final value = int.tryParse(input);
                    if (value == null || value <= 0) {
                      setState(() {
                        errorText = 'Masukkan angka valid di atas 0';
                      });
                      return;
                    }
                    Navigator.pop(context, value);
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      _setNextOilChangeThreshold(selected);
    }
  }

  String _getMaintenanceTip() {
    final useKm = kmSinceLastChange;
    if (useKm < 3000) {
      return "✓ Oli Anda dalam kondisi prima. Lanjutkan perawatan berkala!";
    } else if (useKm < 5000) {
      return "⚠ Siapkan oli pengganti dan rencanakan pergantian dalam waktu dekat!";
    } else {
      return "🚨 Oli sudah melampaui batas! Ganti segera untuk performa optimal!";
    }
  }

  Color get statusColor {
    final s = status;
    if (s == "AMAN") return Colors.green;
    if (s == "HAMPIR GANTI") return Colors.orange;
    return Colors.red;
  }

  double get progress {
    final threshold = _getNextThreshold();
    final useKm = kmSinceLastChange;
    final denom = threshold <= 0 ? 1 : threshold;
    double p = useKm / denom;
    if (p < 0) p = 0;
    if (p > 1) p = 1;
    return p;
  }

  List<FlSpot> getChartData() {
    final entries = historyBox.values.toList();
    if (entries.isEmpty) return [];
    final values = entries.map((item) {
      if (item is Map && item['km'] != null) {
        return double.tryParse(item['km'].toString()) ?? 0.0;
      }
      return double.tryParse(item.toString()) ?? 0.0;
    }).toList();

    return List<FlSpot>.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  }
}
