import 'package:flutter/material.dart';
import '../core/color_extensions.dart';
import 'package:hive/hive.dart';

class MotorFormPage extends StatefulWidget {
  const MotorFormPage({super.key});

  @override
  State<MotorFormPage> createState() => _MotorFormPageState();
}

class _MotorFormPageState extends State<MotorFormPage> {
  final box = Hive.box('motor');

  final nama = TextEditingController();
  final merk = TextEditingController();
  final km = TextEditingController();
  final oli = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacityValue(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacityValue(0.4),
                  blurRadius: 20,
                )
              ],
            ),

            child: Column(
              children: [

                const Icon(
                  Icons.motorcycle,
                  size: 70,
                  color: Colors.orange,
                ),

                const SizedBox(height: 10),

                const Text(
                  "DATA MOTOR",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                _input(nama, "Nama Motor"),
                const SizedBox(height: 12),

                _input(merk, "Merk Motor"),
                const SizedBox(height: 12),

                _input(km, "Kilometer", number: true),
                const SizedBox(height: 12),

                _input(oli, "Jenis Oli"),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      box.put('nama', nama.text);
                      box.put('merk', merk.text);
                      box.put('km', int.tryParse(km.text) ?? 0);
                      box.put('oli', oli.text);

                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text(
                      "SIMPAN & LANJUT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, {bool number = false}) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}