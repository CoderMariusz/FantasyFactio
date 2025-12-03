import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/player_economy.dart';
import '../../domain/usecases/collect_resources.dart';
import 'grid_component.dart';

/// Building sprite component for Trade Factory Masters
/// Renders buildings on the isometric grid with tap detection and animations
class BuildingComponent extends PositionComponent with TapCallbacks {
  // Visual constants
  static const double _pulseMinAlpha = 0.5;
  static const double _pulseAmplitude = 0.5;
  static const double _pulseDuration = 2.0;
  static const double _indicatorOffsetX = 5.0;
  static const double _indicatorOffsetY = 5.0;
  static const double _indicatorRadius = 4.0;
  static const double _widthMultiplier = 0.8;
  static const double _heightMultiplier = 1.5;
  static const double _levelScaleIncrement = 0.01;
  static const double _pulseScaleMax = 1.2;
  static const double _pulseScaleDuration = 0.15;
  static const double _pulseInterpolationSpeed = 5.0;

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
    final baseWidth = gridConfig.tileWidth * _widthMultiplier;
    final baseHeight = gridConfig.tileHeight * _heightMultiplier;

    // Scale slightly with level (10% increase at max level)
    final levelScale = 1.0 + (building.level - 1) * _levelScaleIncrement;

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
      ..color = buildingColor.withValues(alpha: 0.8)
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

  /// Get building color based on type (6 building types)
  Color _getBuildingColor() {
    switch (building.type) {
      case BuildingType.mining:
        return const Color(0xFF8B4513); // Brown
      case BuildingType.smelter:
        return const Color(0xFF4169E1); // Royal Blue
      case BuildingType.storage:
        return const Color(0xFF228B22); // Forest Green
      case BuildingType.conveyor:
        return const Color(0xFFFF8C00); // Dark Orange
      case BuildingType.workshop:
        return const Color(0xFF9370DB); // Medium Purple
      case BuildingType.farm:
        return const Color(0xFFDAA520); // Goldenrod
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

  /// Get icon for building type (6 building types)
  String _getBuildingIcon() {
    switch (building.type) {
      case BuildingType.mining:
        return '⛏️';
      case BuildingType.smelter:
        return '🔥';
      case BuildingType.storage:
        return '📦';
      case BuildingType.conveyor:
        return '➡️';
      case BuildingType.workshop:
        return '⚙️';
      case BuildingType.farm:
        return '🌾';
    }
  }

  /// Render activity indicator (pulsing dot)
  void _renderActivityIndicator(Canvas canvas) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulseAlpha = (_pulseMinAlpha + _pulseAmplitude * (now % _pulseDuration / _pulseDuration));

    final indicatorPaint = Paint()
      ..color = Colors.green.withValues(alpha: pulseAlpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2 - _indicatorOffsetX, -size.y / 2 + _indicatorOffsetY),
      _indicatorRadius,
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
    final success = _collectResources();

    // Play pulse animation only if collection was successful
    if (success) {
      _playPulseAnimation();
    }
  }

  /// Collect resources from this building
  /// Returns true if collection was successful, false if too soon
  bool _collectResources() {
    _isCollecting = true;

    final useCase = CollectResourcesUseCase();
    final result = useCase.execute(
      economy: playerEconomy,
      building: building,
    );

    // Handle too soon case
    if (result.tooSoon) {
      debugPrint(
        '⏳ Too soon to collect! Wait ${result.secondsUntilNextCollection}s',
      );
      _showCooldownText(result.secondsUntilNextCollection ?? 0);
      _isCollecting = false;
      return false;
    }

    debugPrint(
      '💰 Resources collected: ${result.resourcesCollected} ${building.production.resourceType} (capped: ${result.wasCapped})',
    );

    // Show floating text animation
    _showFloatingText(result.resourcesCollected.toDouble(), building.production.resourceType);

    // Notify callback
    onResourcesCollected?.call(building, result);

    _isCollecting = false;
    return true;
  }

  /// Play pulse animation on tap
  void _playPulseAnimation() {
    // Scale effect: grow to 1.2x then back to 1.0x
    final scaleEffect = ScaleEffect.by(
      Vector2.all(_pulseScaleMax),
      EffectController(
        duration: _pulseScaleDuration,
        reverseDuration: _pulseScaleDuration,
        curve: Curves.easeInOut,
      ),
    );

    add(scaleEffect);
  }

  /// Show floating text animation ("+X Resource")
  void _showFloatingText(double amount, String resourceType) {
    final floatingText = FloatingTextComponent(
      text: '+${amount.toStringAsFixed(0)} $resourceType',
      startPosition: position + Vector2(0, -size.y / 2),
    );

    parent?.add(floatingText);
  }

  /// Show cooldown text when collection is attempted too soon
  void _showCooldownText(int secondsRemaining) {
    final floatingText = FloatingTextComponent(
      text: 'Wait ${secondsRemaining}s',
      startPosition: position + Vector2(0, -size.y / 2),
      color: const Color(0xFFFF9800), // Orange color for cooldown
    );

    parent?.add(floatingText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update pulse scale (smooth interpolation)
    if (_pulseScale != 1.0) {
      _pulseScale += (1.0 - _pulseScale) * dt * _pulseInterpolationSpeed;
      if ((_pulseScale - 1.0).abs() < 0.01) {
        _pulseScale = 1.0;
      }
    }
  }
}

/// Floating text component for resource collection feedback
class FloatingTextComponent extends TextComponent with HasPaint {
  static const double floatDistance = 50.0;
  static const double floatDuration = 1.5;
  final Color _textColor;

  FloatingTextComponent({
    required String text,
    required Vector2 startPosition,
    Color color = Colors.greenAccent,
  })  : _textColor = color,
        super(
          text: text,
          position: startPosition,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        );

  double _opacity = 1.0;
  double _elapsed = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Float up effect
    final moveEffect = MoveEffect.by(
      Vector2(0, -floatDistance),
      EffectController(
        duration: floatDuration,
        curve: Curves.easeOut,
      ),
    );

    add(moveEffect);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Manual fade out
    _elapsed += dt;
    _opacity = (1.0 - (_elapsed / floatDuration)).clamp(0.0, 1.0);

    // Update text color with new opacity
    textRenderer = TextPaint(
      style: TextStyle(
        color: _textColor.withValues(alpha: _opacity),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: _opacity),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );

    // Remove when fully faded
    if (_elapsed >= floatDuration) {
      removeFromParent();
    }
  }
}
