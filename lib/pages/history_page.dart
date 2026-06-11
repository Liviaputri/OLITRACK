import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../core/color_extensions.dart';
import '../widgets/history_entry_dialog.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final historyBox = Hive.box('history');

  DateTime? _from;
  DateTime? _to;
  String _query = '';

  List<Map> get _items {
    final raw = historyBox.values.toList();
    final list = raw.whereType<Map>().map((e) => e).toList();

    Iterable<Map> filtered = list;

    if (_from != null) {
      filtered = filtered.where((m) {
        try {
          final d = DateTime.parse(m['date'] ?? '');
          return !d.isBefore(_from!);
        } catch (_) {
          return false;
        }
      });
    }

    if (_to != null) {
      filtered = filtered.where((m) {
        try {
          final d = DateTime.parse(m['date'] ?? '');
          return !d.isAfter(_to!);
        } catch (_) {
          return false;
        }
      });
    }

    if (_query.isNotEmpty) {
      filtered = filtered.where((m) {
        final km = m['km']?.toString() ?? '';
        final note = m['note']?.toString() ?? '';
        return km.contains(_query) || note.toLowerCase().contains(_query.toLowerCase());
      });
    }

    final sorted = filtered.toList()
      ..sort((a, b) {
        try {
          final da = DateTime.parse(a['date'] ?? '');
          final db = DateTime.parse(b['date'] ?? '');
          return db.compareTo(da);
        } catch (_) {
          return 0;
        }
      });

    return sorted.cast<Map>();
  }

  String _format(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(d);
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<void> _exportCSV() async {
    final items = _items;
    final rows = <List<String>>[];
    rows.add(['date', 'km', 'note']);
    for (var m in items) {
      rows.add([m['date']?.toString() ?? '', m['km']?.toString() ?? '', m['note']?.toString() ?? '']);
    }

    final csv = rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join('\n');

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('CSV Export (copy)'),
        content: SingleChildScrollView(child: SelectableText(csv)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _to = picked);
  }

  dynamic _findKeyFor(Map m) {
    for (var k in historyBox.keys) {
      final v = historyBox.get(k);
      if (v is Map && mapEquals(v, m)) return k;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemakaian'),
        actions: [
          IconButton(onPressed: _exportCSV, icon: const Icon(Icons.download)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showHistoryEntryDialog(context, historyBox: historyBox);
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari km atau catatan',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0F1630),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacityValue(0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacityValue(0.12)),
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6B9A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _pickFrom,
                  child: const Text('Dari'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6B9A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _pickTo,
                  child: const Text('Sampai'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_from != null || _to != null)
              Row(
                children: [
                  if (_from != null) Text('Dari: ${DateFormat('dd MMM yyyy').format(_from!)}'),
                  const SizedBox(width: 12),
                  if (_to != null) Text('Sampai: ${DateFormat('dd MMM yyyy').format(_to!)}'),
                  const Spacer(),
                  TextButton(onPressed: () => setState(() { _from = null; _to = null; }), child: const Text('Reset')),
                ],
              ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Tidak ada data', style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final m = _items[index];
                        final note = m['note']?.toString() ?? '';
                        final itemDate = _format(m['date'] ?? '');
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF111A2D),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            tileColor: const Color(0xFF111A2D),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFF0F6B9A),
                              child: Text(
                                m['km'].toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            title: Text(
                              itemDate,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  '${m['km']} KM',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(note, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                ],
                              ],
                            ),
                            onTap: () async {
                              final key = _findKeyFor(m);
                              await showHistoryEntryDialog(context, historyBox: historyBox, existing: m, key: key);
                              setState(() {});
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: const Color(0xFF0F1630),
                                    title: const Text('Hapus entry?', style: TextStyle(color: Colors.white)),
                                    content: const Text('Yakin ingin menghapus entry ini?', style: TextStyle(color: Colors.white70)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  final key = _findKeyFor(m);
                                  if (key != null) {
                                    await historyBox.delete(key);
                                    setState(() {});
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat dihapus'), duration: Duration(seconds: 2)));
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
