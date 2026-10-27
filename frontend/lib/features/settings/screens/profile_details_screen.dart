import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/forgot_password_screen.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  static const Color primaryColor = Color(0xFF1E2158);
  static const Color accentColor = Color(0xFF4B6CF7);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121424) : const Color(0xFFF5F7FF);
    final cardColor = isDark ? const Color(0xFF1E2138) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2158);
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6FF);

    final email = auth.email;
    final userId = auth.userId;
    final isLoggedIn = auth.isLoggedIn;
    final initial = (email != null && email.isNotEmpty) ? email[0].toUpperCase() : 'G';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181B30) : primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Profile Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isLoggedIn
                        ? accentColor.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isLoggedIn ? accentColor : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLoggedIn ? (email ?? 'User') : 'Guest User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLoggedIn
                          ? const Color(0xFFE6FAF3)
                          : const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoggedIn ? Icons.verified_user_rounded : Icons.person_outline,
                          size: 14,
                          color: isLoggedIn ? const Color(0xFF0F6E56) : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLoggedIn ? 'Verified Account' : 'Guest Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLoggedIn
                                ? const Color(0xFF0F6E56)
                                : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT INFORMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : Colors.black45,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.alternate_email_rounded,
                    label: 'Email',
                    value: email ?? 'Not signed in',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                  Divider(color: borderColor, height: 24),
                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: userId != null && userId.isNotEmpty ? userId : 'N/A',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    copyable: userId != null && userId.isNotEmpty,
                    context: context,
                  ),
                  Divider(color: borderColor, height: 24),
                  _buildInfoRow(
                    icon: Icons.lock_clock_outlined,
                    label: 'Auth Status',
                    value: isLoggedIn ? 'Authenticated via Token' : 'Temporary Guest Session',
                    isDark: isDark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (isLoggedIn) ...[
              // Reset Password Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.lock_reset_rounded, color: accentColor),
                  label: const Text(
                    'Reset Password',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  onPressed: () => _confirmLogout(context, auth),
                ),
              ),
            ] else ...[
              // Guest mode: Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    'Sign In or Create Account',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    bool copyable = false,
    BuildContext? context,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF272B45) : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: accentColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (copyable && context != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: accentColor,
            tooltip: 'Copy ID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User ID copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
