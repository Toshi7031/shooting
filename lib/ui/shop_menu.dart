import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../data/repositories/item_repository.dart';
import '../data/models/item_data.dart';
import '../data/models/artifact_data.dart';
import '../data/repositories/artifact_repository.dart';
import '../data/constants.dart';
import 'widgets/base_menu.dart';
import 'widgets/pixel_text.dart';
import 'widgets/pixel_button.dart';
import 'widgets/pixel_scrollbar.dart';
import 'widgets/floating_feedback.dart';

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
            _ShopBallItem(item: ItemRepository.defaultBall, cost: 50),
            _ShopBallItem(item: ItemRepository.vampireOrb, cost: 250),
            _ShopBallItem(item: ItemRepository.explosiveOrb, cost: 150),

            const SizedBox(height: 16),
            // アーティファクトセクション
            const PixelText("-- ARTIFACTS --",
                fontSize: 14, color: GameColors.warning),
            const SizedBox(height: 8),
            _ShopArtifactItem(artifact: ArtifactRepository.headhunter, cost: 500),
            _ShopArtifactItem(artifact: ArtifactRepository.tabulaRasa, cost: 300),
            _ShopArtifactItem(artifact: ArtifactRepository.soulEater, cost: 400),
            _ShopArtifactItem(artifact: ArtifactRepository.berserkersRage, cost: 350),
            _ShopArtifactItem(artifact: ArtifactRepository.luckyCharm, cost: 300),

            const SizedBox(height: 16),
            // ユーティリティ
            const PixelText("-- UTILITY --",
                fontSize: 14, color: GameColors.textSecondary),
            const SizedBox(height: 8),
            _ShopUtilityItem(
              name: "Heal ${GameConstants.healAmount} HP",
              cost: GameConstants.healCost,
              onBuy: (context, buttonKey) {
                final state = GameState();
                if (state.gold >= GameConstants.healCost && state.coreHp < state.maxCoreHp) {
                  state.addGold(-GameConstants.healCost);
                  state.healCore(GameConstants.healAmount.toDouble());
                  _showFeedback(context, buttonKey, "+${GameConstants.healAmount} HP", GameColors.success, true);
                } else if (state.coreHp >= state.maxCoreHp) {
                  _showFeedback(context, buttonKey, "HP Full!", GameColors.accent, false);
                } else {
                  _showFeedback(context, buttonKey, "Not enough Gold!", GameColors.error, false);
                }
              },
            ),
            _ShopUtilityItem(
              name: "Random Upgrade",
              cost: GameConstants.randomUpgradeCost,
              onBuy: (context, buttonKey) {
                final state = GameState();
                if (state.gold >= GameConstants.randomUpgradeCost) {
                  state.addGold(-GameConstants.randomUpgradeCost);
                  final tags = ['Physical', 'Fire', 'Cold'];
                  final tag = tags[DateTime.now().second % 3];
                  state.upgradeTag(tag, 0.2);
                  _showFeedback(context, buttonKey, "$tag +20%!", GameColors.success, true);
                } else {
                  _showFeedback(context, buttonKey, "Not enough Gold!", GameColors.error, false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showFeedback(
    BuildContext context,
    GlobalKey<PixelButtonState> buttonKey,
    String message,
    Color color,
    bool isSuccess,
  ) {
    // ボタンのフィードバック
    if (isSuccess) {
      buttonKey.currentState?.flashSuccess();
    } else {
      buttonKey.currentState?.flashError();
    }

    // ボタンの位置を取得してフローティングテキストを表示
    final renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      FloatingFeedback.show(
        context,
        message,
        color: color,
        position: Offset(position.dx - 20, position.dy - 30),
      );
    }
  }
}

/// アーティファクトアイテム
class _ShopArtifactItem extends StatefulWidget {
  final ArtifactData artifact;
  final int cost;

  const _ShopArtifactItem({required this.artifact, required this.cost});

  @override
  State<_ShopArtifactItem> createState() => _ShopArtifactItemState();
}

class _ShopArtifactItemState extends State<_ShopArtifactItem> {
  final _buttonKey = GlobalKey<PixelButtonState>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, _) {
        final state = GameState();
        final isOwned = state.hasArtifact(widget.artifact);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PixelText(widget.artifact.name, fontSize: 14, color: isOwned ? GameColors.textSecondary : GameColors.warning),
                    PixelText(widget.artifact.description, fontSize: 10, color: GameColors.textSecondary),
                    PixelText(isOwned ? "OWNED" : "${widget.cost} G", fontSize: 12, color: isOwned ? GameColors.textSecondary : GameColors.accent),
                  ],
                ),
              ),
              PixelButton(
                key: _buttonKey,
                label: isOwned ? "OWNED" : "BUY",
                enabled: !isOwned,
                onPressed: () => _onBuy(context, state),
                width: 80,
                height: 30,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBuy(BuildContext context, GameState state) {
    if (state.gold < widget.cost) {
      ShopMenu._showFeedback(context, _buttonKey, "Not enough Gold!", GameColors.error, false);
      return;
    }
    if (!state.hasEmptyArtifactSlot) {
      ShopMenu._showFeedback(context, _buttonKey, "No slots!", GameColors.error, false);
      return;
    }
    state.addGold(-widget.cost);
    state.equipArtifact(widget.artifact);
    ShopMenu._showFeedback(context, _buttonKey, "Equipped!", GameColors.success, true);
  }
}

/// ボールアイテム
class _ShopBallItem extends StatefulWidget {
  final ItemData item;
  final int cost;

  const _ShopBallItem({required this.item, required this.cost});

  @override
  State<_ShopBallItem> createState() => _ShopBallItemState();
}

class _ShopBallItemState extends State<_ShopBallItem> {
  final _buttonKey = GlobalKey<PixelButtonState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PixelText(widget.item.name, fontSize: 16),
                PixelText(widget.item.description,
                    fontSize: 10, color: GameColors.textSecondary),
                PixelText("${widget.cost} G", fontSize: 12, color: GameColors.accent),
              ],
            ),
          ),
          PixelButton(
            key: _buttonKey,
            label: "BUY",
            onPressed: () => _onBuy(context),
            width: 80,
            height: 30,
          ),
        ],
      ),
    );
  }

  void _onBuy(BuildContext context) {
    final state = GameState();
    if (state.gold >= widget.cost) {
      state.addGold(-widget.cost);
      state.addBall(widget.item);
      ShopMenu._showFeedback(context, _buttonKey, "+1 ${widget.item.name}!", GameColors.success, true);
    } else {
      ShopMenu._showFeedback(context, _buttonKey, "Not enough Gold!", GameColors.error, false);
    }
  }
}

/// ユーティリティアイテム
class _ShopUtilityItem extends StatefulWidget {
  final String name;
  final int cost;
  final void Function(BuildContext, GlobalKey<PixelButtonState>) onBuy;

  const _ShopUtilityItem({
    required this.name,
    required this.cost,
    required this.onBuy,
  });

  @override
  State<_ShopUtilityItem> createState() => _ShopUtilityItemState();
}

class _ShopUtilityItemState extends State<_ShopUtilityItem> {
  final _buttonKey = GlobalKey<PixelButtonState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PixelText(widget.name, fontSize: 16),
                PixelText("${widget.cost} G", fontSize: 12, color: GameColors.accent),
              ],
            ),
          ),
          PixelButton(
            key: _buttonKey,
            label: "BUY",
            onPressed: () => widget.onBuy(context, _buttonKey),
            width: 80,
            height: 30,
          ),
        ],
      ),
    );
  }
}
