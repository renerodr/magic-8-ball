import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareReading({
    required String answer,
    required String question,
    required DateTime timestamp,
  }) async {
    final text = _formatShareText(answer, question, timestamp);
    await Share.share(text, subject: 'My Magic 8-Ball Reading');
  }

  Future<void> shareReadingAsImage({
    required GlobalKey repaintKey,
    required String answer,
    required String question,
    required DateTime timestamp,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/magic_8_ball_reading.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: _formatShareText(answer, question, timestamp),
        subject: 'My Magic 8-Ball Reading',
      );
    } catch (_) {
      // Fallback to text sharing if image capture fails
      await shareReading(
        answer: answer,
        question: question,
        timestamp: timestamp,
      );
    }
  }

  String _formatShareText(String answer, String question, DateTime timestamp) {
    final dateStr = '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    if (question.isNotEmpty) {
      return 'I asked: "$question"\n\nThe Oracle answered: "$answer"\n\n$dateStr';
    }
    return 'The Oracle answered: "$answer"\n\n$dateStr';
  }
}
