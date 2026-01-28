import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../data/item_repository.dart';
import '../data/item_data.dart';
import '../data/items/artifact_data.dart';
import '../data/constants.dart';
import 'widgets/base_menu.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_button.dart';
import 'widgets/pixel_scrollbar.dart';

class ShopMenu extends StatelessWidget {
  final VoidCallback onClose;

  const ShopMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BaseMenu(
      title: "SHOP",
      titleColor: GameColors.accent,
      onClose: onClose,
      child: PixelScrollbar(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ボールセクション
            const PixelText("-- BALLS --",
                fontSize: 14, color: GameColors.textSecondary),
            const SizedBox(height: 8),
            _buildBallItem(context, ItemRepository.defaultBall, 50),
            _buildBallItem(context, ItemRepository.vampireOrb, 250),
            _buildBallItem(context, ItemRepository.explosiveOrb, 150),

            const SizedBox(height: 16),
            // アーティファクトセクション
            const PixelText("-- ARTIFACTS --",
                fontSize: 14, color: GameColors.warning),
            const SizedBox(height: 8),
            _buildArtifactItem(context, ArtifactRepository.headhunter, 500),
            _buildArtifactItem(context, ArtifactRepository.tabulaRasa, 300),
            _buildArtifactItem(context, ArtifactRepository.soulEater, 400),
            _buildArtifactItem(context, ArtifactRepository.berserkersRage, 350),
            _buildArtifactItem(context, ArtifactRepository.luckyCharm, 300),

            const SizedBox(height: 16),
            // ユーティリティ
            const PixelText("-- UTILITY --",
                fontSize: 14, color: GameColors.textSecondary),
            const SizedBox(height: 8),
            _buildShopItem(context, "Heal ${GameConstants.healAmount} HP",
                GameConstants.healCost, () {
              final state = GameState();
              if (state.gold >= GameConstants.healCost &&
                  state.coreHp < state.maxCoreHp) {
                state.addGold(-GameConstants.healCost);
                state.healCore(GameConstants.healAmount.toDouble());
                _showMessage(context, "Healed ${GameConstants.healAmount} HP!",
                    GameColors.success);
              } else if (state.coreHp >= state.maxCoreHp) {
                _showMessage(context, "HP is already full!", GameColors.accent);
              } else {
                _showMessage(context, "Not enough Gold!", GameColors.error);
              }
            }),
            _buildShopItem(
                context, "Random Upgrade", GameConstants.randomUpgradeCost, () {
              final state = GameState();
              if (state.gold >= GameConstants.randomUpgradeCost) {
                state.addGold(-GameConstants.randomUpgradeCost);
                final tags = ['Physical', 'Fire', 'Cold'];
                final tag = tags[DateTime.now().second % 3];
                state.upgradeTag(tag, 0.2);
                _showMessage(context, "Upgraded $tag!", GameColors.success);
              } else {
                _showMessage(context, "Not enough Gold!", GameColors.error);
              }
            }),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildArtifactItem(
      BuildContext context, ArtifactData artifact, int cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PixelText(artifact.name,
                    fontSize: 14, color: GameColors.warning),
                PixelText(artifact.description,
                    fontSize: 10, color: GameColors.textSecondary),
                PixelText("$cost G", fontSize: 12, color: GameColors.accent),
              ],
            ),
          ),
          PixelButton(
            label: "BUY",
            onPressed: () {
              final state = GameState();
              if (state.gold < cost) {
                _showMessage(context, "Not enough Gold!", GameColors.error);
                return;
              }
              if (!state.hasEmptyArtifactSlot) {
                _showMessage(
                    context, "No empty artifact slots!", GameColors.error);
                return;
              }
              state.addGold(-cost);
              state.equipArtifact(artifact);
              _showMessage(
                  context, "Equipped ${artifact.name}!", GameColors.warning);
            },
            width: 80,
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildBallItem(BuildContext context, ItemData item, int cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PixelText(item.name, fontSize: 16),
                PixelText(item.description,
                    fontSize: 10, color: GameColors.textSecondary),
                PixelText("$cost G", fontSize: 12, color: GameColors.accent),
              ],
            ),
          ),
          PixelButton(
            label: "BUY",
            onPressed: () {
              final state = GameState();
              if (state.gold >= cost) {
                state.addGold(-cost);
                state.addBall(item);
                _showMessage(
                    context, "Bought ${item.name}!", GameColors.success);
              } else {
                _showMessage(context, "Not enough Gold!", GameColors.error);
              }
            },
            width: 80,
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(
      BuildContext context, String name, int cost, VoidCallback onBuy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PixelText(name, fontSize: 16),
                PixelText("$cost G", fontSize: 12, color: GameColors.accent),
              ],
            ),
          ),
          PixelButton(
            label: "BUY",
            onPressed: onBuy,
            width: 80,
            height: 30,
          ),
        ],
      ),
    );
  }
}
