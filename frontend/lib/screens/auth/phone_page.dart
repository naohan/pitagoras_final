import 'package:flutter/material.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: const Center(
        child: Text('Pantalla de teléfono'),
      ),
    );
  }
}
