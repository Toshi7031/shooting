import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../data/constants.dart';
import 'widgets/pixel_button.dart';
import 'widgets/pixel_scrollbar.dart';
import 'widgets/base_menu.dart';

class LevelUpMenu extends StatelessWidget {
  final VoidCallback? onClose;

  const LevelUpMenu({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, child) {
        return BaseMenu(
          title: "Points: ${GameState().pendingUpgrades}",
          titleColor: GameColors.accent,
          onClose: onClose,
          height: MediaQuery.of(context).size.height * 0.4,
          child: PixelScrollbar(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUpgradeOption("Physical Damage +20%", "Physical", 0.2),
                const SizedBox(height: 10),
                _buildUpgradeOption("Fire Damage +20%", "Fire", 0.2),
                const SizedBox(height: 10),
                _buildUpgradeOption("Cold Damage +20%", "Cold", 0.2),
                const SizedBox(height: 10),
                _buildUpgradeOption("Attack Speed +10%", "AttackSpeed", 0.1),
                const SizedBox(height: 10),
                _buildUpgradeOption("Pierce +1", "Pierce", 1.0),
                const SizedBox(height: 10),
                _buildUpgradeOption("Bounce +1", "Bounce", 1.0),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpgradeOption(String text, String tag, double value) {
    return PixelButton(
      label: text,
      width: double.infinity,
      height: 50,
      onPressed: () {
        GameState().upgradeTag(tag, value);
      },
    );
  }
}
