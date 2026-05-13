import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reading.dart';
import '../services/history_service.dart';
import '../services/haptic_service.dart';
import '../services/haptic_patterns.dart';
import '../utils/motion_policy.dart';
import '../widgets/favorite_button.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  final _hapticService = HapticService();
  late Future<List<Reading>> _readingsFuture;
  Reading? _lastDeletedReading;
  bool _showFavoritesOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _readingsFuture = _historyService.getReadings();
  }

  void _refreshReadings() {
    setState(() {
      _readingsFuture = _historyService.getReadings();
    });
  }

  Future<void> _clear() async {
    await _historyService.clearHistory();
    _refreshReadings();
  }

  void _navigateToHomeAndAsk() {
    _hapticService.trigger(HapticPattern.buttonPress);
    Navigator.of(context).pop();
  }

  Future<void> _deleteReading(Reading reading) async {
    _lastDeletedReading = reading;
    await _historyService.deleteReading(reading);
    _refreshReadings();
  }

  Future<void> _undoDelete() async {
    if (_lastDeletedReading == null) return;
    final reading = _lastDeletedReading!;
    _lastDeletedReading = null;
    await _historyService.addReading(reading);
    _refreshReadings();
  }

  Future<void> _toggleFavorite(Reading reading) async {
    _hapticService.trigger(HapticPattern.favorite);
    await _historyService.toggleFavorite(reading);
    _refreshReadings();
  }

  List<Reading> _filterReadings(List<Reading> readings) {
    var filtered = readings;

    if (_showFavoritesOnly) {
      filtered = filtered.where((r) => r.isFavorite).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.question.toLowerCase().contains(lowerQuery) ||
            r.answer.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Readings'),
        backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F0FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? const Color(0xFFFF6B6B) : null,
            ),
            tooltip: _showFavoritesOnly ? 'Show all' : 'Show favorites',
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clear,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search readings...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          // Readings list
          Expanded(
            child: FutureBuilder<List<Reading>>(
              future: _readingsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allReadings = snapshot.data!;
                final readings = _filterReadings(allReadings);

                if (allReadings.isEmpty) {
                  return _buildEmptyState(context);
                }

                if (readings.isEmpty) {
                  if (_showFavoritesOnly) {
                    return _buildFavoritesEmptyState(context);
                  }
                  if (_searchQuery.isNotEmpty) {
                    return _buildNoSearchResultsState(context);
                  }
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: readings.length,
                  itemBuilder: (context, index) {
                    final reading = readings[index];
                    final policy = MotionPolicy.of(context);
                    return _buildHistoryCard(
                      context,
                      reading,
                      index,
                      readings.length,
                    )
                        .animate()
                        .fadeIn(
                          duration: policy.cardEntryDuration(),
                          delay: policy.staggerDelay(index),
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: policy.cardEntryDuration(),
                          delay: policy.staggerDelay(index),
                          curve: Curves.easeOut,
                        )
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          duration: policy.cardEntryDuration(),
                          delay: policy.staggerDelay(index),
                          curve: Curves.easeOut,
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final policy = MotionPolicy.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        )
            .animate(
              onPlay: policy.isReduced ? null : (c) => c.repeat(reverse: true),
            )
            .rotate(
              begin: -0.09,
              end: 0.09,
              duration: policy.longDuration(),
              curve: Curves.easeInOut,
            )
            .fadeIn(duration: policy.longDuration())
            .then()
            .fade(
              begin: 1.0,
              end: 0.7,
              duration: policy.longDuration(),
              curve: Curves.easeInOut,
            )
            .then()
            .fade(
              begin: 0.7,
              end: 1.0,
              duration: policy.longDuration(),
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 24),
        Text(
          'The oracle awaits your first question',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Shake your device or type below to begin',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _navigateToHomeAndAsk,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Ask a Question'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite_border,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
        const SizedBox(height: 24),
        Text(
          'No starred readings yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap the star on any reading to save it',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNoSearchResultsState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
        const SizedBox(height: 24),
        Text(
          'The mists are unclear…',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Try different words or browse your full history',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Reading reading,
    int index,
    int totalLength,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Dismissible(
      key: Key('reading-${reading.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.red,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        _hapticService.trigger(HapticPattern.error);
        await _deleteReading(reading);
        if (!mounted) return true;
        // ignore: use_build_context_synchronously
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Reading dismissed'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: _undoDelete,
            ),
          ),
        );
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF12111A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'answer-${reading.timestamp.millisecondsSinceEpoch}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        reading.answer.toUpperCase(),
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              fontSize: 18,
                              height: 1.4,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                  ),
                ),
                FavoriteButton(
                  isFavorite: reading.isFavorite,
                  onTap: () => _toggleFavorite(reading),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reading.question.isNotEmpty)
              Text(
                reading.question,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatDate(reading.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
