import 'package:flutter/material.dart';
import '../../systems/audio_manager.dart';
import 'pixel_text.dart';

class SoundSettingsWidget extends StatefulWidget {
  const SoundSettingsWidget({super.key});

  @override
  State<SoundSettingsWidget> createState() => _SoundSettingsWidgetState();
}

class _SoundSettingsWidgetState extends State<SoundSettingsWidget> {
  final AudioManager _audioManager = AudioManager();
  late double _bgmVolume;
  late double _seVolume;
  late bool _bgmEnabled;
  late bool _seEnabled;

  @override
  void initState() {
    super.initState();
    _bgmVolume = _audioManager.bgmVolume;
    _seVolume = _audioManager.seVolume;
    _bgmEnabled = _audioManager.bgmEnabled;
    _seEnabled = _audioManager.seEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("BGM"),
        _buildControlRow(
          value: _bgmVolume,
          enabled: _bgmEnabled,
          onEnabledChanged: (value) {
            setState(() {
              _bgmEnabled = value;
              _audioManager.bgmEnabled = value;
            });
          },
          onVolumeChanged: (value) {
            setState(() {
              _bgmVolume = value;
              _audioManager.bgmVolume = value;
            });
          },
        ),
        const SizedBox(height: 10),
        _buildSectionTitle("SE"),
        _buildControlRow(
          value: _seVolume,
          enabled: _seEnabled,
          onEnabledChanged: (value) {
            setState(() {
              _seEnabled = value;
              _audioManager.seEnabled = value;
            });
          },
          onVolumeChanged: (value) {
            setState(() {
              _seVolume = value;
              _audioManager.seVolume = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: PixelText(title, fontSize: 16, color: Colors.yellow),
    );
  }

  Widget _buildControlRow({
    required double value,
    required bool enabled,
    required ValueChanged<bool> onEnabledChanged,
    required ValueChanged<double> onVolumeChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const PixelText("ON/OFF", fontSize: 12),
            Switch(
              value: enabled,
              onChanged: onEnabledChanged,
              activeThumbColor: Colors.green,
              activeTrackColor: Colors.green.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.5),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: enabled ? Colors.orange : Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            thumbColor: enabled ? Colors.orangeAccent : Colors.grey,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: enabled ? onVolumeChanged : null,
          ),
        ),
      ],
    );
  }
}
