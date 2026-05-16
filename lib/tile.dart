import 'package:flutter/material.dart';
import 'game.dart';

class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: letter.isEmpty ? Colors.grey.shade300 : Colors.grey.shade600,
          width: letter.isEmpty ? 1 : 2,
        ),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow.shade700,
          HitType.miss => Colors.grey.shade500,
          _ => Colors.grey.shade50,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: hitType == HitType.none ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }
}
