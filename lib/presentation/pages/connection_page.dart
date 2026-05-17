import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_msg/data/datasources/chat_remote_data_source.dart';
import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/main.dart';
import 'package:my_msg/presentation/pages/chat_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final TextEditingController _ipController = TextEditingController(text: '100.');
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    final username = _usernameController.text.trim();

    if (ip.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena ambos campos')),
      );
      return;
    }

    // Guardar sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_ip', ip);
    await prefs.setString('saved_username', username);

    // Reconfiguramos el data source para usar la nueva IP
    final ds = sl<ChatRemoteDataSource>();
    ds.updateUrls(ip);
    ds.connect(username);

    // Ir directamente al chat global (sin pasar por la lista de salas)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chat: const Chat(id: 'global', name: 'MyMsg Chat'),
          currentUsername: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E14), Color(0xFF00B8D4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.forum, size: 60, color: Color(0xFF00E5FF)),
                      const SizedBox(height: 20),
                      const Text(
                        'MyMsg Connect',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E5FF),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _usernameController,
                        hint: 'Username (Ej: Laptop, Movil)',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _ipController,
                        hint: 'Tailscale IP (Ej: 100.x.x.x)',
                        icon: Icons.wifi,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 10,
                            shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                          ),
                          onPressed: _connect,
                          child: const Text(
                            'CONECTAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}
