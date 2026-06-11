import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final email = TextEditingController();
  final pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "REGISTER",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: email,
                decoration: const InputDecoration(
                  hintText: "Email",
                  filled: true,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  filled: true,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                    // 🔥 SIMULASI REGISTER BERHASIL
                    if (email.text.isNotEmpty && pass.text.isNotEmpty) {

                      // arahkan ke login (BIAR FLOW BENER)
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text("DAFTAR"),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Kembali ke Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}