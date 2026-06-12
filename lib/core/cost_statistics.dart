import 'package:intl/intl.dart';

class CostStatistics {
  static int getTotalCost(List<Map<String, dynamic>> items) {
    int total = 0;
    for (var item in items) {
      final cost = item['cost'];
      if (cost != null) {
        total += int.tryParse(cost.toString()) ?? 0;
      }
    }
    return total;
  }

  static int getAverageCost(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 0;
    return (getTotalCost(items) / items.length).round();
  }

  static int getLastCost(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 0;
    final lastItem = items.isNotEmpty ? items.first : null;
    if (lastItem == null) return 0;
    final cost = lastItem['cost'];
    if (cost != null) {
      return int.tryParse(cost.toString()) ?? 0;
    }
    return 0;
  }

  static String formatCurrency(int value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static int getCountByOil(List<Map<String, dynamic>> items, String oilType) {
    return items.where((item) => item['oli'] == oilType).length;
  }

  static String getMostUsedOil(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return '-';
    final oilMap = <String, int>{};
    for (var item in items) {
      final oil = item['oli']?.toString() ?? 'Unknown';
      oilMap[oil] = (oilMap[oil] ?? 0) + 1;
    }
    var mostUsed = 'Unknown';
    var maxCount = 0;
    oilMap.forEach((oil, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = oil;
      }
    });
    return mostUsed;
  }

  static double getAverageInterval(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 0;
    int totalKm = 0;
    for (int i = 0; i < items.length - 1; i++) {
      final kmCurrent = int.tryParse(items[i]['km'].toString()) ?? 0;
      final kmNext = int.tryParse(items[i + 1]['km'].toString()) ?? 0;
      totalKm += (kmCurrent - kmNext).abs();
    }
    return (totalKm / (items.length - 1)).round().toDouble();
  }
}
