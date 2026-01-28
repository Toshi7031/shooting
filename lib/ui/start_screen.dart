import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../systems/audio_manager.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, child) {
        if (GameState().isGameActive) return const SizedBox.shrink();

        return SizedBox.expand(
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const PixelText(
                    "CIRCLE BREAKER",
                    fontSize: 40,
                    color: Colors.cyanAccent,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const PixelText(
                    "SURVIVORS",
                    fontSize: 32,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  PixelButton(
                    label: "TAP TO START",
                    width: 200,
                    onPressed: () {
                      // Initialize Audio on interaction
                      AudioManager().startBgm();
                      // Start Game
                      GameState().startGame();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
