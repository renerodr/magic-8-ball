import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reading.dart';
import '../services/history_service.dart';
import '../services/haptic_service.dart';
import '../utils/motion_policy.dart';

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

  @override
  void initState() {
    super.initState();
    _readingsFuture = _historyService.getReadings();
  }

  Future<void> _clear() async {
    await _historyService.clearHistory();
    setState(() => _readingsFuture = _historyService.getReadings());
  }

  void _navigateToHomeAndAsk() {
    _hapticService.onReveal();
    Navigator.of(context).pop();
  }

  Future<void> _deleteReading(Reading reading) async {
    _lastDeletedReading = reading;
    await _historyService.deleteReading(reading);
    setState(() => _readingsFuture = _historyService.getReadings());
  }

  Future<void> _undoDelete() async {
    if (_lastDeletedReading == null) return;
    final reading = _lastDeletedReading!;
    _lastDeletedReading = null;
    await _historyService.addReading(reading);
    setState(() => _readingsFuture = _historyService.getReadings());
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
            icon: const Icon(Icons.delete_outline),
            onPressed: _clear,
          ),
        ],
      ),
      body: FutureBuilder<List<Reading>>(
        future: _readingsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final readings = snapshot.data!;
          if (readings.isEmpty) {
            return _buildEmptyState(context);
          }
            return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final policy = MotionPolicy.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
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
          'Shake your device to begin',
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
          label: const Text('Ask Now'),
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
        color: Colors.red.withValues(alpha: 0.2),
        child: const Icon(
          Icons.delete,
          color: Colors.red,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        await _hapticService.onError();
        await _deleteReading(reading);
        if (!mounted) return true;
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
            Hero(
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
