// lib/widgets/promptgram_chip.dart
import 'package:flutter/material.dart';
import '../models/promptgram.dart';

class PromptgramChip extends StatelessWidget {
  final Promptgram promptgram;
  final bool selected;
  final VoidCallback? onTap;

  const PromptgramChip({
    super.key,
    required this.promptgram,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(promptgram.name),
      selected: selected,
      onSelected: (_) => onTap?.call(),
    );
  }
}
