import 'package:flutter/material.dart';
import '../../data/game_state.dart';
import 'pixel_text.dart';

/// 装備中のアーティファクトを表示するウィジェット
class ArtifactSlotWidget extends StatelessWidget {
  const ArtifactSlotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, _) {
        final state = GameState();
        final artifacts = state.equippedArtifacts;
        final stolenMods = state.stolenMods;

        if (artifacts.isEmpty && stolenMods.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.withAlpha(100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 装備中のアーティファクト
              if (artifacts.isNotEmpty) ...[
                const PixelText("ARTIFACTS",
                    fontSize: 10, color: Colors.orange),
                const SizedBox(height: 4),
                ...artifacts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PixelText(a.name, fontSize: 10),
                        ],
                      ),
                    )),
              ],

              // 盗んだMod（Stolen Mods）
              if (stolenMods.isNotEmpty) ...[
                const SizedBox(height: 6),
                const PixelText("STOLEN", fontSize: 10, color: Colors.cyan),
                const SizedBox(height: 4),
                ...stolenMods.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.cyan,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PixelText(
                            "${m.type} ${m.remainingTime.toStringAsFixed(1)}s",
                            fontSize: 9,
                            color: Colors.cyan,
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}
