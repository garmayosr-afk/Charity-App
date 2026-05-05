import 'package:flutter/material.dart';
import '../../widgets/background.dart';

class AdressePage extends StatelessWidget {
  const AdressePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Locations",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "U Can Donate To The Following Locations",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0b0857),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Card(
                    elevation: 6,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildAddressTile(
                          title: "SOS Gammarth",
                          address: "W832+F2M, Farhat Hached St\nLa Marsa 9999",
                          icon: Icons.location_on,
                          color: const Color(0xFF009de0),
                        ),
                        const Divider(height: 32, thickness: 1),
                        _buildAddressTile(
                          title: "SOS Akouda",
                          address: "VHJF+PHX, Unnamed Road\nAkouda",
                          icon: Icons.location_on,
                          color: const Color(0xFF009de0),
                        ),
                        const Divider(height: 32, thickness: 1),
                        _buildAddressTile(
                          title: "SOS Mahres",
                          address: "Orphelinat، P1\nAl-Maharas 3060",
                          icon: Icons.location_on,
                          color: const Color(0xFF009de0),
                        ),
                        const Divider(height: 32, thickness: 1),
                        _buildAddressTile(
                          title: "SOS Seliana",
                          address: "39WC+4C5, C73\nSiliana",
                          icon: Icons.location_on,
                          color: const Color(0xFF009de0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTile({
    required String title,
    required String address,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), // Added a subtle background for the icon
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} // Don't forget this closing brace for the class!