import 'package:flutter/material.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/widgets/flame_game_board.dart';
import 'package:snake_classic/widgets/score_popup.dart';

/// Isolated widget for score popups - its own setState only rebuilds
/// the popup layer, not the entire game screen.
class ScorePopupLayer extends StatefulWidget {
  const ScorePopupLayer({super.key});

  @override
  State<ScorePopupLayer> createState() => ScorePopupLayerState();
}

class ScorePopupLayerState extends State<ScorePopupLayer> {
  final ScorePopupManager _scorePopupManager = ScorePopupManager();
  Size? _boardSize;
  Offset? _boardOffset;

  @override
  void initState() {
    super.initState();
    // Pre-resolve board metrics after the first frame renders, so the
    // expensive element tree walk happens before any food is eaten.
    // Previously this was lazy (on first food), causing a visible pause.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveBoardMetrics();
    });
  }

  void addPopup({
    required Food food,
    required int points,
    required int boardWidth,
    required int boardHeight,
    double comboMultiplier = 1.0,
  }) {
    // Ensure metrics are resolved (fast no-op if already cached)
    if (_boardSize == null || _boardOffset == null) {
      _resolveBoardMetrics();
    }
    if (_boardSize == null || _boardOffset == null) return;

    final cellWidth = _boardSize!.width / boardWidth;
    final cellHeight = _boardSize!.height / boardHeight;

    final screenX = _boardOffset!.dx + (food.position.x + 0.5) * cellWidth;
    final screenY = _boardOffset!.dy + (food.position.y + 0.5) * cellHeight;

    final color = switch (food.type) {
      FoodType.normal => Colors.red,
      FoodType.bonus => Colors.amber,
      FoodType.special => Colors.purple,
    };

    final displayMultiplier =
        comboMultiplier >= 1.5 ? comboMultiplier.round() : 1;

    setState(() {
      _scorePopupManager.addPopup(
        points: points,
        position: Offset(screenX, screenY),
        color: color,
        multiplier: displayMultiplier,
      );
    });
  }

  void _resolveBoardMetrics() {
    if (_boardSize != null && _boardOffset != null) return;

    // Find the FlameGameBoard render object via the element tree.
    void visitor(Element element) {
      if (_boardSize != null && _boardOffset != null) return;
      if (element.widget is FlameGameBoard) {
        final box = element.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          _boardSize = box.size;
          _boardOffset = box.localToGlobal(Offset.zero);
        }
        return;
      }
      element.visitChildren(visitor);
    }

    context.visitAncestorElements((element) {
      if (element.widget is Stack) {
        element.visitChildren(visitor);
        return _boardSize == null;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _scorePopupManager.activePopups.map((popupData) {
        return ScorePopup(
          key: ValueKey(popupData.id),
          points: popupData.points,
          multiplier: popupData.multiplier,
          position: popupData.position,
          color: popupData.color,
          onComplete: () {
            setState(() {
              _scorePopupManager.removePopup(popupData.id);
            });
          },
        );
      }).toList(),
    );
  }
}
