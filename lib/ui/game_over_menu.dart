import 'package:flutter/material.dart';
import '../data/game_state.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_button.dart';

class GameOverMenu extends StatelessWidget {
  const GameOverMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, child) {
        if (!GameState().isGameOver) return const SizedBox.shrink();

        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PixelText("GAME OVER", fontSize: 32, color: Colors.red),
                const SizedBox(height: 20),
                PixelText("Reached Wave ${GameState().currentWave}",
                    fontSize: 16),
                const SizedBox(height: 40),
                PixelButton(
                  label: "RETRY",
                  onPressed: () {
                    GameState().reset();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
