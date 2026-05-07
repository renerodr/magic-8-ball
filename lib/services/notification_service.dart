import 'package:flutter/material.dart';

class NotificationService {
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    // Placeholder: Will integrate flutter_local_notifications in future
    // For now, this service exists as a scaffold for reminder scheduling
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
  }

  Future<void> scheduleDailyReminder() async {
    if (!_isEnabled) return;
    // Placeholder: Schedule evening reminder at 7 PM
    debugPrint('Scheduled daily reminder for 7 PM');
  }

  Future<void> cancelReminders() async {
    debugPrint('Cancelled all reminders');
  }
}
