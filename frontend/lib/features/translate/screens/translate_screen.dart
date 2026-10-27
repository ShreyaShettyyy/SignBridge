import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/ash_wine_theme.dart';
import '../providers/translation_provider.dart';
import 'sign_language_player_screen.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> _stations = [
    {'code': 'SBC', 'name': 'KSR Bengaluru City Junction', 'sub': 'South Western Railway (SWR)'},
    {'code': 'MYS', 'name': 'Mysuru Junction', 'sub': 'South Western Railway (SWR)'},
    {'code': 'UBL', 'name': 'SSS Hubballi Junction', 'sub': 'South Western Railway (SWR)'},
    {'code': 'MAQ', 'name': 'Mangaluru Central', 'sub': 'Southern Railway (SR)'},
    {'code': 'KLBG', 'name': 'Kalaburagi Junction', 'sub': 'Central Railway (CR)'},
    {'code': 'BGM', 'name': 'Belagavi', 'sub': 'South Western Railway (SWR)'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<TranslationProvider>();
    if (provider.youtubeUrl.isNotEmpty) {
      _youtubeController.text = provider.youtubeUrl;
    } else {
      _youtubeController.text = 'https://www.youtube.com/watch?v=sample_railway_alert';
    }
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslationProvider>();

    return Scaffold(
      backgroundColor: AshWineTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Station Selector
            _buildHeader(provider),

            // Mode Selector: YouTube Audio vs Karnataka Presets vs Direct
            _buildModeTabs(provider),

            // Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode-Specific Input View
                    if (provider.inputMode == AnnouncementInputMode.youtube)
                      _buildYouTubeInputSection(provider)
                    else if (provider.inputMode == AnnouncementInputMode.presets)
                      _buildKarnatakaPresetsSection(provider)
                    else
                      _buildTextInputSection(provider),

                    const SizedBox(height: 16),

                    // Processing Indicator
                    if (provider.isProcessing) _buildProcessingCard(provider),

                    // Error Notification if any
                    if (provider.errorMessage != null) _buildErrorCard(provider),

                    // Result Hub: Audio Transcription, Translation & Proper Nouns
                    if (!provider.isProcessing && provider.originalTranscription.isNotEmpty)
                      _buildResultHub(provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TranslationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AshWineTheme.surfaceDark,
        border: const Border(bottom: BorderSide(color: AshWineTheme.cardBorderDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => _showStationPicker(context, provider),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AshWineTheme.wineHeroGradient,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AshWineTheme.rose, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.train, color: AshWineTheme.champagne, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        provider.selectedStationCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.selectedStationName,
                          style: const TextStyle(
                            color: AshWineTheme.textPrimaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AshWineTheme.rose, size: 18),
                      ],
                    ),
                    Text(
                      'Railway Public Address & Sign Bridge',
                      style: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Station information',
            icon: const Icon(Icons.info_outline, color: AshWineTheme.rose, size: 20),
            onPressed: () => _showStationPicker(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs(TranslationProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AshWineTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AshWineTheme.cardBorderDark),
      ),
      child: Row(
        children: [
          _tabPill(
            label: 'YouTube Audio',
            icon: Icons.video_collection_outlined,
            isSelected: provider.inputMode == AnnouncementInputMode.youtube,
            onTap: () => provider.setInputMode(AnnouncementInputMode.youtube),
          ),
          _tabPill(
            label: 'Karnataka Presets',
            icon: Icons.bookmark_added_outlined,
            isSelected: provider.inputMode == AnnouncementInputMode.presets,
            onTap: () => provider.setInputMode(AnnouncementInputMode.presets),
          ),
          _tabPill(
            label: 'Custom Text',
            icon: Icons.edit_note,
            isSelected: provider.inputMode == AnnouncementInputMode.text,
            onTap: () => provider.setInputMode(AnnouncementInputMode.text),
          ),
        ],
      ),
    );
  }

  Widget _tabPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AshWineTheme.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : AshWineTheme.textSecondaryDark),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AshWineTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// YOUTUBE INPUT SECTION
  Widget _buildYouTubeInputSection(TranslationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AshWineTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AshWineTheme.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.ondemand_video, color: AshWineTheme.champagne, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'YouTube Railway Video Sound',
                    style: TextStyle(
                      color: AshWineTheme.textPrimaryDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AshWineTheme.primaryDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Acoustic Audio (Not Captions)',
                  style: TextStyle(
                    color: AshWineTheme.rose,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Paste a YouTube link containing railway announcements. The app extracts raw sound, transcribes words, detects named entities (like person names), and converts to Indian Sign Language.',
            style: TextStyle(fontSize: 12, color: AshWineTheme.textSecondaryDark, height: 1.4),
          ),
          const SizedBox(height: 14),

          // URL Input Field
          TextField(
            controller: _youtubeController,
            style: const TextStyle(color: AshWineTheme.textPrimaryDark, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'https://www.youtube.com/watch?v=...',
              hintStyle: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 12),
              filled: true,
              fillColor: AshWineTheme.cardDark,
              prefixIcon: const Icon(Icons.link, color: AshWineTheme.rose, size: 18),
              suffixIcon: IconButton(
                tooltip: 'Paste from clipboard',
                icon: const Icon(Icons.content_paste, color: AshWineTheme.champagne, size: 18),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null && data!.text!.isNotEmpty) {
                    setState(() => _youtubeController.text = data.text!);
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AshWineTheme.cardBorderDark),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Process Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AshWineTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.audiotrack, size: 18),
              label: const Text(
                'Extract Audio & Translate Announcement',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              onPressed: provider.isProcessing
                  ? null
                  : () {
                      final url = _youtubeController.text.trim();
                      if (url.isNotEmpty) {
                        provider.processYouTube(url);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  /// KARNATAKA PRESETS SECTION
  Widget _buildKarnatakaPresetsSection(TranslationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Karnataka Railway Announcements',
              style: TextStyle(
                color: AshWineTheme.textPrimaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AshWineTheme.champagne.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '1-Tap Test',
                style: TextStyle(color: AshWineTheme.champagne, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _presetCard(
          title: '🚨 Missing Child Shreya Alert (Featured)',
          badge: 'Named Entity & ISL Fingerspelling S-H-R-E-Y-A',
          badgeColor: AshWineTheme.entityAmber,
          station: 'KSR Bengaluru (SBC)',
          previewText:
              'A 6-year-old child named Shreya has been found near platform 2. Parents requested to report to Station Master office.',
          onTap: () {
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
                  'explanation': 'Proper Noun: Fingerspelled letter-by-letter in ISL'
                },
                {'text': '2', 'entity_type': 'PLATFORM', 'label': 'Platform 2', 'fingerspell': ['2']}
              ]
            });
          },
        ),
        const SizedBox(height: 10),
        _presetCard(
          title: '🚆 Karnataka Express (12627) Arrival',
          badge: 'Train Arrival • KSR Bengaluru',
          badgeColor: AshWineTheme.rose,
          station: 'KSR Bengaluru (SBC)',
          previewText:
              'Train 12627 Karnataka Express from KSR Bengaluru to New Delhi is arriving shortly on platform number 1.',
          onTap: () {
            provider.loadPreset({
              'id': 'ann_karnataka_exp_arrival',
              'station_code': 'SBC',
              'station_name': 'KSR Bengaluru City Junction',
              'transcription':
                  'May I have your attention please. Train number 12627 Karnataka Express from KSR Bengaluru to New Delhi is arriving shortly on platform number 1.',
              'translations': {
                'kn':
                    'ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಕೆಎಸ್ಆರ್ ಬೆಂಗಳೂರಿನಿಂದ ನವದೆಹಲಿಗೆ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 12627 ಕರ್ನಾಟಕ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಕೆಲವೇ ಕ್ಷಣಗಳಲ್ಲಿ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 1 ಕ್ಕೆ ಬರಲಿದೆ.',
                'hi':
                    'यात्रियों का ध्यान आकर्षित किया जाता है। गाड़ी संख्या 12627 कर्नाटक एक्सप्रेस प्लेटफार्म नंबर 1 पर आ रही है।',
              },
              'named_entities': [
                {'text': '12627', 'entity_type': 'TRAIN_NUMBER', 'label': 'Train 12627', 'fingerspell': ['1', '2', '6', '2', '7']},
                {'text': 'Karnataka Express', 'entity_type': 'TRAIN_NAME', 'label': 'Train Name'},
                {'text': '1', 'entity_type': 'PLATFORM', 'label': 'Platform 1'},
              ]
            });
          },
        ),
        const SizedBox(height: 10),
        _presetCard(
          title: '🔄 Rani Chennamma (16589) Platform Reschedule',
          badge: 'Platform Change • Hubballi',
          badgeColor: AshWineTheme.champagne,
          station: 'SSS Hubballi (UBL)',
          previewText:
              'Train 16589 Rani Chennamma Express scheduled on platform 2 will now depart from platform number 4.',
          onTap: () {
            provider.loadPreset({
              'id': 'ann_rani_chennamma_platform',
              'station_code': 'UBL',
              'station_name': 'SSS Hubballi Junction',
              'transcription':
                  'Attention passengers. Train number 16589 Rani Chennamma Express scheduled to depart from platform number 2 will now depart from platform number 4.',
              'translations': {
                'kn':
                    'ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರಿಂದ ಹೊರಡಬೇಕಿದ್ದ ಗಾಡಿ ಸಂಖ್ಯೆ 16589 ರಾಣಿ ಚೆನ್ನಮ್ಮ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಈಗ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 4 ರಿಂದ ಹೊರಡಲಿದೆ.',
                'hi':
                    'यात्रीगण ध्यान दें। प्लेटफार्म नंबर 2 से प्रस्थान करने वाली गाड़ी संख्या 16589 रानी चेन्नम्मा एक्सप्रेस अब प्लेटफार्म नंबर 4 से रवाना होगी।',
              },
              'named_entities': [
                {'text': '16589', 'entity_type': 'TRAIN_NUMBER', 'label': 'Train 16589'},
                {'text': '4', 'entity_type': 'PLATFORM', 'label': 'New Platform 4'},
              ]
            });
          },
        ),
      ],
    );
  }

  Widget _presetCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String station,
    required String previewText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AshWineTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AshWineTheme.cardBorderDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AshWineTheme.textPrimaryDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.play_circle_outline, color: AshWineTheme.champagne, size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  previewText,
                  style: TextStyle(color: AshWineTheme.textSecondaryDark, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// CUSTOM TEXT INPUT SECTION
  Widget _buildTextInputSection(TranslationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AshWineTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AshWineTheme.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type or Speak Railway Announcement',
            style: TextStyle(
              color: AshWineTheme.textPrimaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 3,
            style: const TextStyle(color: AshWineTheme.textPrimaryDark, fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'e.g. Attention please, child named Shreya has been found at platform 2...',
              hintStyle: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 12),
              filled: true,
              fillColor: AshWineTheme.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AshWineTheme.cardBorderDark),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AshWineTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.translate, size: 16),
              label: const Text('Translate & Synthesize ISL'),
              onPressed: () {
                final txt = _textController.text.trim();
                if (txt.isNotEmpty) {
                  provider.processText(txt);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// PROCESSING CARD
  Widget _buildProcessingCard(TranslationProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AshWineTheme.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AshWineTheme.rose.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AshWineTheme.rose),
          const SizedBox(height: 16),
          Text(
            provider.processingStatus.isNotEmpty
                ? provider.processingStatus
                : 'Processing railway acoustic sound track...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AshWineTheme.textPrimaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Analyzing sound wave, Named Entities (NER), and ISL manual gestures',
            textAlign: TextAlign.center,
            style: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(TranslationProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// RESULT HUB: Transcribed Audio, Regional Language Selector, Natural Translation, and ISL Revealer
  Widget _buildResultHub(TranslationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Spoken Audio Sound Track (Transcribed)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AshWineTheme.surfaceDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AshWineTheme.cardBorderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.graphic_eq, color: AshWineTheme.rose, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Transcribed Announcement Audio',
                        style: TextStyle(
                          color: AshWineTheme.rose,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AshWineTheme.cardDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Detected: ${provider.detectedLanguage}',
                      style: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 10.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                provider.originalTranscription,
                style: const TextStyle(
                  color: AshWineTheme.textPrimaryDark,
                  fontSize: 13.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Language Switcher Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Translate to Regional Language',
              style: TextStyle(
                color: AshWineTheme.textPrimaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Karnataka Standard',
              style: TextStyle(color: AshWineTheme.champagne, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _langChip(provider, code: 'kn', name: 'ಕನ್ನಡ (Kannada)'),
              const SizedBox(width: 8),
              _langChip(provider, code: 'hi', name: 'हिन्दी (Hindi)'),
              const SizedBox(width: 8),
              _langChip(provider, code: 'en', name: 'English'),
              const SizedBox(width: 8),
              _langChip(provider, code: 'ta', name: 'தமிழ் (Tamil)'),
              const SizedBox(width: 8),
              _langChip(provider, code: 'te', name: 'తెలుగు (Telugu)'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. Meaningful Regional Translation Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AshWineTheme.cardGlowGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AshWineTheme.rose.withOpacity(0.5), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AshWineTheme.primaryDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AshWineTheme.cardBorderDark),
                        ),
                        child: Text(
                          provider.targetLangName,
                          style: const TextStyle(
                            color: AshWineTheme.champagne,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Authentic Public Address',
                        style: TextStyle(color: AshWineTheme.rose, fontSize: 11),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      provider.isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                      color: provider.isSpeaking ? AshWineTheme.champagne : AshWineTheme.textPrimaryDark,
                      size: 20,
                    ),
                    onPressed: () => provider.speakTranslation(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                provider.translatedAnnouncement,
                style: const TextStyle(
                  color: AshWineTheme.textPrimaryDark,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. Named Entities Identified (e.g. Shreya, Train Number, Platform)
        if (provider.namedEntities.isNotEmpty) ...[
          const Text(
            'Named Entity Recognition (NER)',
            style: TextStyle(
              color: AshWineTheme.textPrimaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.namedEntities.map((e) {
              final isPerson = e['is_name'] == true || e['entity_type'] == 'PERSON';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPerson ? AshWineTheme.entityAmber.withOpacity(0.2) : AshWineTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPerson ? AshWineTheme.entityAmber : AshWineTheme.cardBorderDark,
                    width: isPerson ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPerson ? Icons.person_pin : Icons.label_important,
                      size: 14,
                      color: isPerson ? AshWineTheme.entityAmber : AshWineTheme.champagne,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${e['label']}: ${e['text']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPerson ? AshWineTheme.entityAmber : AshWineTheme.textPrimaryDark,
                      ),
                    ),
                    if (isPerson) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AshWineTheme.entityAmber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ISL Fingerspell',
                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 20),

        // 5. BIG CTA: REVEAL IN INDIAN SIGN LANGUAGE (ISL)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignLanguagePlayerScreen()),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: AshWineTheme.wineHeroGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AshWineTheme.rose, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AshWineTheme.primaryLight.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sign_language, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Reveal in Indian Sign Language (ISL) ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _langChip(TranslationProvider provider, {required String code, required String name}) {
    final isSelected = provider.targetLanguage == code;
    return InkWell(
      onTap: () => provider.setTargetLanguage(code),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AshWineTheme.primaryLight : AshWineTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AshWineTheme.rose : AshWineTheme.cardBorderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AshWineTheme.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  void _showStationPicker(BuildContext context, TranslationProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AshWineTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Karnataka Railway Station',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AshWineTheme.textPrimaryDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AshWineTheme.textMutedDark),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._stations.map((st) {
                final isSelected = st['code'] == provider.selectedStationCode;
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected ? AshWineTheme.primaryDark : null,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AshWineTheme.cardDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AshWineTheme.cardBorderDark),
                    ),
                    child: Text(
                      st['code']!,
                      style: TextStyle(
                        color: isSelected ? AshWineTheme.champagne : AshWineTheme.rose,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    st['name']!,
                    style: TextStyle(
                      color: AshWineTheme.textPrimaryDark,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    st['sub']!,
                    style: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 11),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AshWineTheme.champagne)
                      : null,
                  onTap: () {
                    provider.setStation(st['code']!, st['name']!);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
