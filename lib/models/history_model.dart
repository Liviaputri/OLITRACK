class HistoryModel {
  String tanggal;
  String oli;
  int km;
  int intervalKm;
  int intervalBulan;
  int? cost; // Biaya ganti oli (opsional)
  String? place; // Tempat ganti oli (bengkel/toko)
  String? notes; // Catatan tambahan

  HistoryModel({
    required this.tanggal,
    required this.oli,
    required this.km,
    this.intervalKm = 5000,
    this.intervalBulan = 3,
    this.cost,
    this.place,
    this.notes,
  });
}

