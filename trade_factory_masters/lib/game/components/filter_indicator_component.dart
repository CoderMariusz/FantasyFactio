import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../domain/entities/conveyor_tile.dart';

/// Filter indicator - visual icon showing filter mode on conveyor tile
/// Shows small icon in corner of tile indicating active filter
/// Green = Whitelist, Red = Blacklist, Blue = Single
class FilterIndicatorComponent extends PositionComponent {
  /// Current filter configuration
  ConveyorFilter filter;

  /// Size of indicator icon
  static const double iconSize = 16.0;

  /// Padding from tile corner
  static const double padding = 2.0;

  FilterIndicatorComponent({
    required this.filter,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(iconSize, iconSize),
  );

  /// Update filter configuration
  void updateFilter(ConveyorFilter newFilter) {
    filter = newFilter;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Don't render if no active filter
    if (filter.mode == FilterMode.allowAll) {
      return;
    }

    // Draw circular background
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      bgPaint,
    );

    // Draw icon based on filter mode
    _drawFilterIcon(canvas);

    // Draw border
    final borderPaint = Paint()
      ..color = _getModeColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      borderPaint,
    );
  }

  /// Draw icon for current filter mode
  void _drawFilterIcon(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final color = _getModeColor();
    const iconStrokeWidth = 2.0;

    switch (filter.mode) {
      case FilterMode.allowAll:
        // Should not reach here (filtered above)
        break;

      case FilterMode.whitelist:
        // Draw checkmark
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = iconStrokeWidth
          ..strokeCap = StrokeCap.round;

        final radius = size.x / 3;
        canvas.drawLine(
          Offset(center.dx - radius / 2, center.dy),
          Offset(center.dx - radius / 4, center.dy + radius / 2),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx - radius / 4, center.dy + radius / 2),
          Offset(center.dx + radius / 2, center.dy - radius / 3),
          paint,
        );
        break;

      case FilterMode.blacklist:
        // Draw X
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = iconStrokeWidth
          ..strokeCap = StrokeCap.round;

        final radius = size.x / 3;
        canvas.drawLine(
          Offset(center.dx - radius, center.dy - radius),
          Offset(center.dx + radius, center.dy + radius),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx + radius, center.dy - radius),
          Offset(center.dx - radius, center.dy + radius),
          paint,
        );
        break;

      case FilterMode.single:
        // Draw circle (representing single item)
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final radius = size.x / 4;
        canvas.drawCircle(center, radius, paint);
        break;
    }
  }

  /// Get color for filter mode
  Color _getModeColor() {
    switch (filter.mode) {
      case FilterMode.allowAll:
        return Colors.grey;
      case FilterMode.whitelist:
        return Colors.green;
      case FilterMode.blacklist:
        return Colors.red;
      case FilterMode.single:
        return Colors.blue;
    }
  }

  /// Create tooltip text describing filter
  String getTooltip() {
    switch (filter.mode) {
      case FilterMode.allowAll:
        return 'No filter - all items pass';
      case FilterMode.whitelist:
        final items = filter.resourceIds.join(', ');
        return 'Whitelist: $items';
      case FilterMode.blacklist:
        final items = filter.resourceIds.join(', ');
        return 'Blacklist: $items';
      case FilterMode.single:
        return 'Single: ${filter.singleResourceId}';
    }
  }
}
