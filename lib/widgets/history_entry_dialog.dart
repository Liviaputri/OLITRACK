import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Future<void> showHistoryEntryDialog(BuildContext context,
    {required Box historyBox, Map? existing, dynamic key}) async {
  final kmController = TextEditingController(text: existing?['km']?.toString() ?? '');
  final oliController = TextEditingController(text: existing?['oli']?.toString() ?? '');
  final intervalKmController = TextEditingController(text: existing?['intervalKm']?.toString() ?? '5000');
  final intervalBulanController = TextEditingController(text: existing?['intervalBulan']?.toString() ?? '3');
  final costController = TextEditingController(text: existing?['cost']?.toString() ?? '');
  final placeController = TextEditingController(text: existing?['place']?.toString() ?? '');
  final notesController = TextEditingController(text: existing?['notes']?.toString() ?? '');
  DateTime selected = DateTime.tryParse(existing?['date']?.toString() ?? '') ?? DateTime.now();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1630),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existing == null ? 'Tambah Riwayat Ganti Oli' : 'Edit Riwayat Ganti Oli',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tanggal
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tanggal: ${selected.toLocal().toIso8601String().split('T').first}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selected,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selected = picked);
                        }
                      },
                      child: const Text('Ubah', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // KM
                TextField(
                  controller: kmController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'KM saat ganti',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.speed, color: Colors.orange, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // Jenis Oli
                TextField(
                  controller: oliController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Jenis oli (contoh: Castrol 10W-40)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.local_gas_station, color: Colors.orange, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // Interval KM
                TextField(
                  controller: intervalKmController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Interval KM (contoh: 5000)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.timeline, color: Colors.blue, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // Interval Bulan
                TextField(
                  controller: intervalBulanController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Interval Bulan (contoh: 3)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // Biaya (opsional)
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Biaya (Rp) - opsional',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.attach_money, color: Colors.green, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // Tempat Ganti
                TextField(
                  controller: placeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tempat ganti (bengkel/toko) - opsional',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // Catatan
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Catatan tambahan - opsional',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.notes, color: Colors.purple, size: 20),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6B9A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final kmText = kmController.text.trim();
                if (kmText.isEmpty) return;
                
                final entry = {
                  'date': selected.toIso8601String(),
                  'km': int.tryParse(kmText) ?? 0,
                  'oli': oliController.text.trim(),
                  'intervalKm': int.tryParse(intervalKmController.text.trim()) ?? 5000,
                  'intervalBulan': int.tryParse(intervalBulanController.text.trim()) ?? 3,
                  'cost': int.tryParse(costController.text.trim()),
                  'place': placeController.text.trim().isEmpty ? null : placeController.text.trim(),
                  'notes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                };

                final navigator = Navigator.of(context);
                if (existing != null && key != null) {
                  await historyBox.put(key, entry);
                } else {
                  await historyBox.add(entry);
                }

                if (context.mounted) {
                  navigator.pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      });
    },
  );
}
