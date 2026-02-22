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

class ShopMenu extends StatefulWidget {
  final VoidCallback onClose;

  const ShopMenu({super.key, required this.onClose});

  @override
  State<ShopMenu> createState() => _ShopMenuState();

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
    final renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
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

class _ShopMenuState extends State<ShopMenu> {
  int _purchaseMultiplier = 1;

  @override
  Widget build(BuildContext context) {
    return BaseMenu(
      title: "SHOP",
      titleColor: GameColors.accent,
      onClose: widget.onClose,
      child: PixelScrollbar(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ボールセクション
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PixelText("-- BALLS --",
                    fontSize: 14, color: GameColors.textSecondary),
                Row(
                  children: [
                    _buildMultiplierButton(1),
                    const SizedBox(width: 4),
                    _buildMultiplierButton(10),
                    const SizedBox(width: 4),
                    _buildMultiplierButton(100),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ShopBallItem(
                item: ItemRepository.defaultBall,
                cost: 50,
                multiplier: _purchaseMultiplier),
            _ShopBallItem(
                item: ItemRepository.vampireOrb,
                cost: 250,
                multiplier: _purchaseMultiplier),
            _ShopBallItem(
                item: ItemRepository.explosiveOrb,
                cost: 150,
                multiplier: _purchaseMultiplier),

            const SizedBox(height: 16),
            // アーティファクトセクション
            const PixelText("-- ARTIFACTS --",
                fontSize: 14, color: GameColors.warning),
            const SizedBox(height: 8),
            _ShopArtifactItem(
                artifact: ArtifactRepository.headhunter, cost: 500),
            _ShopArtifactItem(
                artifact: ArtifactRepository.tabulaRasa, cost: 300),
            _ShopArtifactItem(
                artifact: ArtifactRepository.soulEater, cost: 400),
            _ShopArtifactItem(
                artifact: ArtifactRepository.berserkersRage, cost: 350),
            _ShopArtifactItem(
                artifact: ArtifactRepository.luckyCharm, cost: 300),

            const SizedBox(height: 16),
            // シンギュラリティ・マージ
            const PixelText("-- SINGULARITY MERGE --",
                fontSize: 14, color: GameColors.legendary), // legendary color?
            const SizedBox(height: 8),
            _SpecificMergeItem(
                tier1: ItemRepository.defaultBall,
                tier2: ItemRepository.juggernautSphere),
            _SpecificMergeItem(
                tier1: ItemRepository.vampireOrb,
                tier2: ItemRepository.bloodMoon),
            _SpecificMergeItem(
                tier1: ItemRepository.explosiveOrb,
                tier2: ItemRepository.supernova),

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
                if (state.gold >= GameConstants.healCost &&
                    state.coreHp < state.maxCoreHp) {
                  state.addGold(-GameConstants.healCost);
                  state.healCore(GameConstants.healAmount.toDouble());
                  ShopMenu._showFeedback(
                      context,
                      buttonKey,
                      "+${GameConstants.healAmount} HP",
                      GameColors.success,
                      true);
                } else if (state.coreHp >= state.maxCoreHp) {
                  ShopMenu._showFeedback(
                      context, buttonKey, "HP Full!", GameColors.accent, false);
                } else {
                  ShopMenu._showFeedback(context, buttonKey, "Not enough Gold!",
                      GameColors.error, false);
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

                  final upgrades = [
                    (tag: 'Physical', amount: 0.2, message: 'Physical +20%!'),
                    (tag: 'Fire', amount: 0.2, message: 'Fire +20%!'),
                    (tag: 'Cold', amount: 0.2, message: 'Cold +20%!'),
                    (tag: 'FireRate', amount: 0.1, message: 'Fire Rate +10%!'),
                    (tag: 'Pierce', amount: 1.0, message: 'Pierce +1!'),
                    (tag: 'Bounce', amount: 1.0, message: 'Bounce +1!'),
                  ];
                  final upgrade =
                      upgrades[DateTime.now().second % upgrades.length];

                  state.upgradeTag(upgrade.tag, upgrade.amount,
                      consumePoint: false);
                  ShopMenu._showFeedback(context, buttonKey, upgrade.message,
                      GameColors.success, true);
                } else {
                  ShopMenu._showFeedback(context, buttonKey, "Not enough Gold!",
                      GameColors.error, false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiplierButton(int value) {
    final isSelected = _purchaseMultiplier == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _purchaseMultiplier = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.accent : Colors.transparent,
          border: Border.all(color: GameColors.accent),
          borderRadius: BorderRadius.circular(4),
        ),
        child: PixelText(
          "x$value",
          fontSize: 10,
          color: isSelected ? Colors.black : GameColors.accent,
        ),
      ),
    );
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
                    PixelText(widget.artifact.name,
                        fontSize: 14,
                        color: isOwned
                            ? GameColors.textSecondary
                            : GameColors.warning),
                    PixelText(widget.artifact.description,
                        fontSize: 10, color: GameColors.textSecondary),
                    PixelText(isOwned ? "OWNED" : "${widget.cost} G",
                        fontSize: 12,
                        color: isOwned
                            ? GameColors.textSecondary
                            : GameColors.accent),
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
      ShopMenu._showFeedback(
          context, _buttonKey, "Not enough Gold!", GameColors.error, false);
      return;
    }
    if (!state.hasEmptyArtifactSlot) {
      ShopMenu._showFeedback(
          context, _buttonKey, "No slots!", GameColors.error, false);
      return;
    }
    state.addGold(-widget.cost);
    state.equipArtifact(widget.artifact);
    ShopMenu._showFeedback(
        context, _buttonKey, "Equipped!", GameColors.success, true);
  }
}

/// ボールアイテム
class _ShopBallItem extends StatefulWidget {
  final ItemData item;
  final int cost;
  final int multiplier;

  const _ShopBallItem({
    required this.item,
    required this.cost,
    this.multiplier = 1,
  });

  @override
  State<_ShopBallItem> createState() => _ShopBallItemState();
}

class _ShopBallItemState extends State<_ShopBallItem> {
  final _buttonKey = GlobalKey<PixelButtonState>();

  @override
  Widget build(BuildContext context) {
    final totalCost = widget.cost * widget.multiplier;

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
                Row(
                  children: [
                    PixelText("${widget.cost} G",
                        fontSize: 12, color: GameColors.accent),
                    if (widget.multiplier > 1)
                      PixelText(" x ${widget.multiplier} = $totalCost G",
                          fontSize: 12, color: GameColors.accent),
                  ],
                ),
              ],
            ),
          ),
          PixelButton(
            key: _buttonKey,
            label:
                "BUY${widget.multiplier > 1 ? ' x${widget.multiplier}' : ''}",
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
    final totalCost = widget.cost * widget.multiplier;

    if (state.gold >= totalCost) {
      state.addGold(-totalCost);
      state.addBalls(widget.item, widget.multiplier);
      ShopMenu._showFeedback(
          context,
          _buttonKey,
          "+${widget.multiplier} ${widget.item.name}!",
          GameColors.success,
          true);
    } else {
      ShopMenu._showFeedback(
          context, _buttonKey, "Not enough Gold!", GameColors.error, false);
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
                PixelText("${widget.cost} G",
                    fontSize: 12, color: GameColors.accent),
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

class _SpecificMergeItem extends StatefulWidget {
  final ItemData tier1;
  final ItemData tier2;

  const _SpecificMergeItem({
    required this.tier1,
    required this.tier2,
  });

  @override
  State<_SpecificMergeItem> createState() => _SpecificMergeItemState();
}

class _SpecificMergeItemState extends State<_SpecificMergeItem> {
  final _buttonKey = GlobalKey<PixelButtonState>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, _) {
        final state = GameState();
        final ownedCount =
            state.ballLoadout.where((b) => b.name == widget.tier1.name).length;
        final canMerge = ownedCount >= 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PixelText(widget.tier2.name,
                        fontSize: 16, color: GameColors.legendary),
                    PixelText(widget.tier2.description,
                        fontSize: 10, color: GameColors.textSecondary),
                    PixelText("Cost: 100 ${widget.tier1.name}",
                        fontSize: 10, color: GameColors.textSecondary),
                    PixelText("$ownedCount / 100",
                        fontSize: 12,
                        color:
                            canMerge ? GameColors.success : GameColors.error),
                  ],
                ),
              ),
              PixelButton(
                key: _buttonKey,
                label: "MERGE",
                enabled: canMerge,
                onPressed: () => _onMerge(context, state),
                width: 80,
                height: 30,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMerge(BuildContext context, GameState state) {
    if (state.requestSpecificMerge(widget.tier1, widget.tier2, 100)) {
      ShopMenu._showFeedback(context, _buttonKey,
          "Merge! +${widget.tier2.name}", GameColors.legendary, true);
    } else {
      ShopMenu._showFeedback(
          context, _buttonKey, "Not enough balls!", GameColors.error, false);
    }
  }
}
