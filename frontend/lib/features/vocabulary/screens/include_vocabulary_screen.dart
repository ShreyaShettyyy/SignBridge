import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/theme/ash_wine_theme.dart';
import '../../translate/providers/translation_provider.dart';
import '../../translate/screens/sign_language_player_screen.dart';

class IncludeVocabularyScreen extends StatefulWidget {
  const IncludeVocabularyScreen({super.key});

  @override
  State<IncludeVocabularyScreen> createState() => _IncludeVocabularyScreenState();
}

class _IncludeVocabularyScreenState extends State<IncludeVocabularyScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Emergency & Lost Person',
    'Train Arrivals',
    'Platform Reschedule',
    'Train Delays',
    'Public Safety',
  ];

  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 'ann_shreya_child_alert',
      'station_code': 'SBC',
      'station_name': 'KSR Bengaluru City Junction',
      'category': 'Emergency & Lost Person',
      'title': '🚨 Missing Child Shreya Alert (Featured)',
      'preview': 'Child named Shreya found near platform 2, safe with RPF. Parents please report to office.',
      'transcription':
          'Attention please. A 6-year-old child named Shreya has been found near platform number 2. She is safe with the Railway Protection Force. Parents or guardians are requested to immediately report to the Station Master office.',
      'translations': {
        'kn':
            'ದಯವಿಟ್ಟು ಗಮನಿಸಿ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರ ಬಳಿ ಶ್ರೇಯಾ ಹೆಸರಿನ 6 ವರ್ಷದ ಬಾಲಕಿ ಕಂಡುಬಂದಿದ್ದಾಳೆ. ಆಕೆ ರೈಲ್ವೆ ರಕ್ಷಣಾ ಪಡೆಯ (ಆರ್.ಪಿ.ಎಫ್) ಸಿಬ್ಬಂದಿಯೊಂದಿಗೆ ಸುರಕ್ಷಿತವಾಗಿದ್ದಾಳೆ. ಪೋಷಕರು ಅಥವಾ ಸಂಬಂಧಿಕರು ತಕ್ಷಣವೇ ಸ್ಟೇಷನ್ ಮಾಸ್ಟರ್ ಕಚೇರಿಯನ್ನು ಸಂಪರ್ಕಿಸಲು ವಿನಂತಿಸಲಾಗಿದೆ.',
        'hi':
            'कृपया ध्यान दें। प्लेटफार्म नंबर 2 के पास श्रेया नाम की 6 वर्षीय बच्ची मिली है। वह रेलवे सुरक्षा बल के पास सुरक्षित है। माता-पिता तुरंत स्टेशन मास्टर कार्यालय में संपर्क करें।',
      },
      'named_entities': [
        {'text': 'Shreya', 'entity_type': 'PERSON', 'label': 'Child Name', 'fingerspell': ['S', 'H', 'R', 'E', 'Y', 'A']},
        {'text': '2', 'entity_type': 'PLATFORM', 'label': 'Platform 2'},
      ],
      'has_custom_video': false,
    },
    {
      'id': 'ann_karnataka_exp_arrival',
      'station_code': 'SBC',
      'station_name': 'KSR Bengaluru City Junction',
      'category': 'Train Arrivals',
      'title': '🚆 Karnataka Express (12627) Arrival',
      'preview': 'Train 12627 Karnataka Express to New Delhi is arriving shortly on platform number 1.',
      'transcription':
          'May I have your attention please. Train number 12627 Karnataka Express from KSR Bengaluru to New Delhi is arriving shortly on platform number 1.',
      'translations': {
        'kn':
            'ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಕೆಎಸ್ಆರ್ ಬೆಂಗಳೂರಿನಿಂದ ನವದೆಹಲಿಗೆ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 12627 ಕರ್ನಾಟಕ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಕೆಲವೇ ಕ್ಷಣಗಳಲ್ಲಿ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 1 ಕ್ಕೆ ಬರಲಿದೆ.',
        'hi':
            'यात्रियों का ध्यान आकर्षित किया जाता है। गाड़ी संख्या 12627 कर्नाटक एक्सप्रेस प्लेटफार्म नंबर 1 पर आ रही है।',
      },
      'named_entities': [
        {'text': '12627', 'entity_type': 'TRAIN_NUMBER', 'label': 'Train 12627'},
        {'text': 'Karnataka Express', 'entity_type': 'TRAIN_NAME', 'label': 'Karnataka Express'},
        {'text': '1', 'entity_type': 'PLATFORM', 'label': 'Platform 1'},
      ],
      'has_custom_video': false,
    },
    {
      'id': 'ann_rani_chennamma_platform',
      'station_code': 'UBL',
      'station_name': 'SSS Hubballi Junction',
      'category': 'Platform Reschedule',
      'title': '🔄 Rani Chennamma (16589) Platform Reschedule',
      'preview': 'Train 16589 Rani Chennamma will now depart from platform number 4 instead of platform 2.',
      'transcription':
          'Attention passengers. Train number 16589 Rani Chennamma Express scheduled to depart from platform number 2 will now depart from platform number 4. Inconvenience caused is deeply regretted.',
      'translations': {
        'kn':
            'ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರಿಂದ ಹೊರಡಬೇಕಿದ್ದ ಗಾಡಿ ಸಂಖ್ಯೆ 16589 ರಾಣಿ ಚೆನ್ನಮ್ಮ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಈಗ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 4 ರಿಂದ ಹೊರಡಲಿದೆ.',
        'hi':
            'यात्रीगण कृपया ध्यान दें। प्लेटफार्म नंबर 2 से प्रस्थान करने वाली गाड़ी संख्या 16589 रानी चेन्नम्मा एक्सप्रेस अब प्लेटफार्म नंबर 4 से रवाना होगी।',
      },
      'named_entities': [
        {'text': '16589', 'entity_type': 'TRAIN_NUMBER', 'label': 'Train 16589'},
        {'text': '4', 'entity_type': 'PLATFORM', 'label': 'New Platform 4'},
      ],
      'has_custom_video': false,
    },
    {
      'id': 'ann_vande_bharat_delay',
      'station_code': 'MYS',
      'station_name': 'Mysuru Junction',
      'category': 'Train Delays',
      'title': '⏱️ Vande Bharat (20608) Running Status Delay',
      'preview': 'Train 20608 Mysuru to Chennai Vande Bharat Express is delayed by 25 minutes due to technical reasons.',
      'transcription':
          'Attention passengers. Train number 20608 Mysuru to MGR Chennai Central Vande Bharat Express is running 25 minutes behind schedule due to technical maintenance.',
      'translations': {
        'kn':
            'ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಮೈಸೂರಿನಿಂದ ಎಂಜಿಆರ್ ಚೆನ್ನೈ ಸೆಂಟ್ರಲ್ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 20608 ವಂದೇ ಭಾರತ್ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ತಾಂತ್ರಿಕ ಕಾರಣಗಳಿಂದ ಸುಮಾರು 25 ನಿಮಿಷ ವಿಳಂಬವಾಗಿ ಸಂಚರಿಸುತ್ತಿದೆ.',
        'hi':
            'यात्रियों का ध्यान आकर्षित किया जाता है। मैसूरु से चेन्नई जाने वाली गाड़ी संख्या 20608 वंदे भारत एक्सप्रेस 25 मिनट की देरी से चल रही है।',
      },
      'named_entities': [
        {'text': '20608', 'entity_type': 'TRAIN_NUMBER', 'label': 'Train 20608'},
        {'text': '25 min', 'entity_type': 'DURATION', 'label': '25 Minutes Late'},
      ],
      'has_custom_video': false,
    },
    {
      'id': 'ann_baggage_security_alert',
      'station_code': 'MAQ',
      'station_name': 'Mangaluru Central',
      'category': 'Public Safety',
      'title': '⚠️ Unattended Baggage Security Caution',
      'preview': 'Do not touch suspicious or unattended luggage. Immediately inform RPF or dial helpline 139.',
      'transcription':
          'Security alert. If you notice any suspicious, unclaimed, or unattended baggage on railway premises, please do not touch it. Immediately alert the on-duty Railway Protection Force or call railway helpline 139.',
      'translations': {
        'kn':
            'ಸುರಕ್ಷತಾ ಎಚ್ಚರಿಕೆ. ರೈಲ್ವೆ ಆವರಣದಲ್ಲಿ ಯಾವುದೇ ಅನುಮಾನಾಸ್ಪದ, ಮಾಲೀಕರಿಲ್ಲದ ಬ್ಯಾಗ್ ಕಂಡುಬಂದಲ್ಲಿ, ಮುಟ್ಟಬೇಡಿ. ತಕ್ಷಣ ರೈಲ್ವೆ ರಕ್ಷಣಾ ಪಡೆಗೆ ತಿಳಿಸಿ ಅಥವಾ 139 ಗೆ ಕರೆ ಮಾಡಿ.',
        'hi':
            'सुरक्षा चेतावनी। यदि आपको रेलवे परिसर में कोई भी लावारिस बैग दिखाई दे, तो उसे न छुएं। तुरंत हेल्पलाइन 139 पर संपर्क करें।',
      },
      'named_entities': [
        {'text': '139', 'entity_type': 'PHONE', 'label': 'Helpline 139'},
        {'text': 'RPF', 'entity_type': 'ORGANIZATION', 'label': 'Railway Police'},
      ],
      'has_custom_video': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslationProvider>();

    final filtered = _announcements.where((a) {
      final matchesCat = _selectedCategory == 'All' || a['category'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          a['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a['preview'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a['station_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AshWineTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Studio Header
            _buildHeader(context),

            // Custom Dataset & ISL Guide Banner
            _buildIslDatasetBanner(context),

            // Search Bar
            _buildSearchBar(context),

            // Category Horizontal Tabs
            _buildCategoryTabs(context),

            // Announcement List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildAnnouncementCard(context, filtered[index], provider);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = AshWineTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AshWineTheme.surface(context),
        border: Border(bottom: BorderSide(color: AshWineTheme.cardBorder(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AshWineTheme.wineHeroGradient,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AshWineTheme.rose),
                ),
                child: const Icon(Icons.dataset_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Railway Dataset Studio',
                    style: TextStyle(
                      color: AshWineTheme.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Curate Announcements & Custom ISL Datasets',
                    style: TextStyle(color: AshWineTheme.textMuted(context), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? AshWineTheme.champagne : AshWineTheme.primaryDark,
                  size: 20,
                ),
                onPressed: () => settings.toggleDarkMode(!settings.isDarkMode),
              ),
              IconButton(
                tooltip: 'Add new announcement to dataset',
                icon: const Icon(Icons.add_circle, color: AshWineTheme.primaryLight, size: 24),
                onPressed: () => _showAddAnnouncementDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIslDatasetBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AshWineTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AshWineTheme.cardBorder(context)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sign_language_rounded, color: AshWineTheme.primaryLight, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Two-Handed ISL Dataset: A-Z, 0-9 & Vocabulary',
                  style: TextStyle(
                    color: AshWineTheme.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Record custom gestures into datasets/user_custom_isl/ for training.',
                  style: TextStyle(color: AshWineTheme.textMuted(context), fontSize: 10.5),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: AshWineTheme.rose),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.menu_book_rounded, size: 14, color: AshWineTheme.primaryLight),
            label: const Text(
              'ISL Guide',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AshWineTheme.primaryLight),
            ),
            onPressed: () => _showIslGuideDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        style: TextStyle(color: AshWineTheme.textPrimary(context), fontSize: 13),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search Karnataka announcements (e.g., Shreya, 12627, Hubballi)...',
          hintStyle: TextStyle(color: AshWineTheme.textMuted(context), fontSize: 12),
          filled: true,
          fillColor: AshWineTheme.surface(context),
          prefixIcon: const Icon(Icons.search, color: AshWineTheme.rose, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AshWineTheme.cardBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AshWineTheme.cardBorder(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = cat),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AshWineTheme.primaryLight : AshWineTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AshWineTheme.rose : AshWineTheme.cardBorder(context),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AshWineTheme.textSecondary(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Map<String, dynamic> item, TranslationProvider provider) {
    final title = item['title'] ?? '';
    final station = item['station_name'] ?? '';
    final stationCode = item['station_code'] ?? '';
    final preview = item['preview'] ?? '';
    final category = item['category'] ?? '';
    final entities = (item['named_entities'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AshWineTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AshWineTheme.cardBorder(context)),
        boxShadow: AshWineTheme.isDark(context)
            ? []
            : [
                BoxShadow(
                  color: AshWineTheme.primaryDark.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AshWineTheme.card(context),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AshWineTheme.cardBorder(context)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AshWineTheme.champagne),
                    const SizedBox(width: 4),
                    Text(
                      '$stationCode • $station',
                      style: const TextStyle(
                        color: AshWineTheme.champagne,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AshWineTheme.primaryDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: AshWineTheme.rose, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              color: AshWineTheme.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            preview,
            style: TextStyle(color: AshWineTheme.textSecondary(context), fontSize: 12.5, height: 1.35),
          ),

          const SizedBox(height: 12),

          // Named Entities Chips
          if (entities.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entities.map((e) {
                final isPerson = e['is_name'] == true || e['entity_type'] == 'PERSON';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPerson ? AshWineTheme.entityAmber.withOpacity(0.18) : AshWineTheme.card(context),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isPerson ? AshWineTheme.entityAmber : AshWineTheme.cardBorder(context),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPerson ? Icons.person : Icons.tag,
                        size: 11,
                        color: isPerson ? AshWineTheme.entityAmber : AshWineTheme.champagne,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${e['label']}: ${e['text']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPerson ? AshWineTheme.entityAmber : AshWineTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons: Load & Play ISL, Attach Video
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AshWineTheme.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Play ISL Sign Sequence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    provider.loadPreset(item);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignLanguagePlayerScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Attach Custom Sign Video to this announcement',
                icon: const Icon(Icons.videocam_outlined, color: AshWineTheme.champagne),
                onPressed: () => _showAttachVideoSheet(context, item, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: AshWineTheme.mauve.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'No matching railway announcements',
            style: TextStyle(color: AshWineTheme.textPrimary(context), fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showIslGuideDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AshWineTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sign_language, color: AshWineTheme.primaryLight, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Two-Handed ISL Dataset Guide',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AshWineTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AshWineTheme.textMuted(context)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AshWineTheme.card(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AshWineTheme.cardBorder(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📹 How to Record Your Custom Gestures',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AshWineTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '1. Run in terminal:\n   python scripts/record_my_gestures.py\n2. Select mode (Alphabet, Number, or Railway Word).\n3. Follow the 3-second visual countdown and perform the gesture 3-5 times.\n4. Run python scripts/train_user_dataset.py to compile the registry.',
                          style: TextStyle(fontSize: 12, height: 1.4, color: AshWineTheme.textSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '🔤 Authentic Two-Handed ISL Alphabet (A–Z)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AshWineTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'In Indian Sign Language, the non-dominant hand serves as the base/paper and dominant hand executes the sign:',
                    style: TextStyle(fontSize: 11.5, color: AshWineTheme.textMuted(context)),
                  ),
                  const SizedBox(height: 10),
                  _buildGuideRow(context, 'S (Shreya)', 'Interlock both pinky fingers with both fists clenched.'),
                  _buildGuideRow(context, 'H (Shreya)', 'Dominant open palm slides flat forward over non-dominant open palm.'),
                  _buildGuideRow(context, 'R (Shreya)', 'Cross index finger over middle finger (fingers crossed).'),
                  _buildGuideRow(context, 'E (Shreya)', 'Dominant index fingertip touches tip of non-dominant index finger.'),
                  _buildGuideRow(context, 'Y (Shreya)', 'Dominant thumb and pinky extended (horn/V), non-dominant index points up into palm.'),
                  _buildGuideRow(context, 'A (Shreya)', 'Dominant index fingertip touches tip of non-dominant thumb.'),
                  const SizedBox(height: 16),
                  Text(
                    '🔢 Numbers (0–9)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AshWineTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGuideRow(context, '0', 'Fingers curved touching thumb creating an "O" shape.'),
                  _buildGuideRow(context, '1 - 5', 'Dominant index (1), +middle (2), +ring (3), 4 fingers (4), open hand (5).'),
                  _buildGuideRow(context, '6 - 9', 'Non-dominant open palm (5) + dominant fingers (1 to 4) touching palm.'),
                  const SizedBox(height: 16),
                  Text(
                    '🚉 Core Railway Words',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AshWineTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGuideRow(context, 'ATTENTION', 'Both open palms face audience and wave slightly up-down at chest.'),
                  _buildGuideRow(context, 'TRAIN', 'Both hands with index & middle extended slide back and forth like rail tracks.'),
                  _buildGuideRow(context, 'PLATFORM', 'Flat non-dominant hand palm down (elevated) + dominant hand pats surface.'),
                  _buildGuideRow(context, 'CHILD', 'Flat palm pats downward in front indicating small child height.'),
                  _buildGuideRow(context, 'FOUND / SAFE', 'Both open hands grasp forward and pull back with thumbs-up.'),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuideRow(BuildContext context, String term, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AshWineTheme.primaryDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AshWineTheme.cardBorder(context)),
            ),
            child: Text(
              term,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AshWineTheme.primaryLight),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(fontSize: 11.5, color: AshWineTheme.textSecondary(context), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    String station = 'SBC';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AshWineTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Karnataka Announcement',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AshWineTheme.textPrimary(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AshWineTheme.textMuted(context)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: AshWineTheme.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Announcement Title',
                  labelStyle: const TextStyle(color: AshWineTheme.rose),
                  filled: true,
                  fillColor: AshWineTheme.card(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AshWineTheme.cardBorder(context)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                maxLines: 3,
                style: TextStyle(color: AshWineTheme.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Spoken Sound Track Text',
                  labelStyle: const TextStyle(color: AshWineTheme.rose),
                  hintText: 'e.g. Attention please, train 12627 arriving...',
                  hintStyle: TextStyle(color: AshWineTheme.textMuted(context), fontSize: 12),
                  filled: true,
                  fillColor: AshWineTheme.card(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AshWineTheme.cardBorder(context)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AshWineTheme.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Add to Local Dataset'),
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    final body = textCtrl.text.trim();
                    if (t.isNotEmpty && body.isNotEmpty) {
                      setState(() {
                        _announcements.insert(0, {
                          'id': 'ann_custom_${DateTime.now().millisecondsSinceEpoch}',
                          'station_code': station,
                          'station_name': 'KSR Bengaluru City Junction',
                          'category': 'Custom Announcements',
                          'title': t,
                          'preview': body,
                          'transcription': body,
                          'named_entities': [],
                          'has_custom_video': false,
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Announcement successfully added to local dataset!'),
                          backgroundColor: AshWineTheme.primaryDark,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachVideoSheet(BuildContext context, Map<String, dynamic> item, TranslationProvider provider) {
    final urlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AshWineTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attach Video: ${item['title']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AshWineTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a video recording of yourself demonstrating the sign language for this announcement.',
                style: TextStyle(color: AshWineTheme.textSecondary(context), fontSize: 12),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: urlCtrl,
                style: TextStyle(color: AshWineTheme.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Video URL or Local File Path',
                  labelStyle: const TextStyle(color: AshWineTheme.rose),
                  filled: true,
                  fillColor: AshWineTheme.card(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AshWineTheme.cardBorder(context)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AshWineTheme.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Save Custom Video Demonstration'),
                  onPressed: () {
                    final u = urlCtrl.text.trim();
                    if (u.isNotEmpty) {
                      provider.setCustomVideoUrl(u);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Custom sign video demonstration saved!'),
                          backgroundColor: AshWineTheme.primaryDark,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
