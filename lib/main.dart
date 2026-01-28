import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'breakout_game.dart';
import 'ui/hud.dart';
import 'ui/bottom_control.dart';
import 'ui/game_over_menu.dart';
import 'ui/start_screen.dart';
import 'systems/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager().init(); // Optional preload

  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget(
              game: BreakoutGame(),
            ),
            const GameHud(),
            const BottomControls(),
            const GameOverMenu(),
            const StartScreen(),
          ],
        ),
      ),
    ),
  );
}
