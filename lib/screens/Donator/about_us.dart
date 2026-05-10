import 'package:flutter/material.dart';
import '../../widgets/background.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.black87
          ),
        ),
        centerTitle: true,
      ),
      body: Background(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 100, // accommodate appbar
            left: 16,
            right: 16,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Our Mission',
                content:
                    "We care for children without parental care or children whose families are unable to care for them. We provide them with the opportunity to live in a normal family environment filled with familiarity and love, a stable environment in one of the SOS Children's Villages. Our approach is based on four basic principles: a mother, brothers and sisters, a home where they feel family warmth, and a supportive community that encourages their growth.",
                backgroundColor: const Color(0xFF0b0857), // Dark blue from image
                textColor: Colors.white,
                icon: Icons.favorite,
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Our Vision',
                subtitle: 'Vision 2030: Ensuring no child grows up alone',
                content:
                    "Our future vision goes beyond the boundaries of traditional children's villages. We are working by 2030 to address the root causes of the problem through family support programs to prevent family breakdown before it happens. We aspire to a cohesive Tunisian society that guarantees every child a safe environment, whether within their supported biological family, or through innovative forms of alternative care that are fully integrated into society.",
                backgroundColor: const Color(0xFF009de0), // Medium blue from image
                textColor: Colors.white,
                icon: Icons.visibility,
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Our Values',
                subtitle: 'Courage, Commitment, Trust, and Responsibility',
                content:
                    "Our values are the compass that guides our decisions. We have the courage to take bold steps in the best interest of the child, and we are committed to long-term engagement towards those we care for. We build our relationships on mutual trust, and act with the highest degree of administrative and financial responsibility and transparency before our partners and donors.",
                backgroundColor: const Color(0xFF28b6f6), // Light blue from image
                textColor: Colors.white,
                icon: Icons.handshake,
              ),
              const SizedBox(height: 24),
              const Text(
                'Our Impact',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0b0857),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem('43', 'Children Reintegrated\n(in 2025)'),
                  const SizedBox(width: 8),
                  _buildStatItem('50', 'Families &\nYouth Housing'),
                  const SizedBox(width: 8),
                  _buildStatItem('5500+', 'Education &\nTraining Enhanced'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required String content,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.95),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: textColor.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF009de0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}