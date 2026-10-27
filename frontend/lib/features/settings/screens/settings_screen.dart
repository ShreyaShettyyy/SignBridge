import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'profile_details_screen.dart';
import 'language_options_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const primaryColor = Color(0xFF1E2158);
  static const accentColor = Color(0xFF4B6CF7);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark || settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121424) : const Color(0xFFF5F7FF);
    final appBarColor = isDark ? const Color(0xFF181B30) : primaryColor;
    final headerColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _SectionHeader(title: 'PREFERENCES', color: headerColor),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Toggle dark appearance',
            isDark: isDark,
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (val) => settings.toggleDarkMode(val),
              activeThumbColor: accentColor,
            ),
          ),
          _SettingsTile(
            icon: Icons.record_voice_over_outlined,
            title: 'Voice Feedback',
            subtitle: 'Speak translations aloud',
            isDark: isDark,
            trailing: Switch(
              value: settings.voiceFeedback,
              onChanged: (val) => settings.toggleVoiceFeedback(val),
              activeThumbColor: accentColor,
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'ACCOUNT', color: headerColor),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Details',
            subtitle: 'Manage your account info',
            isDark: isDark,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileDetailsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language Options',
            subtitle: 'Choose SL variation (${settings.signLanguage})',
            isDark: isDark,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LanguageOptionsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1E2158);
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;
    final iconBoxBg = isDark ? const Color(0xFF1E2138) : Colors.white;
    final iconColor = isDark ? const Color(0xFF8BA5FF) : const Color(0xFF1E2158);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBoxBg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: subtitleColor),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.black26,
                )
              : null),
      onTap: onTap,
    );
  }
}
