import 'package:flutter/material.dart';
import '../services/sound_manager.dart';
import '../services/haptic_service.dart';
import '../services/speech_service.dart';

class SettingsSheet extends StatefulWidget {
  final SoundManager soundManager;
  final HapticService hapticService;
  final SpeechService speechService;
  final VoidCallback? onSettingsChanged;

  const SettingsSheet({
    super.key,
    required this.soundManager,
    required this.hapticService,
    required this.speechService,
    this.onSettingsChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _soundEnabled;
  late bool _hapticsEnabled;
  late bool _voiceInputEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = !widget.soundManager.isMuted;
    _hapticsEnabled = widget.hapticService.isEnabled;
    _voiceInputEnabled = true;
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await widget.soundManager.setMuted(!value);
    widget.onSettingsChanged?.call();
  }

  Future<void> _toggleHaptics(bool value) async {
    setState(() => _hapticsEnabled = value);
    widget.hapticService.setEnabled(value);
    widget.onSettingsChanged?.call();
  }

  Future<void> _toggleVoiceInput(bool value) async {
    setState(() => _voiceInputEnabled = value);
    widget.onSettingsChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A23) : const Color(0xFFFAF7F2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Sound',
            subtitle: 'Play sound effects and ambient audio',
            value: _soundEnabled,
            onChanged: _toggleSound,
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.vibration_rounded,
            title: 'Haptics',
            subtitle: 'Vibration feedback for interactions',
            value: _hapticsEnabled,
            onChanged: _toggleHaptics,
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.mic_rounded,
            title: 'Voice Input',
            subtitle: 'Allow voice questions',
            value: _voiceInputEnabled,
            onChanged: _toggleVoiceInput,
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.accessibility_new_rounded,
            title: 'Reduced Motion',
            subtitle: 'Follows system preference',
            isReadOnly: true,
            value: MediaQuery.of(context).accessibleNavigation,
            onChanged: null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isReadOnly;
  final ValueChanged<bool>? onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252530) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: isReadOnly ? null : onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
