import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../core/color_extensions.dart';
import '../core/cost_statistics.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final historyBox = Hive.box('history');

  @override
  Widget build(BuildContext context) {
    final items = historyBox.values.cast<Map<String, dynamic>>().toList();
    items.sort((a, b) {
      try {
        final da = DateTime.parse(a['date'] ?? '');
        final db = DateTime.parse(b['date'] ?? '');
        return db.compareTo(da);
      } catch (_) {
        return 0;
      }
    });

    final totalCost = CostStatistics.getTotalCost(items);
    final averageCost = CostStatistics.getAverageCost(items);
    final lastCost = CostStatistics.getLastCost(items);
    final mostUsedOil = CostStatistics.getMostUsedOil(items);
    final averageInterval = CostStatistics.getAverageInterval(items);

    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B1A),
        elevation: 0,
        title: const Text(
          'Statistik & Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data statistik',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // COST SUMMARY
                  _buildCostSummaryCard(totalCost, averageCost, lastCost),
                  const SizedBox(height: 20),

                  // OIL & INTERVAL INFO
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Oli Terbanyak Digunakan',
                          mostUsedOil,
                          Icons.local_gas_station,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Rata-rata Interval',
                          '${averageInterval.toInt()} KM',
                          Icons.timeline,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TOTAL CHANGES
                  _buildInfoCard(
                    'Total Penggantian Oli',
                    '${items.length}x',
                    Icons.history,
                    Colors.green,
                  ),
                  const SizedBox(height: 20),

                  // HISTORY BY OIL TYPE
                  _buildHistoryByOilType(items),
                  const SizedBox(height: 20),

                  // RECENT CHANGES
                  _buildRecentChanges(items),
                ],
              ),
            ),
    );
  }

  Widget _buildCostSummaryCard(int total, int average, int last) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1630),
            Color(0xFF1A2847),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              const Text(
                'RINGKASAN BIAYA',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Biaya',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CostStatistics.formatCurrency(total),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 60, color: Colors.white12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Rata-rata per Ganti',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CostStatistics.formatCurrency(average),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 60, color: Colors.white12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Ganti Terakhir',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CostStatistics.formatCurrency(last),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1630),
            Color(0xFF1A2847),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryByOilType(List<Map<String, dynamic>> items) {
    final oilMap = <String, int>{};
    for (var item in items) {
      final oil = item['oli']?.toString() ?? 'Unknown';
      oilMap[oil] = (oilMap[oil] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1630),
            Color(0xFF1A2847),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_gas_station, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Penggunaan Per Jenis Oli',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...oilMap.entries.map((e) {
            final percentage = (e.value / items.length * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${e.value}x ($percentage%)',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / items.length,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(Colors.orange.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentChanges(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1630),
            Color(0xFF1A2847),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Penggantian Terakhir',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(5).map((item) {
            final date = DateTime.tryParse(item['date'] ?? '');
            final dateStr = date != null ? DateFormat('dd MMM yyyy').format(date) : 'N/A';
            const textStyle = TextStyle(color: Colors.white70, fontSize: 12);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: textStyle,
                        ),
                        if ((item['oli']?.toString() ?? '').isNotEmpty)
                          Text(
                            item['oli'] ?? '-',
                            style: const TextStyle(color: Colors.orange, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${item['km']} KM',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (items.length > 5) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'dan ${items.length - 5} penggantian lainnya',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
