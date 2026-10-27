import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutSignBridgeScreen extends StatelessWidget {
  const AboutSignBridgeScreen({super.key});

  static const Color primaryColor = Color(0xFF1E2158);
  static const Color accentColor = Color(0xFF4B6CF7);
  static const String supportEmail = 'signbridgeog@gmail.com';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121424) : const Color(0xFFF5F7FF);
    final cardColor = isDark ? const Color(0xFF1E2138) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2158);
    final subtextColor = isDark ? Colors.white70 : Colors.black87;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181B30) : primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'About SignBridge',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Hero App Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2158), const Color(0xFF2C326E)]
                      : [const Color(0xFF1E2158), const Color(0xFF4B6CF7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(
                      Icons.sign_language_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SignBridge',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Breaking Communication Barriers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Indian Sign Language (ISL) · AI Platform',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Short Description / Overview
            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: accentColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Project Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SignBridge is a real-time assistive communication system designed to empower the Deaf and Hard-of-Hearing community. By uniting high-speed computer vision, 3D deep neural networks, and generative AI grammar reconstruction, SignBridge translates Indian Sign Language into clear, natural spoken language instantly.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Key Highlights
            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, color: const Color(0xFFBA7517), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Key Capabilities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureRow(
                    icon: Icons.camera_alt_rounded,
                    title: 'Real-Time Camera Translation',
                    desc: 'Instant streaming detection of 76 ISL signs via MediaPipe 3D landmarks and Swin3D model.',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  Divider(color: borderColor, height: 20),
                  _buildFeatureRow(
                    icon: Icons.spellcheck_rounded,
                    title: 'AI Grammar Decoding',
                    desc: 'Converts raw sign glosses into fluid, grammatically coherent natural sentences.',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  Divider(color: borderColor, height: 20),
                  _buildFeatureRow(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Voice Feedback (TTS)',
                    desc: 'Spoken audio output enables seamless, hands-free interaction with hearing individuals.',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  Divider(color: borderColor, height: 20),
                  _buildFeatureRow(
                    icon: Icons.menu_book_rounded,
                    title: '76 ISL Sign Vocabulary',
                    desc: 'Interactive dictionary featuring Core 50 essentials, categories, and camera practice.',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mission Statement
            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Our Mission',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'To bridge silent divides and foster inclusive environments in healthcare, education, workplaces, and daily life through accessible, modern technology.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contact & Support
            _buildCard(
              cardColor: cardColor,
              borderColor: borderColor,
              isDark: isDark,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF272B45) : const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mail_outline_rounded, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Questions or Feedback?',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          supportEmail,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: accentColor,
                    tooltip: 'Copy support email',
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: supportEmail));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support email copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF272B45) : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(fontSize: 12, color: subtextColor, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
