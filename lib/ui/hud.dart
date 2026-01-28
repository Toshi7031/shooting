import 'package:flutter/material.dart';
import '../../data/game_state.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_panel.dart';
import 'widgets/artifact_slot_widget.dart';

class GameHud extends StatelessWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, child) {
        final state = GameState();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // トップバー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // HP Panel
                    PixelPanel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          PixelText(
                              "HP: ${state.coreHp.toInt()}/${state.maxCoreHp.toInt()}",
                              color: Colors.redAccent),
                        ],
                      ),
                    ),

                    // Info Panel
                    PixelPanel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PixelText("WAVE ${state.currentWave}",
                              fontSize: 10, color: Colors.yellow),
                          PixelText("GOLD: ${state.gold}",
                              fontSize: 10, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),

                // アーティファクトスロット表示
                const SizedBox(height: 8),
                const ArtifactSlotWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
