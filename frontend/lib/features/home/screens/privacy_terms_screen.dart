import 'package:flutter/material.dart';

class PrivacyTermsScreen extends StatefulWidget {
  const PrivacyTermsScreen({super.key});

  static const Color primaryColor = Color(0xFF1E2158);
  static const Color accentColor = Color(0xFF4B6CF7);

  @override
  State<PrivacyTermsScreen> createState() => _PrivacyTermsScreenState();
}

class _PrivacyTermsScreenState extends State<PrivacyTermsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        backgroundColor: isDark ? const Color(0xFF181B30) : PrivacyTermsScreen.primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Privacy & Terms',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Terms of Service'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Privacy Tab
          _buildPrivacyContent(isDark, cardColor, textColor, subtextColor, borderColor),
          // Terms Tab
          _buildTermsContent(isDark, cardColor, textColor, subtextColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        _buildHeaderCard(
          icon: Icons.security_rounded,
          title: 'SignBridge Privacy Policy',
          subtitle: 'Your privacy and biometric data security are our highest priority.',
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildSectionCard(
          title: '1. Camera & Video Landmark Processing',
          icon: Icons.videocam_outlined,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'SignBridge uses your device camera solely for real-time sign language recognition. Video frames are converted in temporary volatile memory into MediaPipe hand and pose coordinates (3D landmarks). Raw video frames are processed in-flight and are never recorded, sold, or stored on external servers without your explicit permission.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '2. Translation Data & History',
          icon: Icons.history_edu_rounded,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'Recognized sign vocabulary and constructed sentences are stored locally or in your private account history so you can review and practice them. You have complete control to delete individual translation items or clear your entire history at any time.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '3. Text-to-Speech & Voice Feedback',
          icon: Icons.record_voice_over_outlined,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'When Voice Feedback is enabled, sentences are read aloud using on-device speech synthesis to communicate with hearing individuals. No voice recordings of your surroundings are captured or stored.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '4. AI Grammar Post-Processing',
          icon: Icons.auto_awesome_rounded,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'Raw Indian Sign Language glosses may be processed by our linguistic grammar decoder to form fluid, natural sentences. Only text tokens representing sign names are passed to grammar models—never camera video or user identity data.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '5. Data Rights & Support',
          icon: Icons.contact_support_outlined,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'You have the right to request deletion of your account and associated data at any time. For questions regarding your data privacy, contact our team at signbridgeog@gmail.com.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTermsContent(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        _buildHeaderCard(
          icon: Icons.gavel_rounded,
          title: 'SignBridge Terms of Service',
          subtitle: 'Guidelines and conditions for using the SignBridge assistive platform.',
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildSectionCard(
          title: '1. Purpose & Accessibility Mission',
          icon: Icons.accessibility_new_rounded,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'SignBridge is designed as an assistive communication and learning platform for Indian Sign Language (ISL). Its goal is to foster inclusive interaction between the Deaf and Hard-of-Hearing community and hearing individuals.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '2. AI Assistance Disclaimer',
          icon: Icons.info_outline_rounded,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'While SignBridge utilizes deep learning models (Swin3D-S and MediaPipe) trained on ISL gestures, sign language involves subtle facial expressions and regional variations. Predictions are AI-assisted aids and should not be solely relied upon for high-stakes medical, legal, or emergency translation.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '3. Acceptable Use',
          icon: Icons.verified_user_outlined,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'Users agree to use SignBridge responsibly for communication, translation, and education. You may not reverse-engineer, exploit, or attempt unauthorized access to the recognition servers or translation services.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '4. Service Updates & Changes',
          icon: Icons.update_rounded,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'SignBridge continually expands its vocabulary models and features. We reserve the right to improve or modify system capabilities to ensure optimal translation accuracy and security.',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '5. Contact & Inquiries',
          icon: Icons.mail_outline_rounded,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          borderColor: borderColor,
          content:
              'If you have inquiries, suggestions, or concerns regarding these terms, please contact us at signbridgeog@gmail.com.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeaderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2158) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFF4B6CF7).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4B6CF7).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4B6CF7), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E2158),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: PrivacyTermsScreen.accentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 13, height: 1.5, color: subtextColor),
          ),
        ],
      ),
    );
  }
}
