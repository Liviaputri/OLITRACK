import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Future<void> showHistoryEntryDialog(BuildContext context,
    {required Box historyBox, Map? existing, dynamic key}) async {
  final kmController = TextEditingController(text: existing?['km']?.toString() ?? '');
  final noteController = TextEditingController(text: existing?['note']?.toString() ?? '');
  DateTime selected = DateTime.tryParse(existing?['date']?.toString() ?? '') ?? DateTime.now();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1630),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existing == null ? 'Tambah Riwayat' : 'Edit Riwayat',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kmController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'KM',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF111A2D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tanggal: ${selected.toLocal().toIso8601String().split('T').first}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selected,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selected = picked);
                        }
                      },
                      child: const Text('Pilih'),
                    ),
                  ],
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
                  'note': noteController.text.trim(),
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
