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

        // Always show the widget to display empty slots
        // if (artifacts.isEmpty && stolenMods.isEmpty) {
        //   return const SizedBox.shrink();
        // }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 装備中のアーティファクト (常に3スロット表示)
              const PixelText("ARTIFACTS", fontSize: 10, color: Colors.orange),
              const SizedBox(height: 4),
              // 3スロット固定表示
              ...List.generate(3, (index) {
                final hasArtifact = index < artifacts.length;
                final artifact = hasArtifact ? artifacts[index] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: hasArtifact ? Colors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          border: hasArtifact ? null : Border.all(color: Colors.white24, width: 1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      PixelText(
                        hasArtifact ? artifact!.name : "---",
                        fontSize: 10,
                        color: hasArtifact ? Colors.white : Colors.white24,
                      ),
                    ],
                  ),
                );
              }),

              // 盗んだMod（Stolen Mods）- グループ化して表示
              if (stolenMods.isNotEmpty) ...[
                const SizedBox(height: 6),
                const PixelText("STOLEN", fontSize: 10, color: Colors.cyan),
                const SizedBox(height: 4),
                // typeでグループ化して表示
                ..._groupStolenMods(stolenMods).entries.map((entry) => Padding(
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
                            entry.value > 1 ? "${entry.key} ×${entry.value}" : entry.key,
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

  /// stolenModsをtypeでグループ化してカウント
  Map<String, int> _groupStolenMods(List<StolenMod> mods) {
    final grouped = <String, int>{};
    for (final mod in mods) {
      grouped[mod.type] = (grouped[mod.type] ?? 0) + 1;
    }
    return grouped;
  }
}
