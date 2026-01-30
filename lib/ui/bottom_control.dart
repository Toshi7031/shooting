import 'package:flutter/material.dart';
import 'widgets/pixel_button.dart';
import 'shop_menu.dart';
import 'pause_menu.dart';
import 'level_up_menu.dart'; // Import
import '../data/game_state.dart';
import '../main.dart'; // For gameInstance

class BottomControls extends StatelessWidget {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PixelButton(
                label: "SHOP",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (ctx) =>
                        ShopMenu(onClose: () => Navigator.pop(ctx)),
                  );
                },
                width: 100,
              ),
              PixelButton(
                label: "MENU",
                onPressed: () {
                  // ... existing menu logic ...
                  GameState().isPaused = true;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => PauseMenu(
                      onResume: () {
                        GameState().isPaused = false;
                        Navigator.pop(ctx);
                      },
                      onRestart: () {
                        GameState().reset(); // Reset State
                        gameInstance.resetGame(); // Reset game components
                        GameState().isPaused = false;
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                },
                width: 100,
              ),
              ListenableBuilder(
                listenable: GameState(),
                builder: (context, child) {
                  final hasPoints = GameState().pendingUpgrades > 0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PixelButton(
                        label: "UPGRADE",
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (ctx) =>
                                LevelUpMenu(onClose: () => Navigator.pop(ctx)),
                          );
                        },
                        width: 100,
                      ),
                      if (hasPoints)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${GameState().pendingUpgrades}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
