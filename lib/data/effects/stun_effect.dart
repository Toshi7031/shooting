import 'dart:math';
import 'package:flutter/material.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import 'item_effect.dart';

class StunEffect extends ItemEffect {
  final double chance;
  final double duration;

  StunEffect({this.chance = 0.02, this.duration = 0.5});

  @override
  void onHit(Ball ball, BlockEnemy block) {
    if (Random().nextDouble() < chance) {
      block.applyStun(duration);
      debugPrint("StunEffect: Stunned enemy!");
    }
  }
}
