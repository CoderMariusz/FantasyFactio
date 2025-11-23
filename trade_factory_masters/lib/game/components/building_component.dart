import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../domain/entities/building.dart';
import '../../domain/entities/player_economy.dart';
import '../../domain/usecases/collect_resources.dart';
import 'grid_component.dart';

/// Building sprite component for Trade Factory Masters
/// Renders buildings on the isometric grid with tap detection and animations
class BuildingComponent extends PositionComponent with TapCallbacks {
  final Building building;
  final GridConfig gridConfig;
  final Function(Building, CollectResourcesResult)? onResourcesCollected;
  final PlayerEconomy playerEconomy;

  /// Current visual state
  bool _isCollecting = false;
  double _pulseScale = 1.0;

  BuildingComponent({
    required this.building,
    required this.gridConfig,
    required this.playerEconomy,
    this.onResourcesCollected,
  }) : super(
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Convert grid position to screen coordinates
    final screenPos = gridConfig.gridToScreen(
      building.gridPosition.x,
      building.gridPosition.y,
    );

    position = screenPos;

    // Set size based on building type and level
    size = _calculateBuildingSize();

    debugPrint(
      '✅ BuildingComponent loaded: ${building.type} L${building.level} at grid(${building.gridPosition.x},${building.gridPosition.y}) -> screen($position)',
    );
  }

  /// Calculate building size based on type and level
  Vector2 _calculateBuildingSize() {
    // Base size is tile size
    final baseWidth = gridConfig.tileWidth * 0.8;
    final baseHeight = gridConfig.tileHeight * 1.5;

    // Scale slightly with level (10% increase at max level)
    final levelScale = 1.0 + (building.level - 1) * 0.01;

    return Vector2(baseWidth * levelScale, baseHeight * levelScale);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply pulse scale for animation
    canvas.save();
    canvas.scale(_pulseScale, _pulseScale);

    // Draw building placeholder (will be replaced with sprites)
    _renderBuildingPlaceholder(canvas);

    // Draw level indicator
    _renderLevelIndicator(canvas);

    canvas.restore();
  }

  /// Render building placeholder (procedural graphics until sprites are loaded)
  void _renderBuildingPlaceholder(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );

    // Color based on building type
    final buildingColor = _getBuildingColor();

    // Draw building body (isometric box)
    final paint = Paint()
      ..color = buildingColor
      ..style = PaintingStyle.fill;

    // Draw main building shape (rounded rectangle for now)
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    // Draw outline
    final outlinePaint = Paint()
      ..color = buildingColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      outlinePaint,
    );

    // Draw building icon/symbol based on type
    _renderBuildingIcon(canvas);

    // Draw activity indicator if building is producing
    if (building.isActive && !_isCollecting) {
      _renderActivityIndicator(canvas);
    }
  }

  /// Get building color based on type
  Color _getBuildingColor() {
    switch (building.type) {
      case BuildingType.collector:
        return const Color(0xFF8B4513); // Brown
      case BuildingType.processor:
        return const Color(0xFF4169E1); // Royal Blue
      case BuildingType.storage:
        return const Color(0xFF228B22); // Forest Green
      case BuildingType.conveyor:
        return const Color(0xFFFF8C00); // Dark Orange
      case BuildingType.market:
        return const Color(0xFF9370DB); // Medium Purple
    }
  }

  /// Render building type icon
  void _renderBuildingIcon(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getBuildingIcon(),
        style: TextStyle(
          fontSize: size.x * 0.4,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  /// Get icon for building type
  String _getBuildingIcon() {
    switch (building.type) {
      case BuildingType.collector:
        return '⛏️';
      case BuildingType.processor:
        return '⚙️';
      case BuildingType.storage:
        return '📦';
      case BuildingType.conveyor:
        return '➡️';
      case BuildingType.market:
        return '💰';
    }
  }

  /// Render activity indicator (pulsing dot)
  void _renderActivityIndicator(Canvas canvas) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulseAlpha = (0.5 + 0.5 * (now % 2.0 / 2.0));

    final indicatorPaint = Paint()
      ..color = Colors.green.withOpacity(pulseAlpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2 - 5, -size.y / 2 + 5),
      4,
      indicatorPaint,
    );
  }

  /// Render level indicator
  void _renderLevelIndicator(Canvas canvas) {
    final levelText = 'L${building.level}';
    final textPainter = TextPainter(
      text: TextSpan(
        text: levelText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2,
        size.y / 2 - textPainter.height - 5,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (_isCollecting) return; // Prevent double-tap

    debugPrint('🔨 Building tapped: ${building.type} L${building.level}');

    // Trigger resource collection
    _collectResources();

    // Play pulse animation
    _playPulseAnimation();
  }

  /// Collect resources from this building
  void _collectResources() {
    _isCollecting = true;

    final useCase = CollectResourcesUseCase();
    final result = useCase.execute(
      economy: playerEconomy,
      building: building,
    );

    debugPrint(
      '💰 Resources collected: ${result.resourcesCollected} ${building.production.resourceType} (capped: ${result.wasCapped})',
    );

    // Show floating text animation
    _showFloatingText(result.resourcesCollected, building.production.resourceType);

    // Notify callback
    onResourcesCollected?.call(building, result);

    _isCollecting = false;
  }

  /// Play pulse animation on tap
  void _playPulseAnimation() {
    // Scale effect: grow to 1.2x then back to 1.0x
    final scaleEffect = ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(
        duration: 0.15,
        reverseDuration: 0.15,
        curve: Curves.easeInOut,
      ),
    );

    add(scaleEffect);
  }

  /// Show floating text animation ("+X Resource")
  void _showFloatingText(double amount, String resourceType) {
    final floatingText = FloatingTextComponent(
      text: '+${amount.toStringAsFixed(1)} $resourceType',
      startPosition: position + Vector2(0, -size.y / 2),
    );

    parent?.add(floatingText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update pulse scale (smooth interpolation)
    if (_pulseScale != 1.0) {
      _pulseScale += (1.0 - _pulseScale) * dt * 5;
      if ((_pulseScale - 1.0).abs() < 0.01) {
        _pulseScale = 1.0;
      }
    }
  }
}

/// Floating text component for resource collection feedback
class FloatingTextComponent extends TextComponent {
  static const double floatDistance = 50.0;
  static const double floatDuration = 1.5;

  FloatingTextComponent({
    required String text,
    required Vector2 startPosition,
  }) : super(
          text: text,
          position: startPosition,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Float up and fade out
    final moveEffect = MoveEffect.by(
      Vector2(0, -floatDistance),
      EffectController(
        duration: floatDuration,
        curve: Curves.easeOut,
      ),
    );

    final fadeEffect = OpacityEffect.fadeOut(
      EffectController(
        duration: floatDuration,
        curve: Curves.easeIn,
      ),
      onComplete: () {
        removeFromParent();
      },
    );

    add(moveEffect);
    add(fadeEffect);
  }
}
