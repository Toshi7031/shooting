import 'package:flutter/material.dart';
import '../data/game_state.dart';
import 'widgets/pixel_panel.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_button.dart';
import 'widgets/pixel_scrollbar.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
  });

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
              const SizedBox(height: 20),

              // Stats Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PixelScrollbar(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PixelText("STATS",
                            fontSize: 16, color: Colors.yellow),
                        const Divider(color: Colors.white24),
                        _buildStat("Level", "${GameState().level}"),
                        _buildStat("Wave", "${GameState().currentWave}"),
                        _buildStat("Gold", "${GameState().gold}"),
                        const SizedBox(height: 10),
                        const PixelText("MULTIPLIERS",
                            fontSize: 12, color: Colors.cyan),
                        _buildStat("Physical",
                            "x${GameState().tagMultipliers['Physical']?.toStringAsFixed(1)}"),
                        _buildStat("Fire",
                            "x${GameState().tagMultipliers['Fire']?.toStringAsFixed(1)}"),
                        _buildStat("Cold",
                            "x${GameState().tagMultipliers['Cold']?.toStringAsFixed(1)}"),
                        const SizedBox(height: 10),
                        const PixelText("SKILLS",
                            fontSize: 12, color: Colors.orange),
                        _buildStat("Atk Speed",
                            "x${GameState().fireIntervalMultiplier.toStringAsFixed(1)}"),
                        _buildStat("Pierce", "${GameState().pierceCount}"),
                        _buildStat("Bounce", "${GameState().maxBounces}"),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              PixelButton(
                label: "RESUME",
                onPressed: onResume,
                width: 200,
              ),
              const SizedBox(height: 10),
              PixelButton(
                label: "RESTART",
                onPressed: onRestart,
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
