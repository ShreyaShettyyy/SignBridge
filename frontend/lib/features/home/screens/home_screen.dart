import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/ash_wine_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../translate/providers/translation_provider.dart';
import '../../translate/screens/translate_screen.dart';
import '../../translate/screens/sign_language_player_screen.dart';
import '../../vocabulary/screens/include_vocabulary_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../saved/screens/saved_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../settings/providers/settings_provider.dart';
import 'about_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_terms_screen.dart';

class SignBridgeHome extends StatefulWidget {
  const SignBridgeHome({super.key});

  @override
  State<SignBridgeHome> createState() => _SignBridgeHomeState();
}

class _SignBridgeHomeState extends State<SignBridgeHome> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<Widget> _screens = const [
    _HomeTab(),
    TranslateScreen(),
    IncludeVocabularyScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    _fadeCtrl.reset();
    setState(() => _selectedIndex = index);
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AshWineTheme.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AshWineTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: AshWineTheme.surface(context),
        border: Border(top: BorderSide(color: AshWineTheme.cardBorder(context))),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : AshWineTheme.exactAshWine.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
              _navItem(context, 1, Icons.campaign_outlined, Icons.campaign, 'Announce'),
              _navItem(context, 2, Icons.dataset_outlined, Icons.dataset, 'ISL Studio'),
              _navItem(context, 3, Icons.history_outlined, Icons.history, 'History'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = selectedIndex == index;
    final isDark = AshWineTheme.isDark(context);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AshWineTheme.primaryLight.withOpacity(0.3) : AshWineTheme.cardBgSecondaryLight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: isDark ? AshWineTheme.rose.withOpacity(0.4) : AshWineTheme.exactAshWine.withOpacity(0.2))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? (isDark ? AshWineTheme.champagne : AshWineTheme.exactAshWine)
                  : AshWineTheme.textMuted(context),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : AshWineTheme.exactAshWine,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<TranslationProvider>();
    final String initial = (auth.email ?? 'S')[0].toUpperCase();
    final String greeting = _greeting();

    return Scaffold(
      backgroundColor: AshWineTheme.bg(context),
      body: Column(
        children: [
          // App Header
          _AppHeader(
            initial: initial,
            greeting: greeting,
            email: auth.email,
            isLoggedIn: auth.isLoggedIn,
            stationName: provider.selectedStationName,
            stationCode: provider.selectedStationCode,
            onLogout: () async {
              await context.read<AuthProvider>().logout();
            },
            onLogin: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Banner
                  _HeroBanner(
                    onGetStarted: () {
                      final home = context.findAncestorStateOfType<_SignBridgeHomeState>();
                      home?._onNavTap(1);
                    },
                    onOpenPlayer: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignLanguagePlayerScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Spotlight Alert Demo: Missing Child Shreya
                  _FeaturedAnnouncementCard(
                    onTestShreya: () {
                      provider.loadPreset({
                        'id': 'ann_shreya_child_alert',
                        'station_code': 'SBC',
                        'station_name': 'KSR Bengaluru City Junction',
                        'transcription':
                            'Attention please. A 6-year-old child named Shreya has been found near platform number 2. She is safe with the Railway Protection Force. Parents or guardians are requested to immediately report to the Station Master office.',
                        'translations': {
                          'kn':
                              'ದಯವಿಟ್ಟು ಗಮನಿಸಿ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರ ಬಳಿ ಶ್ರೇಯಾ ಹೆಸರಿನ 6 ವರ್ಷದ ಬಾಲಕಿ ಕಂಡುಬಂದಿದ್ದಾಳೆ. ಆಕೆ ರೈಲ್ವೆ ರಕ್ಷಣಾ ಪಡೆಯ ಸಿಬ್ಬಂದಿಯೊಂದಿಗೆ ಸುರಕ್ಷಿತವಾಗಿದ್ದಾಳೆ. ಪೋಷಕರು ಅಥವಾ ಸಂಬಂಧಿಕರು ತಕ್ಷಣವೇ ಸ್ಟೇಷನ್ ಮಾಸ್ಟರ್ ಕಚೇರಿಯನ್ನು ಸಂಪರ್ಕಿಸಲು ವಿನಂತಿಸಲಾಗಿದೆ.',
                          'hi':
                              'कृपया ध्यान दें। प्लेटफार्म नंबर 2 के पास श्रेया नाम की 6 वर्षीय बच्ची मिली है। वह रेलवे सुरक्षा बल के पास सुरक्षित है। माता-पिता तुरंत स्टेशन मास्टर कार्यालय में संपर्क करें।',
                        },
                        'named_entities': [
                          {
                            'text': 'Shreya',
                            'entity_type': 'PERSON',
                            'label': 'Child Name',
                            'is_name': true,
                            'fingerspell': ['S', 'H', 'R', 'E', 'Y', 'A'],
                            'explanation': 'Proper Noun: Hand gesture spells S-H-R-E-Y-A letter by letter in ISL.'
                          },
                          {'text': '2', 'entity_type': 'PLATFORM', 'label': 'Platform 2', 'fingerspell': ['2']}
                        ]
                      });
                      final home = context.findAncestorStateOfType<_SignBridgeHomeState>();
                      home?._onNavTap(1);
                    },
                  ),

                  const SizedBox(height: 22),

                  // Core Modes Grid
                  const _SectionLabel(label: 'Railway Accessibility Modules'),
                  const SizedBox(height: 12),
                  _ModulesGrid(
                    onAnnounce: () {
                      final home = context.findAncestorStateOfType<_SignBridgeHomeState>();
                      home?._onNavTap(1);
                    },
                    onDataset: () {
                      final home = context.findAncestorStateOfType<_SignBridgeHomeState>();
                      home?._onNavTap(2);
                    },
                    onPlayer: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignLanguagePlayerScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // Quick Actions Row
                  const _SectionLabel(label: 'Quick navigation'),
                  const SizedBox(height: 12),
                  _QuickActionsRow(
                    onHistory: () {
                      final home = context.findAncestorStateOfType<_SignBridgeHomeState>();
                      home?._onNavTap(3);
                    },
                    onSaved: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedScreen()),
                      );
                    },
                    onSettings: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    onAbout: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutSignBridgeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    required this.initial,
    required this.greeting,
    required this.email,
    required this.isLoggedIn,
    required this.stationName,
    required this.stationCode,
    required this.onLogout,
    required this.onLogin,
  });

  final String initial;
  final String greeting;
  final String? email;
  final bool isLoggedIn;
  final String stationName;
  final String stationCode;
  final VoidCallback onLogout;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isDark = AshWineTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: AshWineTheme.surface(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(bottom: BorderSide(color: AshWineTheme.cardBorder(context))),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AshWineTheme.exactAshWine.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AshWineTheme.cardDark : AshWineTheme.cardBgSecondaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AshWineTheme.rose : AshWineTheme.exactAshWine.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.sign_language,
                      color: isDark ? Colors.white : AshWineTheme.exactAshWine,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SignBridge',
                        style: TextStyle(
                          color: AshWineTheme.textPrimary(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Railway Multilingual & ISL System',
                        style: TextStyle(
                          color: isDark ? AshWineTheme.rose : AshWineTheme.mauve,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Theme Toggle Button (Light / Dark)
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return IconButton(
                        tooltip: settings.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                        icon: Icon(
                          settings.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
                          color: settings.isDarkMode ? AshWineTheme.champagne : AshWineTheme.exactAshWine,
                          size: 22,
                        ),
                        onPressed: () => settings.toggleDarkMode(!settings.isDarkMode),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AshWineTheme.cardDark : AshWineTheme.cardBgSecondaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AshWineTheme.cardBorder(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.train,
                          size: 14,
                          color: isDark ? AshWineTheme.champagne : AshWineTheme.exactAshWine,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stationCode,
                          style: TextStyle(
                            color: isDark ? AshWineTheme.champagne : AshWineTheme.exactAshWine,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(color: AshWineTheme.textMuted(context), fontSize: 12),
                      ),
                      Text(
                        stationName,
                        style: TextStyle(
                          color: AshWineTheme.textPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: isDark ? AshWineTheme.primaryLight : AshWineTheme.exactAshWine,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onGetStarted, required this.onOpenPlayer});
  final VoidCallback onGetStarted;
  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AshWineTheme.wineHeroGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AshWineTheme.rose.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AshWineTheme.primaryDark.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.mic, size: 13, color: AshWineTheme.champagne),
                SizedBox(width: 5),
                Text(
                  'Acoustic Audio to ISL Gestures',
                  style: TextStyle(
                    color: AshWineTheme.champagne,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Railway Station Announcements Accessibility',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste YouTube railway announcement videos or speak. Translates sound into authentic Kannada, Hindi, and Indian Sign Language (ISL) with letter-by-letter fingerspelling for proper names.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AshWineTheme.champagne,
                  foregroundColor: AshWineTheme.bgDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text(
                  'Process Announcement',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                onPressed: onGetStarted,
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.sign_language, size: 16),
                label: const Text(
                  'ISL Player',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                onPressed: onOpenPlayer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedAnnouncementCard extends StatelessWidget {
  const _FeaturedAnnouncementCard({required this.onTestShreya});
  final VoidCallback onTestShreya;

  @override
  Widget build(BuildContext context) {
    final isDark = AshWineTheme.isDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AshWineTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AshWineTheme.entityAmber.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AshWineTheme.entityAmber.withOpacity(isDark ? 0.12 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AshWineTheme.properNounGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.child_care, size: 14, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'FEATURED SPOTLIGHT ALERT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AshWineTheme.cardDark : AshWineTheme.cardBgSecondaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'KSR Bengaluru SBC',
                  style: TextStyle(
                    color: isDark ? AshWineTheme.champagne : AshWineTheme.exactAshWine,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Missing Child Shreya Found Announcement',
            style: TextStyle(
              color: AshWineTheme.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"Attention please. A 6-year-old child named Shreya has been found near platform 2... safe with RPF."',
            style: TextStyle(
              color: AshWineTheme.textSecondary(context),
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AshWineTheme.entityAmber.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NER Proper Noun: SHREYA',
                  style: TextStyle(color: AshWineTheme.entityAmber, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AshWineTheme.primaryDark : AshWineTheme.cardBgSecondaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Fingerspelling: S-H-R-E-Y-A',
                  style: TextStyle(
                    color: isDark ? AshWineTheme.rose : AshWineTheme.exactAshWine,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AshWineTheme.exactAshWine,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.play_circle_filled, size: 18),
              label: const Text(
                'Load Alert & Translate in Indian Sign Language',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              onPressed: onTestShreya,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModulesGrid extends StatelessWidget {
  const _ModulesGrid({
    required this.onAnnounce,
    required this.onDataset,
    required this.onPlayer,
  });

  final VoidCallback onAnnounce;
  final VoidCallback onDataset;
  final VoidCallback onPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _moduleCard(
                context,
                title: 'YouTube Audio STT',
                subtitle: 'Extract acoustic sound and translate',
                icon: Icons.ondemand_video,
                badge: 'Input Sound',
                color: AshWineTheme.rose,
                onTap: onAnnounce,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _moduleCard(
                context,
                title: 'ISL Gesture Player',
                subtitle: 'Sequenced gestures & letter fingerspelling',
                icon: Icons.sign_language,
                badge: 'Two-Handed ISL',
                color: AshWineTheme.entityAmber,
                onTap: onPlayer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _moduleCard(
          context,
          title: 'Karnataka Announcement Dataset Studio',
          subtitle: 'KSR Bengaluru, Mysuru, Hubballi • Attach custom recorded sign videos',
          icon: Icons.dataset,
          badge: 'Dataset Builder',
          color: AshWineTheme.champagne,
          onTap: onDataset,
        ),
      ],
    );
  }

  Widget _moduleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = AshWineTheme.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AshWineTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AshWineTheme.cardBorder(context)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AshWineTheme.exactAshWine.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark ? AshWineTheme.cardDark : AshWineTheme.cardBgSecondaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isDark ? color : AshWineTheme.exactAshWine,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: AshWineTheme.textPrimary(context),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: AshWineTheme.textSecondary(context), fontSize: 11.5, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onHistory,
    required this.onSaved,
    required this.onSettings,
    required this.onAbout,
  });

  final VoidCallback onHistory;
  final VoidCallback onSaved;
  final VoidCallback onSettings;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(context, Icons.history, 'History', onHistory),
        _quickAction(context, Icons.bookmark_border, 'Saved', onSaved),
        _quickAction(context, Icons.settings_outlined, 'Settings', onSettings),
        _quickAction(context, Icons.info_outline, 'About', onAbout),
      ],
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = AshWineTheme.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AshWineTheme.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AshWineTheme.cardBorder(context)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AshWineTheme.exactAshWine.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDark ? AshWineTheme.champagne : AshWineTheme.exactAshWine,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: AshWineTheme.textPrimary(context),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AshWineTheme.textPrimary(context),
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}
