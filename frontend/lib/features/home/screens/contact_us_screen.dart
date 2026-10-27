import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static const Color primaryColor = Color(0xFF1E2158);
  static const Color accentColor = Color(0xFF4B6CF7);
  static const String supportEmail = 'signbridgeog@gmail.com';

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _messageCtrl;

  bool _isSending = false;
  String _selectedCategory = 'General Inquiry';

  final List<String> _categories = [
    'General Inquiry',
    'Bug Report',
    'Sign Recognition Feedback',
    'Feature Request',
    'Partnership / Accessibility',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final userEmail = auth.email ?? '';
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: userEmail);
    _subjectCtrl = TextEditingController(text: 'General Inquiry');
    _messageCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final name = _nameCtrl.text.trim().isEmpty ? 'Anonymous User' : _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final subject = '[$_selectedCategory] ${_subjectCtrl.text.trim()}';
      final message = _messageCtrl.text.trim();

      await ApiService.sendContactMessage(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );

      if (!mounted) return;

      setState(() => _isSending = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF0F6E56), size: 48),
          title: const Text('Message Sent', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Thank you for reaching out! Your message has been sent to our support team at signbridgeog@gmail.com. We usually respond within 24 hours.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ContactUsScreen.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission notice: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121424) : const Color(0xFFF5F7FF);
    final cardColor = isDark ? const Color(0xFF1E2138) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2158);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6FF);
    final inputBg = isDark ? const Color(0xFF272B45) : const Color(0xFFF8F9FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF181B30) : ContactUsScreen.primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Direct email banner card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2158), const Color(0xFF2C326E)]
                      : [const Color(0xFF1E2158), const Color(0xFF4B6CF7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ContactUsScreen.accentColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'We are here to help!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Have feedback, discovered a bug, or need assistance? Reach out to our team directly:',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: ContactUsScreen.supportEmail));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support email copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.alternate_email_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            ContactUsScreen.supportEmail,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.copy_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form card
            Container(
              padding: const EdgeInsets.all(22),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEND US A MESSAGE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : Colors.black45,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Category Dropdown
                    Text('Topic', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: cardColor,
                      style: TextStyle(fontSize: 14, color: textColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text('Your Name (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. Rahul Sharma',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: inputBg,
                        prefixIcon: Icon(Icons.person_outline_rounded, color: isDark ? Colors.white54 : ContactUsScreen.primaryColor, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    Text('Your Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor, fontSize: 14),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: inputBg,
                        prefixIcon: Icon(Icons.alternate_email_rounded, color: isDark ? Colors.white54 : ContactUsScreen.primaryColor, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Message
                    Text('Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _messageCtrl,
                      maxLines: 5,
                      style: TextStyle(color: textColor, fontSize: 14),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your message';
                        if (v.trim().length < 5) return 'Message is too short';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Tell us how we can help, report an issue, or suggest improvements...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ContactUsScreen.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSending ? null : _submitForm,
                        child: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.send_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Send Message',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
