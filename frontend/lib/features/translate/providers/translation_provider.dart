import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

enum AnnouncementInputMode { youtube, presets, text, audio }

class HistoryItem {
  final String? id;
  final String translation;
  final String? originalText;
  final String? station;
  final String? targetLang;
  final DateTime timestamp;

  HistoryItem({
    this.id,
    required this.translation,
    this.originalText,
    this.station,
    this.targetLang,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'translation': translation,
        'originalText': originalText,
        'station': station,
        'targetLang': targetLang,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id']?.toString(),
      translation: json['translation']?.toString() ?? '',
      originalText: json['originalText']?.toString(),
      station: json['station']?.toString(),
      targetLang: json['targetLang']?.toString(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory HistoryItem.fromMap(Map<String, String> map) {
    return HistoryItem(
      id: map['id'],
      translation: map['translation'] ?? '',
      originalText: map['original_text'],
      station: map['station'],
      targetLang: map['target_lang'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class TranslationProvider extends ChangeNotifier {
  // TTS Engine
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Station & Input Mode
  String _selectedStationCode = 'SBC';
  String _selectedStationName = 'KSR Bengaluru City Junction';
  AnnouncementInputMode _inputMode = AnnouncementInputMode.youtube;

  // Processing & State
  bool _isProcessing = false;
  String _processingStatus = '';
  String? _errorMessage;

  // YouTube & Audio Input
  String _youtubeUrl = '';
  Map<String, dynamic>? _videoMetadata;

  // Content
  String _originalTranscription = '';
  String _detectedLanguage = 'English';
  String _targetLanguage = 'kn'; // Kannada by default
  String _translatedAnnouncement = '';
  List<Map<String, dynamic>> _namedEntities = [];
  List<Map<String, dynamic>> _fingerspellingCards = [];

  // Indian Sign Language (ISL) Sequence & Player
  List<Map<String, dynamic>> _islSequence = [];
  int _activeGestureIndex = 0;
  bool _isPlayingISL = false;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  Timer? _gestureTimer;
  String? _customVideoUrl;

  // History & Cache
  List<HistoryItem> _history = [];
  bool _isLoadingHistory = false;

  String get currentTranslation => _translatedAnnouncement;
  bool get isConnected => true;

  void clearCurrentTranslation() {
    _translatedAnnouncement = '';
    notifyListeners();
  }

  // Getters
  FlutterTts get tts => _tts;
  bool get isSpeaking => _isSpeaking;
  String get selectedStationCode => _selectedStationCode;
  String get selectedStationName => _selectedStationName;
  AnnouncementInputMode get inputMode => _inputMode;
  bool get isProcessing => _isProcessing;
  String get processingStatus => _processingStatus;
  String? get errorMessage => _errorMessage;

  String get youtubeUrl => _youtubeUrl;
  Map<String, dynamic>? get videoMetadata => _videoMetadata;
  String get originalTranscription => _originalTranscription;
  String get detectedLanguage => _detectedLanguage;
  String get targetLanguage => _targetLanguage;
  String get translatedAnnouncement => _translatedAnnouncement;
  List<Map<String, dynamic>> get namedEntities => _namedEntities;
  List<Map<String, dynamic>> get fingerspellingCards => _fingerspellingCards;

  List<Map<String, dynamic>> get islSequence => _islSequence;
  int get activeGestureIndex => _activeGestureIndex;
  bool get isPlayingISL => _isPlayingISL;
  double get playbackSpeed => _playbackSpeed;
  bool get isLooping => _isLooping;
  String? get customVideoUrl => _customVideoUrl;
  List<HistoryItem> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  TranslationProvider() {
    _initTts();
    _loadSampleDefault();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.85);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });
    } catch (_) {}
  }

  void _loadSampleDefault() {
    // Default preview: Shreya missing child announcement
    _originalTranscription =
        'Attention please. A 6-year-old child named Shreya has been found near platform number 2. She is safe with the Railway Protection Force. Parents or guardians are requested to immediately report to the Station Master office.';
    _translatedAnnouncement =
        'ದಯವಿಟ್ಟು ಗಮನಿಸಿ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರ ಬಳಿ ಶ್ರೇಯಾ ಹೆಸರಿನ 6 ವರ್ಷದ ಬಾಲಕಿ ಕಂಡುಬಂದಿದ್ದಾಳೆ. ಆಕೆ ರೈಲ್ವೆ ರಕ್ಷಣಾ ಪಡೆಯ (ಆರ್.ಪಿ.ಎಫ್) ಸಿಬ್ಬಂದಿಯೊಂದಿಗೆ ಸುರಕ್ಷಿತವಾಗಿದ್ದಾಳೆ. ಪೋಷಕರು ಅಥವಾ ಸಂಬಂಧಿಕರು ತಕ್ಷಣವೇ ಸ್ಟೇಷನ್ ಮಾಸ್ಟರ್ ಕಚೇರಿಯನ್ನು ಸಂಪರ್ಕಿಸಲು ವಿನಂತಿಸಲಾಗಿದೆ.';
    _namedEntities = [
      {
        'text': 'Shreya',
        'entity_type': 'PERSON',
        'label': 'Child Name',
        'is_name': true,
        'fingerspell': ['S', 'H', 'R', 'E', 'Y', 'A'],
        'explanation': 'Proper Noun: Fingerspelled letter-by-letter in ISL'
      },
      {
        'text': '2',
        'entity_type': 'PLATFORM',
        'label': 'Platform 2',
        'fingerspell': ['2']
      }
    ];
    _islSequence = ApiService.getFallbackISLSequence('shreya');
  }

  void setStation(String code, String name) {
    _selectedStationCode = code;
    _selectedStationName = name;
    notifyListeners();
  }

  void setInputMode(AnnouncementInputMode mode) {
    _inputMode = mode;
    notifyListeners();
  }

  void setYoutubeUrl(String url) {
    _youtubeUrl = url;
    notifyListeners();
  }

  /// Process YouTube Video URL: Extract audio, STT, Multilingual NLP, NER, and ISL
  Future<void> processYouTube(String url) async {
    if (url.trim().isEmpty) return;
    _isProcessing = true;
    _errorMessage = null;
    _youtubeUrl = url.trim();
    _processingStatus = 'Extracting audio from YouTube video...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _processingStatus = 'Transcribing spoken announcement sound track...';
      notifyListeners();

      final result = await ApiService.processYouTubeAnnouncement(
        youtubeUrl: _youtubeUrl,
        targetLang: _targetLanguage,
      );

      _videoMetadata = result['video_metadata'] as Map<String, dynamic>?;
      _originalTranscription = result['audio_transcription'] ?? '';
      _detectedLanguage = result['detected_language'] ?? 'English';
      _translatedAnnouncement = result['translated_announcement'] ?? '';

      final rawEntities = result['named_entities'] as List? ?? [];
      _namedEntities = rawEntities.map((e) => Map<String, dynamic>.from(e)).toList();

      final rawSeq = result['isl_sequence'] as List? ?? [];
      _islSequence = rawSeq.map((e) => Map<String, dynamic>.from(e)).toList();

      final rawFingerspell = result['fingerspelling_cards'] as List? ?? [];
      _fingerspellingCards = rawFingerspell.map((e) => Map<String, dynamic>.from(e)).toList();

      _activeGestureIndex = 0;
      _isPlayingISL = false;

      // Save to history
      _addHistoryRecord(
        translation: _translatedAnnouncement,
        originalText: _originalTranscription,
        station: _selectedStationName,
        targetLang: _targetLanguage,
      );
    } catch (e) {
      _errorMessage = 'Failed to process YouTube audio: $e';
    } finally {
      _isProcessing = false;
      _processingStatus = '';
      notifyListeners();
    }
  }

  /// Process text announcement directly
  Future<void> processText(String text) async {
    if (text.trim().isEmpty) return;
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Contextually translating to $targetLangName...';
    notifyListeners();

    try {
      _originalTranscription = text.trim();
      final result = await ApiService.translateAnnouncementText(
        text: _originalTranscription,
        targetLang: _targetLanguage,
      );

      _translatedAnnouncement = result['translated_text'] ?? '';
      final rawEntities = result['named_entities'] as List? ?? [];
      _namedEntities = rawEntities.map((e) => Map<String, dynamic>.from(e)).toList();

      final rawSeq = result['isl_sequence'] as List? ?? [];
      _islSequence = rawSeq.map((e) => Map<String, dynamic>.from(e)).toList();

      _activeGestureIndex = 0;
      _isPlayingISL = false;

      _addHistoryRecord(
        translation: _translatedAnnouncement,
        originalText: _originalTranscription,
        station: _selectedStationName,
        targetLang: _targetLanguage,
      );
    } catch (e) {
      _errorMessage = 'Translation failed: $e';
    } finally {
      _isProcessing = false;
      _processingStatus = '';
      notifyListeners();
    }
  }

  /// Load a pre-curated Karnataka announcement preset
  void loadPreset(Map<String, dynamic> preset) {
    _originalTranscription = preset['transcription'] ?? '';
    _selectedStationCode = preset['station_code'] ?? _selectedStationCode;
    _selectedStationName = preset['station_name'] ?? _selectedStationName;

    final translations = preset['translations'] as Map<String, dynamic>?;
    if (translations != null && translations.containsKey(_targetLanguage)) {
      _translatedAnnouncement = translations[_targetLanguage] ?? '';
    } else {
      _translatedAnnouncement = preset['translations']?['kn'] ?? _originalTranscription;
    }

    final rawEntities = preset['named_entities'] as List? ?? [];
    _namedEntities = rawEntities.map((e) => Map<String, dynamic>.from(e)).toList();

    final isChildAlert = preset['id'] == 'ann_shreya_child_alert' ||
        preset['title']?.toString().contains('Shreya') == true;
    _islSequence = ApiService.getFallbackISLSequence(isChildAlert ? 'shreya' : 'karnataka_exp');
    _activeGestureIndex = 0;
    _isPlayingISL = false;
    _customVideoUrl = preset['custom_video_url'];

    _addHistoryRecord(
      translation: _translatedAnnouncement,
      originalText: _originalTranscription,
      station: _selectedStationName,
      targetLang: _targetLanguage,
    );
    notifyListeners();
  }

  /// Switch Target Language and update contextual translation
  Future<void> setTargetLanguage(String langCode) async {
    if (_targetLanguage == langCode) return;
    _targetLanguage = langCode;
    notifyListeners();

    if (_originalTranscription.isNotEmpty) {
      await processText(_originalTranscription);
    }
  }

  String get targetLangName {
    switch (_targetLanguage) {
      case 'kn':
        return 'ಕನ್ನಡ (Kannada)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'en':
        return 'English';
      default:
        return _targetLanguage.toUpperCase();
    }
  }

  // --- Sign Language Interactive Player Controls ---

  void playISL() {
    if (_islSequence.isEmpty) return;
    _isPlayingISL = true;
    _scheduleNextGesture();
    notifyListeners();
  }

  void pauseISL() {
    _isPlayingISL = false;
    _gestureTimer?.cancel();
    notifyListeners();
  }

  void togglePlayPauseISL() {
    if (_isPlayingISL) {
      pauseISL();
    } else {
      playISL();
    }
  }

  void setGestureIndex(int index) {
    if (index >= 0 && index < _islSequence.length) {
      _activeGestureIndex = index;
      notifyListeners();
    }
  }

  void stepGesture(int delta) {
    final nextIndex = _activeGestureIndex + delta;
    if (nextIndex >= 0 && nextIndex < _islSequence.length) {
      _activeGestureIndex = nextIndex;
      notifyListeners();
    } else if (nextIndex >= _islSequence.length && _isLooping) {
      _activeGestureIndex = 0;
      notifyListeners();
    }
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void toggleLooping() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void setCustomVideoUrl(String? url) {
    _customVideoUrl = url;
    notifyListeners();
  }

  void _scheduleNextGesture() {
    _gestureTimer?.cancel();
    if (!_isPlayingISL || _islSequence.isEmpty) return;

    final currentGesture = _islSequence[_activeGestureIndex];
    final baseDuration = (currentGesture['duration_ms'] as int?) ?? 1000;
    final adjustedDuration = (baseDuration / _playbackSpeed).round();

    _gestureTimer = Timer(Duration(milliseconds: adjustedDuration), () {
      if (!_isPlayingISL) return;
      if (_activeGestureIndex < _islSequence.length - 1) {
        _activeGestureIndex++;
        notifyListeners();
        _scheduleNextGesture();
      } else {
        if (_isLooping) {
          _activeGestureIndex = 0;
          notifyListeners();
          _scheduleNextGesture();
        } else {
          _isPlayingISL = false;
          notifyListeners();
        }
      }
    });
  }

  /// Text-to-Speech announcement pronunciation
  Future<void> speakTranslation() async {
    if (_translatedAnnouncement.trim().isEmpty) return;
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      notifyListeners();
      return;
    }

    try {
      _isSpeaking = true;
      notifyListeners();

      String langCode = 'kn-IN';
      if (_targetLanguage == 'hi') langCode = 'hi-IN';
      if (_targetLanguage == 'en') langCode = 'en-IN';
      if (_targetLanguage == 'ta') langCode = 'ta-IN';
      if (_targetLanguage == 'te') langCode = 'te-IN';

      await _tts.setLanguage(langCode);
      await _tts.speak(_translatedAnnouncement);
    } catch (_) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // --- History Storage ---

  void _addHistoryRecord({
    required String translation,
    String? originalText,
    String? station,
    String? targetLang,
  }) {
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      translation: translation,
      originalText: originalText,
      station: station,
      targetLang: targetLang,
      timestamp: DateTime.now(),
    );
    _history.insert(0, item);
    if (_history.length > 50) {
      _history.removeLast();
    }
    _persistHistory();
    notifyListeners();
  }

  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _history.map((h) => h.toJson()).toList();
      await prefs.setString('railway_history_cache', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> loadHistory(String userId, {String? token, bool force = false}) async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('railway_history_cache');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        _history = decoded.map((m) => HistoryItem.fromJson(Map<String, dynamic>.from(m))).toList();
      }
    } catch (_) {} finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void updateTranslation(String text) {
    _translatedAnnouncement = text;
    notifyListeners();
  }

  Future<HistoryItem> saveTranslation(
    String userId,
    String translation, {
    String? token,
  }) async {
    _addHistoryRecord(translation: translation, station: _selectedStationName, targetLang: _targetLanguage);
    return HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      translation: translation,
      timestamp: DateTime.now(),
    );
  }

  Future<void> deleteHistoryItem(String id, {String? token}) async {
    _history.removeWhere((h) => h.id == id || h.translation == id);
    _persistHistory();
    notifyListeners();
  }

  Future<void> clearHistory({String? token}) async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('railway_history_cache');
    notifyListeners();
  }

  @override
  void dispose() {
    _gestureTimer?.cancel();
    _tts.stop();
    super.dispose();
  }
}
