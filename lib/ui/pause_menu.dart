import 'package:flutter/material.dart';
import '../data/game_state.dart';
import 'widgets/pixel_panel.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_button.dart';
import 'widgets/pixel_scrollbar.dart';
import 'widgets/sound_settings_widget.dart';

class PauseMenu extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
  });

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: PixelPanel(
          width: 320,
          height: 480,
          child: Column(
            children: [
              const PixelText("PAUSED", fontSize: 24, color: Colors.white),
              const SizedBox(height: 10),

              // Toggle Button
              PixelButton(
                label: _showSettings ? "SHOW STATS" : "AUDIO SETTINGS",
                onPressed: () {
                  setState(() {
                    _showSettings = !_showSettings;
                  });
                },
                width: 160,
                height: 30,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 10),

              // Content Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _showSettings ? const SoundSettingsWidget() : _buildStats(),
                ),
              ),

              const SizedBox(height: 20),
              PixelButton(
                label: "RESUME",
                onPressed: widget.onResume,
                width: 200,
              ),
              const SizedBox(height: 10),
              PixelButton(
                label: "RESTART",
                onPressed: widget.onRestart,
                width: 200,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return PixelScrollbar(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PixelText("STATS", fontSize: 16, color: Colors.yellow),
          const Divider(color: Colors.white24),
          _buildStat("Level", "${GameState().level}"),
          _buildStat("Wave", "${GameState().currentWave}"),
          _buildStat("Gold", "${GameState().gold}"),
          const SizedBox(height: 10),
          const PixelText("MULTIPLIERS", fontSize: 12, color: Colors.cyan),
          _buildStat("Physical", "x${GameState().tagMultipliers['Physical']?.toStringAsFixed(1)}"),
          _buildStat("Fire", "x${GameState().tagMultipliers['Fire']?.toStringAsFixed(1)}"),
          _buildStat("Cold", "x${GameState().tagMultipliers['Cold']?.toStringAsFixed(1)}"),
          const SizedBox(height: 10),
          const PixelText("SKILLS", fontSize: 12, color: Colors.orange),
          _buildStat("Atk Speed", "x${GameState().fireIntervalMultiplier.toStringAsFixed(1)}"),
          _buildStat("Pierce", "${GameState().pierceCount}"),
          _buildStat("Bounce", "${GameState().maxBounces}"),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PixelText(label, fontSize: 14),
          PixelText(value, fontSize: 14, color: Colors.white70),
        ],
      ),
    );
  }
}
