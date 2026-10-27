import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class LanguageOptionsScreen extends StatelessWidget {
  const LanguageOptionsScreen({super.key});

  static const Color primaryColor = Color(0xFF1E2158);
  static const Color accentColor = Color(0xFF4B6CF7);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121424) : const Color(0xFFF5F7FF);
    final cardColor = isDark ? const Color(0xFF1E2138) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2158);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181B30) : primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Language Options',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionTitle('SIGN LANGUAGE VARIATION', isDark),
          const SizedBox(height: 12),
          _buildLanguageCard(
            title: 'Indian Sign Language (ISL)',
            subtitle: 'Standard Indian Sign Language vocabulary & gestures',
            badge: 'Primary Model',
            badgeColor: const Color(0xFF0F6E56),
            badgeBg: const Color(0xFFE6FAF3),
            isSelected: settings.signLanguage == 'ISL',
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            borderColor: borderColor,
            onTap: () => settings.setSignLanguage('ISL'),
          ),
          const SizedBox(height: 10),
          _buildLanguageCard(
            title: 'American Sign Language (ASL)',
            subtitle: 'North American finger-spelling & two-hand gestures',
            badge: 'Beta',
            badgeColor: const Color(0xFF8B5CF6),
            badgeBg: const Color(0xFFF3E8FF),
            isSelected: settings.signLanguage == 'ASL',
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            borderColor: borderColor,
            onTap: () => settings.setSignLanguage('ASL'),
          ),
          const SizedBox(height: 10),
          _buildLanguageCard(
            title: 'British Sign Language (BSL)',
            subtitle: 'Two-handed manual alphabet variation',
            badge: 'Coming Soon',
            badgeColor: Colors.orange.shade800,
            badgeBg: const Color(0xFFFFF4E5),
            isSelected: settings.signLanguage == 'BSL',
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            borderColor: borderColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('BSL dataset is currently in training. Using ISL as default.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          _buildSectionTitle('SPOKEN VOICE LANGUAGE (TTS)', isDark),
          const SizedBox(height: 12),
          _buildVoiceOptionCard(
            title: 'English (United States)',
            code: 'en-US',
            isSelected: settings.spokenLanguage == 'en-US',
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            borderColor: borderColor,
            onTap: () => settings.setSpokenLanguage('en-US'),
          ),
          const SizedBox(height: 10),
          _buildVoiceOptionCard(
            title: 'English (India)',
            code: 'en-IN',
            isSelected: settings.spokenLanguage == 'en-IN',
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            borderColor: borderColor,
            onTap: () => settings.setSpokenLanguage('en-IN'),
          ),
          const SizedBox(height: 10),
          _buildVoiceOptionCard(
            title: 'Hindi (India)',
            code: 'hi-IN',
            isSelected: settings.spokenLanguage == 'hi-IN',
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            borderColor: borderColor,
            onTap: () => settings.setSpokenLanguage('hi-IN'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white54 : Colors.black45,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required bool isSelected,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? accentColor : (isDark ? Colors.white38 : Colors.black26),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceOptionCard({
    required String title,
    required String code,
    required bool isSelected,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.volume_up_rounded,
              color: isSelected ? accentColor : (isDark ? Colors.white54 : Colors.black38),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: accentColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
