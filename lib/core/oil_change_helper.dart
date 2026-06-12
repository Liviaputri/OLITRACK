import 'package:intl/intl.dart';

class OilChangeHelper {
  /// Menghitung berapa KM lagi sampai perlu ganti oli
  static int getRemainingKm(int currentKm, int lastOilChangeKm, int intervalKm) {
    final nextChangeKm = lastOilChangeKm + intervalKm;
    final remaining = nextChangeKm - currentKm;
    return remaining > 0 ? remaining : 0;
  }

  /// Menghitung berapa hari lagi sampai perlu ganti oli
  static int getRemainingDays(DateTime lastOilChangeDate, int intervalBulan) {
    final nextChangeDate = DateTime(
      lastOilChangeDate.year,
      lastOilChangeDate.month + intervalBulan,
      lastOilChangeDate.day,
    );
    final remaining = nextChangeDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Menghitung KM berikutnya untuk penggantian
  static int getNextChangeKm(int lastOilChangeKm, int intervalKm) {
    return lastOilChangeKm + intervalKm;
  }

  /// Menghitung tanggal berikutnya untuk penggantian
  static DateTime getNextChangeDate(DateTime lastOilChangeDate, int intervalBulan) {
    return DateTime(
      lastOilChangeDate.year,
      lastOilChangeDate.month + intervalBulan,
      lastOilChangeDate.day,
    );
  }

  /// Menentukan prioritas penggantian (KM atau Tanggal - mana yang tercapai duluan)
  static String getPriority(
    int currentKm,
    int lastOilChangeKm,
    int intervalKm,
    DateTime lastOilChangeDate,
    int intervalBulan,
  ) {
    final nextChangeKm = getNextChangeKm(lastOilChangeKm, intervalKm);
    final nextChangeDate = getNextChangeDate(lastOilChangeDate, intervalBulan);
    
    // Hitung sisa KM dan sisa hari
    final remainingKm = getRemainingKm(currentKm, lastOilChangeKm, intervalKm);
    final remainingDays = getRemainingDays(lastOilChangeDate, intervalBulan);
    
    // Jika salah satu sudah overdue
    if (remainingKm <= 0) return 'KM_OVERDUE';
    if (remainingDays <= 0) return 'DATE_OVERDUE';
    
    // Kedua belum tercapai, lihat mana yang lebih dekat
    // Asumsikan rata-rata jarak 50 KM per hari
    final estimatedDaysForKm = (remainingKm / 50).ceil();
    
    if (estimatedDaysForKm < remainingDays) {
      return 'KM';
    } else if (remainingDays < estimatedDaysForKm) {
      return 'DATE';
    } else {
      // Jika sama, prioritas KM
      return 'KM';
    }
  }

  /// Mendapatkan status penggantian oli
  static String getStatus(
    int currentKm,
    int lastOilChangeKm,
    int intervalKm,
    DateTime lastOilChangeDate,
    int intervalBulan,
  ) {
    final priority = getPriority(
      currentKm,
      lastOilChangeKm,
      intervalKm,
      lastOilChangeDate,
      intervalBulan,
    );

    if (priority == 'KM_OVERDUE' || priority == 'DATE_OVERDUE') {
      return 'GANTI OLI SEKARANG';
    }

    final nextChangeKm = getNextChangeKm(lastOilChangeKm, intervalKm);
    final nextChangeDate = getNextChangeDate(lastOilChangeDate, intervalBulan);
    final remainingKm = getRemainingKm(currentKm, lastOilChangeKm, intervalKm);
    final remainingDays = getRemainingDays(lastOilChangeDate, intervalBulan);

    // Estimasi rata-rata jarak 50 KM per hari
    final estimatedDaysForKm = (remainingKm / 50).ceil();

    if (priority == 'KM') {
      if (remainingKm <= 500) {
        return 'KM HAMPIR HABIS';
      } else if (remainingKm <= 1000) {
        return 'DALAM $remainingKm KM LAGI';
      } else {
        return 'AMAN';
      }
    } else {
      if (remainingDays <= 7) {
        return 'TANGGAL HAMPIR TIBA';
      } else if (remainingDays <= 14) {
        return 'DALAM $remainingDays HARI LAGI';
      } else {
        return 'AMAN';
      }
    }
  }

  /// Mendapatkan deskripsi lengkap untuk ditampilkan di UI
  static String getDetailedMessage(
    int currentKm,
    int lastOilChangeKm,
    int intervalKm,
    DateTime lastOilChangeDate,
    int intervalBulan,
  ) {
    final nextChangeKm = getNextChangeKm(lastOilChangeKm, intervalKm);
    final nextChangeDate = getNextChangeDate(lastOilChangeDate, intervalBulan);
    final remainingKm = getRemainingKm(currentKm, lastOilChangeKm, intervalKm);
    final remainingDays = getRemainingDays(lastOilChangeDate, intervalBulan);
    final priority = getPriority(
      currentKm,
      lastOilChangeKm,
      intervalKm,
      lastOilChangeDate,
      intervalBulan,
    );

    final dateFormat = DateFormat('dd MMM yyyy').format(nextChangeDate);

    if (priority == 'KM_OVERDUE') {
      return 'Oli sudah harus diganti (melewati $nextChangeKm KM). Ganti sekarang juga!';
    } else if (priority == 'DATE_OVERDUE') {
      return 'Oli sudah harus diganti (melewati tanggal $dateFormat). Ganti sekarang juga!';
    } else if (priority == 'KM') {
      return 'Ganti oli dalam $remainingKm KM (target: $nextChangeKm KM)\nAtau maksimal tgl $dateFormat';
    } else {
      return 'Ganti oli dalam $remainingDays hari (target: $dateFormat)\nAtau maksimal $nextChangeKm KM';
    }
  }

  /// Format tanggal ke string Indonesia
  static String formatDateId(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
