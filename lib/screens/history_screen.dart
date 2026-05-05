import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  late Future<List<Reading>> _readingsFuture;

  @override
  void initState() {
    super.initState();
    _readingsFuture = _historyService.getReadings();
  }

  Future<void> _clear() async {
    await _historyService.clearHistory();
    setState(() => _readingsFuture = _historyService.getReadings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Readings'),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clear),
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
            return const Center(child: Text('No readings yet. Shake!'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: readings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = readings[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Hero(
                  tag: 'answer-${r.timestamp.millisecondsSinceEpoch}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      r.answer.toUpperCase(),
                      style: Theme.of(context).textTheme.displayLarge!
                          .copyWith(fontSize: 16),
                    ),
                  ),
                ),
                subtitle: r.question.isNotEmpty
                    ? Text(
                        r.question,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.6),
                        ),
                      )
                    : null,
                trailing: Text(
                  _formatDate(r.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
