import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/player_economy.dart';
import '../../config/game_config.dart';

/// Resource HUD - displays player resources at top of game screen
/// Shows: Gold, Wood, Stone, Iron with icons and amounts
class ResourceHUD extends PositionComponent {
  PlayerEconomy _economy;

  // Layout constants
  static const double _hudHeight = 50.0;
  static const double _iconSize = 24.0;
  static const double _itemSpacing = 20.0;
  static const double _iconTextGap = 6.0;

  ResourceHUD({
    required PlayerEconomy economy,
    required Vector2 screenSize,
  }) : _economy = economy,
       super(
         position: Vector2(0, 0),
         size: Vector2(screenSize.x, _hudHeight),
       );

  /// Update economy data
  void updateEconomy(PlayerEconomy economy) {
    _economy = economy;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw semi-transparent background
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      bgPaint,
    );

    // Draw bottom border
    final borderPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(0, size.y),
      Offset(size.x, size.y),
      borderPaint,
    );

    // Calculate starting x position (center the resources)
    final resources = _getDisplayResources();
    final totalWidth = _calculateTotalWidth(resources.length);
    double x = (size.x - totalWidth) / 2;

    // Render each resource
    for (final resource in resources) {
      _renderResourceItem(canvas, x, resource);
      x += _getItemWidth(resource) + _itemSpacing;
    }
  }

  /// Get resources to display in HUD
  List<_HudResource> _getDisplayResources() {
    return [
      _HudResource(
        icon: Icons.monetization_on,
        color: Colors.amber,
        amount: _economy.gold.toInt(),
        label: 'Gold',
      ),
      _HudResource(
        icon: Icons.park,
        color: Colors.brown,
        amount: _getResourceAmount(ResourceIds.wood),
        label: 'Wood',
      ),
      _HudResource(
        icon: Icons.landscape,
        color: Colors.grey,
        amount: _getResourceAmount(ResourceIds.stone),
        label: 'Stone',
      ),
      _HudResource(
        icon: Icons.hardware,
        color: Colors.blueGrey,
        amount: _getResourceAmount(ResourceIds.ironOre),
        label: 'Iron',
      ),
    ];
  }

  /// Get amount of a specific resource from inventory
  int _getResourceAmount(String resourceId) {
    final resource = _economy.inventory[resourceId];
    return resource?.amount.toInt() ?? 0;
  }

  /// Calculate total width of all resource items
  double _calculateTotalWidth(int itemCount) {
    // Approximate width per item
    final itemWidth = _iconSize + _iconTextGap + 50; // icon + gap + text
    return (itemWidth * itemCount) + (_itemSpacing * (itemCount - 1));
  }

  /// Get width of a single resource item
  double _getItemWidth(_HudResource resource) {
    return _iconSize + _iconTextGap + _estimateTextWidth(resource.amount);
  }

  /// Estimate text width based on number of digits
  double _estimateTextWidth(int amount) {
    final digits = amount.toString().length;
    return digits * 10.0 + 10.0; // ~10px per digit + padding
  }

  /// Render a single resource item (icon + amount)
  void _renderResourceItem(Canvas canvas, double x, _HudResource resource) {
    final centerY = size.y / 2;

    // Draw icon background circle
    final iconBgPaint = Paint()
      ..color = resource.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(x + _iconSize / 2, centerY),
      _iconSize / 2 + 2,
      iconBgPaint,
    );

    // Draw icon (using TextPainter for emoji/icon)
    final iconPaint = TextPaint(
      style: TextStyle(
        fontSize: _iconSize - 4,
        color: resource.color,
      ),
    );

    // Use emoji icons
    final iconText = _getResourceEmoji(resource.label);
    iconPaint.render(
      canvas,
      iconText,
      Vector2(x + 2, centerY - (_iconSize - 4) / 2),
    );

    // Draw amount text
    final amountPaint = TextPaint(
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final amountText = _formatAmount(resource.amount);
    amountPaint.render(
      canvas,
      amountText,
      Vector2(x + _iconSize + _iconTextGap, centerY - 8),
    );
  }

  /// Get emoji icon for resource type
  String _getResourceEmoji(String label) {
    switch (label) {
      case 'Gold':
        return '\u{1F4B0}'; // Money bag
      case 'Wood':
        return '\u{1FAB5}'; // Wood
      case 'Stone':
        return '\u{1FAA8}'; // Rock
      case 'Iron':
        return '\u{2699}';  // Gear (for iron/metal)
      default:
        return '\u{2753}'; // Question mark
    }
  }

  /// Format amount with K/M suffix for large numbers
  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}

/// Helper class for HUD resource display
class _HudResource {
  final IconData icon;
  final Color color;
  final int amount;
  final String label;

  const _HudResource({
    required this.icon,
    required this.color,
    required this.amount,
    required this.label,
  });
}
