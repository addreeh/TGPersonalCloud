import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFEFF4F9)
            : const Color(0xFF1E1E1E),
        title: const Text(
          "TGPersonalCloud",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF58ACFF),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFEFF4F9)
              : const Color(
                  0xFF0F0F0F), // Cambia el color de fondo según tu preferencia
        ),
        child: const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(),
        ),
      ),
    );
  }
}
