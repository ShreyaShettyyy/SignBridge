import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/ash_wine_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../translate/providers/translation_provider.dart';
import '../../translate/screens/sign_language_player_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory(force: false));
  }

  Future<void> _loadHistory({bool force = false}) async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId ?? 'guest';
    try {
      await context.read<TranslationProvider>().loadHistory(userId, token: auth.token, force: force);
    } catch (_) {}
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AshWineTheme.surfaceDark,
        title: const Text('Clear Announcement History', style: TextStyle(color: AshWineTheme.textPrimaryDark)),
        content: const Text(
          'Are you sure you want to delete all saved announcement history? This action cannot be undone.',
          style: TextStyle(color: AshWineTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AshWineTheme.textMutedDark)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TranslationProvider>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = context.watch<TranslationProvider>();
    final history = translationProvider.history;

    return Scaffold(
      backgroundColor: AshWineTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AshWineTheme.surfaceDark,
        elevation: 0,
        title: const Text(
          'Announcement History',
          style: TextStyle(
            color: AshWineTheme.textPrimaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (history.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AshWineTheme.rose),
              tooltip: 'Clear History',
              onPressed: _confirmClearHistory,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AshWineTheme.champagne),
              tooltip: 'Refresh',
              onPressed: () => _loadHistory(force: true),
            ),
          ],
        ],
      ),
      body: translationProvider.isLoadingHistory
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AshWineTheme.rose),
                  SizedBox(height: 12),
                  Text('Loading history...', style: TextStyle(color: AshWineTheme.textSecondaryDark)),
                ],
              ),
            )
          : history.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AshWineTheme.rose,
                  backgroundColor: AshWineTheme.surfaceDark,
                  onRefresh: () => _loadHistory(force: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _HistoryCard(
                        item: item,
                        index: index,
                        onTap: () {
                          translationProvider.processText(item.originalText ?? item.translation);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignLanguagePlayerScreen()),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AshWineTheme.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AshWineTheme.cardBorderDark),
            ),
            child: const Icon(Icons.history, size: 48, color: AshWineTheme.rose),
          ),
          const SizedBox(height: 18),
          const Text(
            'No announcements translated yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AshWineTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Translated railway announcements will appear here for fast replay.',
            style: TextStyle(fontSize: 13, color: AshWineTheme.textMutedDark),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final int index;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy · h:mm a').format(item.timestamp);

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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AshWineTheme.cardDark,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AshWineTheme.cardBorderDark),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.train, size: 12, color: AshWineTheme.champagne),
                          const SizedBox(width: 4),
                          Text(
                            item.station ?? 'Karnataka Railway',
                            style: const TextStyle(
                              color: AshWineTheme.champagne,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(color: AshWineTheme.textMutedDark, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.translation,
                  style: const TextStyle(
                    color: AshWineTheme.textPrimaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (item.originalText != null && item.originalText!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.originalText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AshWineTheme.textSecondaryDark, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'Replay in ISL Gestures',
                      style: TextStyle(
                        color: AshWineTheme.rose,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: AshWineTheme.rose),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
