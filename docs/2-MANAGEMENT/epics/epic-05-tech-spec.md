# Epic 5: Mobile-First UX - Technical Specification

**Epic:** EPIC-05 - Mobile-First UX
**Total SP:** 29
**Duration:** 1-2 weeks (Sprint 8, shared with EPIC-08)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03
**Author:** Mariusz (updated)

---

## Overview

EPIC-05 implementuje kompleksowy system Mobile-First UX dla Trade Factory Masters, zapewniając natywne doświadczenie mobilne z responsywnymi touch controls, haptic feedback, płynnymi animacjami (60 FPS), oraz accessibility features. Ten epic przekształca grę z prostego prototypu w profesjonalną aplikację mobilną, która czuje się naturalnie na touchscreenach.

Filozofia projektu: **"Touch-first, not touch-adapted"** - nie jest to port desktopowy z dodanymi gestami, ale gra zaprojektowana od podstaw dla mobile interaction patterns.

Kluczowe cele:
- Wszystkie tap targets minimum 44×44px (Apple HIG compliance)
- Tap response time <50ms (visual + haptic feedback)
- 60 FPS sustained gameplay na budget devices (Snapdragon 660)
- One-handed gameplay (80% UI w thumb-reachable zones)
- WCAG AAA accessibility compliance (7:1 contrast ratios)

System został zaprojektowany aby zapewnić maksymalną satysfakcję użytkownika i wyróżnić TFM od desktopowych portów które czują się niezgrabnie na mobile.

## Objectives and Scope

### In Scope

**Touch Controls:**
- ✅ Tap (single): Select building, collect resources, button press
- ✅ Long-press (500ms): Show tooltip with building details
- ✅ Swipe (1 finger): Pan camera across 50×50 grid
- ✅ Pinch (2 fingers): Zoom 0.5× - 2.0× range
- ✅ Double-tap: Recenter camera to factory center (25, 25)
- ✅ Tap response: <50ms visual feedback + haptic

**Haptic Feedback Patterns:**
- ✅ Light impact (10ms): Resource collect, button tap, selection
- ✅ Medium impact (20ms): Upgrade complete, milestone, Tier unlock
- ✅ Heavy impact (30ms): Reserved for major events
- ✅ No haptic: Failed actions (empty building, insufficient gold)
- ✅ User setting: Toggle to disable all haptics

**Camera System:**
- ✅ GridCamera with dual zoom modes (Planning 0.5× vs Build 1.5×)
- ✅ Smooth zoom animation (300ms ease-in-out)
- ✅ Pan with momentum/inertia on release
- ✅ Bounds checking (cannot pan outside 50×50 grid)
- ✅ Double-tap recenter (400ms smooth animation)

**Performance Optimization:**
- ✅ 60 FPS target (16.67ms frame budget)
- ✅ Sprite batching (all conveyors in single draw call)
- ✅ Spatial culling (only render visible tiles + 1-tile buffer)
- ✅ Object pooling (reuse ResourceSprite objects)
- ✅ Progressive quality reduction (auto-disable shadows/particles if FPS <45)

**One-Handed UI Layout:**
- ✅ Bottom toolbar: 5 buttons (Build, Conveyor, Market, Stats, Settings)
- ✅ Top HUD: Gold count, resource counts (read-only, no interaction)
- ✅ Modal dialogs: Bottom-anchored (easy to reach)
- ✅ No critical buttons in top corners (hard to reach one-handed)

**Accessibility:**
- ✅ WCAG AAA contrast ratios (7:1 minimum)
- ✅ Colorblind modes (deuteranopia, protanopia, tritanopia)
- ✅ Large text mode (+2sp to all text)
- ✅ Reduced motion mode (disable non-essential animations)
- ✅ Gesture alternatives (D-pad for pan, +/- buttons for zoom)

**Animation System:**
- ✅ Resource collection animation (200-400ms ease-out)
- ✅ Building upgrade animation (sparkles, glow, floating text)
- ✅ Zoom mode toggle animation (300ms)
- ✅ Floating text (success/error feedback)
- ✅ 60 FPS maintained during all animations

### Out of Scope

- ❌ Landscape mode optimization - future iteration (Month 3-4)
- ❌ Tablet-specific layouts - future iteration
- ❌ Desktop controls (keyboard/mouse) - Month 6-7 port
- ❌ Advanced gestures (3-finger swipe, etc.) - nie planowane
- ❌ Voice control - nie planowane
- ❌ Custom haptic patterns beyond basic - overkill dla Tier 1

## System Architecture Alignment

EPIC-05 integruje się z Clean Architecture oraz Flame Engine:

**Game Engine Layer (Flame):**
- `TradeFactoryGame` - główna klasa FlameGame with HasTappableComponents
- `GridCamera` - camera system z zoom modes
- `CameraController` - gesture handling dla pan/pinch/double-tap
- `TouchController` - wykrywa taps na buildings/UI

**Presentation Layer (Flutter):**
- `GameScreen` - główny widget z GameWidget + UI overlay
- Design system: Colors, Typography, Spacing (8-point grid)
- UI components: Buttons, Sliders, Tooltips
- Animation controllers: Resource collection, upgrade effects

**Performance Systems:**
- Sprite batching system (batch render conveyors)
- Culling system (render only visible components)
- Object pooling (ResourceSprite pool)
- Performance monitor (auto-reduce quality if FPS <45)

**Accessibility Layer:**
- `HapticService` - wrapper for platform haptics with enable/disable
- Colorblind modes (palette adjustments)
- Large text mode (font size scaling)
- Reduced motion mode (disable animations)

**Platform Integration:**
- Android: HapticFeedback API, MediaQuery
- iOS: UIImpactFeedbackGenerator, UIDevice
- Firebase Performance Monitoring (FPS tracking)

## Detailed Design

### Services and Modules

| Moduł | Odpowiedzialność | Input | Output | Owner |
|-------|------------------|-------|--------|-------|
| **GridCamera** | Camera system z zoom modes | Gestures | Camera position/zoom | Flame |
| **CameraController** | Gesture handling (pan/pinch/tap) | Touch events | Camera updates | Flame |
| **HapticService** | Haptic feedback patterns | Action type | Platform haptic | Core Utils |
| **PerformanceMonitor** | FPS tracking, quality reduction | Frame times | Quality settings | Game Systems |
| **SpriteBatch** | Batch rendering conveyors | Conveyor list | Single draw call | Flame |
| **CullingSystem** | Spatial culling | Viewport rect | Visible components | Flame |
| **ResourceSpritePool** | Object pooling | ResourceType | Reused sprites | Flame |
| **AnimationSystem** | Collection/upgrade animations | Action event | Tween animations | Presentation |
| **DesignSystem** | Colors, typography, spacing | - | Theme constants | Core Constants |
| **AccessibilityService** | A11y settings management | User preferences | A11y config | Core Utils |

### Data Models and Contracts

**GridCamera (Flame):**
```dart
class GridCamera extends Camera {
  Point<double> position;          // Camera center (x, y in grid coords)
  ZoomMode currentMode;            // Planning (0.5×) vs Build (1.5×)
  double zoomLevel;                // Current zoom (0.5 - 2.0)
  final Size viewportSize;         // Screen size in pixels
  final Rect gridBounds;           // 50×50 grid bounds

  // Computed properties
  Rect get viewport => Rect.fromCenter(
    center: Offset(position.x, position.y),
    width: viewportSize.width / zoomLevel,
    height: viewportSize.height / zoomLevel,
  );

  bool isVisible(Component component) {
    return viewport.overlaps(component.toRect());
  }
}

enum ZoomMode {
  planning,  // 0.5× zoom - view entire factory
  build,     // 1.5× zoom - tap buildings, collect resources
}
```

**CameraController:**
```dart
class CameraController {
  final GridCamera camera;
  Point<double>? _panStart;
  double? _initialZoom;

  // Gesture handlers
  void onPanStart(DragStartDetails details) {
    _panStart = _screenToGrid(details.localPosition);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_panStart == null) return;

    final current = _screenToGrid(details.localPosition);
    final delta = Point(
      _panStart!.x - current.x,
      _panStart!.y - current.y,
    );

    camera.position = _clampToBounds(
      Point(camera.position.x + delta.x, camera.position.y + delta.y),
    );
  }

  void onPanEnd(DragEndDetails details) {
    // Apply momentum/inertia
    final velocity = details.velocity.pixelsPerSecond;
    _animateMomentum(velocity);
  }

  void onScaleStart(ScaleStartDetails details) {
    _initialZoom = camera.zoomLevel;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale == 1.0) return;

    camera.zoomLevel = (_initialZoom! * details.scale).clamp(0.5, 2.0);
    camera.zoom = Vector2.all(camera.zoomLevel);
  }

  void toggleZoomMode() {
    final targetZoom = camera.currentMode == ZoomMode.planning ? 1.5 : 0.5;
    camera.animateZoom(targetZoom, Duration(milliseconds: 300));
    camera.currentMode = camera.currentMode == ZoomMode.planning
        ? ZoomMode.build
        : ZoomMode.planning;

    HapticService.lightImpact();
  }

  void doubleTapRecenter() {
    camera.panTo(Point(25.0, 25.0), Duration(milliseconds: 400));
    camera.animateZoom(1.5, Duration(milliseconds: 400)); // Build mode
  }

  Point<double> _screenToGrid(Offset screen) {
    // Convert screen pixels to grid coordinates
    final worldPos = camera.screenToWorld(screen);
    return Point(worldPos.x / tileSize, worldPos.y / tileSize);
  }

  Point<double> _clampToBounds(Point<double> position) {
    return Point(
      position.x.clamp(0.0, 50.0),
      position.y.clamp(0.0, 50.0),
    );
  }
}
```

**HapticService:**
```dart
class HapticService {
  static bool _isEnabled = true;

  static void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact(); // 10ms
  }

  static void mediumImpact() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact(); // 20ms
  }

  static void heavyImpact() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact(); // 30ms
  }

  static void selectionClick() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }

  static void error() {
    if (!_isEnabled) return;
    HapticFeedback.vibrate(); // Short vibrate
  }

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    // Save preference to SharedPreferences
  }

  static Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('haptics_enabled') ?? true;
  }
}
```

**PerformanceMonitor:**
```dart
class PerformanceMonitor {
  final List<double> _fpsHistory = [];
  bool _qualityReduced = false;

  void update(double fps) {
    _fpsHistory.add(fps);
    if (_fpsHistory.length > 60) {
      _fpsHistory.removeAt(0); // Keep last 60 frames (1 second)
    }

    final avgFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;

    if (avgFPS < 45 && !_qualityReduced) {
      _reduceQuality();
    } else if (avgFPS > 55 && _qualityReduced) {
      _restoreQuality();
    }
  }

  void _reduceQuality() {
    print('[Performance] FPS <45, reducing quality...');

    // Disable shadows
    RenderSettings.shadowsEnabled = false;

    // Reduce particle count
    ParticleSystem.maxParticles = 10; // Was 20

    // Increase culling margin (render fewer off-screen tiles)
    CullingSystem.margin = 0.5; // Was 1.0

    _qualityReduced = true;
  }

  void _restoreQuality() {
    print('[Performance] FPS >55, restoring quality...');

    RenderSettings.shadowsEnabled = true;
    ParticleSystem.maxParticles = 20;
    CullingSystem.margin = 1.0;

    _qualityReduced = false;
  }
}
```

**Design System Constants:**
```dart
// lib/core/constants/colors.dart
class AppColors {
  // Primary
  static const factoryBlue = Color(0xFF2E5CB8);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFF44336);
  static const gold = Color(0xFFFFD700);

  // Neutral
  static const darkGray = Color(0xFF1E1E1E);
  static const mediumGray = Color(0xFF424242);
  static const lightGray = Color(0xFFE0E0E0);
  static const offWhite = Color(0xFFF5F5F5);

  // Resource colors
  static const wood = Color(0xFF8D6E63);
  static const ore = Color(0xFF78909C);
  static const food = Color(0xFF66BB6A);
  static const bars = Color(0xFFFF8A65);
  static const tools = Color(0xFF42A5F5);
}

// lib/core/constants/typography.dart
class AppTypography {
  static const fontFamily = 'Roboto';

  static const display = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const title = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const subtitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
  static const label = TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
}

// lib/core/constants/spacing.dart
class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const s = 12.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

**AccessibilityService:**
```dart
class AccessibilityService {
  static ColorblindMode _colorblindMode = ColorblindMode.none;
  static bool _largeTextEnabled = false;
  static bool _reducedMotionEnabled = false;

  static Color adjustColor(Color original) {
    switch (_colorblindMode) {
      case ColorblindMode.deuteranopia:
        return _adjustForDeuteranopia(original);
      case ColorblindMode.protanopia:
        return _adjustForProtanopia(original);
      case ColorblindMode.tritanopia:
        return _adjustForTritanopia(original);
      case ColorblindMode.none:
        return original;
    }
  }

  static double getFontScale() {
    return _largeTextEnabled ? 1.15 : 1.0; // +2sp effect
  }

  static Duration getAnimationDuration(Duration normal) {
    return _reducedMotionEnabled ? Duration.zero : normal;
  }
}

enum ColorblindMode {
  none,
  deuteranopia,
  protanopia,
  tritanopia,
}
```

### APIs and Interfaces

**TradeFactoryGame (Flame):**
```dart
class TradeFactoryGame extends FlameGame with HasTappableComponents {
  late GridComponent grid;
  late GridCamera gridCamera;
  late CameraController cameraController;
  late PerformanceMonitor performanceMonitor;

  @override
  Future<void> onLoad() async {
    // Load sprites
    await SpriteLoader.loadAll();

    // Create 50×50 grid
    grid = GridComponent(size: 50);
    add(grid);

    // Setup camera
    gridCamera = GridCamera(
      position: Point(25.0, 25.0), // Start centered
      currentMode: ZoomMode.build,
      zoomLevel: 1.5,
      viewportSize: size,
      gridBounds: Rect.fromLTWH(0, 0, 50, 50),
    );
    camera = gridCamera;

    // Setup camera controls
    cameraController = CameraController(gridCamera);

    // Setup performance monitoring
    performanceMonitor = PerformanceMonitor();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update systems
    final conveyorSystem = ref.read(conveyorSystemProvider);
    conveyorSystem.updateResourceFlow(dt);

    // Monitor FPS
    final fps = 1.0 / dt;
    performanceMonitor.update(fps);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render order (back to front):
    // 1. Grid tiles
    // 2. Conveyors (batched)
    // 3. Buildings
    // 4. Resource sprites
    // 5. UI overlays
  }

  // Touch event handling
  @override
  void onTapDown(TapDownInfo info) {
    final gridPos = cameraController._screenToGrid(info.eventPosition.widget);
    final building = _findBuildingAt(gridPos);

    if (building != null) {
      HapticService.lightImpact();
      _handleBuildingTap(building);
    }
  }

  @override
  void onLongTapDown(TapDownInfo info) {
    final gridPos = cameraController._screenToGrid(info.eventPosition.widget);
    final building = _findBuildingAt(gridPos);

    if (building != null) {
      HapticService.mediumImpact();
      _showTooltip(building);
    }
  }

  @override
  void onDoubleTap() {
    cameraController.doubleTapRecenter();
  }
}
```

**Sprite Batching API:**
```dart
class ConveyorBatch {
  final List<ConveyorComponent> conveyors;
  final Image spriteSheet;

  void render(Canvas canvas, Camera camera) {
    // Cull off-screen conveyors
    final visible = conveyors.where((c) => camera.isVisible(c)).toList();

    if (visible.isEmpty) return;

    // Group by direction for optimal batching
    final horizontal = visible.where((c) => c.isHorizontal).toList();
    final vertical = visible.where((c) => !c.isHorizontal).toList();

    // Batch render (single draw call per group)
    _batchRender(canvas, horizontal);
    _batchRender(canvas, vertical);
  }

  void _batchRender(Canvas canvas, List<ConveyorComponent> group) {
    canvas.drawAtlas(
      spriteSheet,
      group.map((c) => c.transform).toList(),      // Transforms
      group.map((c) => c.sourceRect).toList(),     // Source rects
      null,                                        // Colors
      BlendMode.src,
      null,                                        // Cull rect
      Paint(),
    );
  }
}
```

**Object Pooling API:**
```dart
class ResourceSpritePool {
  final Map<ResourceType, List<ResourceSprite>> _pools = {};
  final List<ResourceSprite> _active = [];

  ResourceSprite acquire(ResourceType type) {
    final pool = _pools[type] ?? [];

    final sprite = pool.isEmpty
        ? ResourceSprite(type)        // Create new if pool empty
        : pool.removeLast();          // Reuse existing

    _active.add(sprite);
    return sprite;
  }

  void release(ResourceSprite sprite) {
    _active.remove(sprite);
    sprite.reset();                   // Clear state

    final pool = _pools[sprite.type] ?? [];
    pool.add(sprite);
    _pools[sprite.type] = pool;
  }

  void prewarm(ResourceType type, int count) {
    final pool = _pools[type] ?? [];
    for (int i = 0; i < count; i++) {
      pool.add(ResourceSprite(type));
    }
    _pools[type] = pool;
  }
}
```

**Animation System API:**
```dart
class AnimationSystem {
  // Resource collection animation
  static void animateResourceCollection({
    required Building building,
    required Resource resource,
    required VoidCallback onComplete,
  }) {
    final sprite = ResourceSpritePool.instance.acquire(resource.type);
    sprite.position = building.center;

    final tween = Tween<Offset>(
      begin: building.center,
      end: inventoryBarPosition,
    );

    final animation = tween.animate(
      CurvedAnimation(
        parent: AnimationController(
          duration: AccessibilityService.getAnimationDuration(
            Duration(milliseconds: 300),
          ),
          vsync: this,
        ),
        curve: Curves.easeOut,
      ),
    );

    animation.addListener(() {
      sprite.position = animation.value;
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ResourceSpritePool.instance.release(sprite);
        _showFloatingText('+${resource.amount} ${resource.displayName}');
        onComplete();
      }
    });

    animation.controller.forward();
  }

  // Building upgrade animation
  static void animateUpgrade({
    required Building building,
    required int newLevel,
  }) {
    // Sparkle particles
    ParticleSystem.burst(
      position: building.center,
      count: 20,
      color: AppColors.successGreen,
    );

    // Glow effect
    building.addEffect(GlowEffect(
      color: AppColors.successGreen,
      duration: Duration(milliseconds: 500),
    ));

    // Floating text
    _showFloatingText('+20% production', color: AppColors.gold);

    // Haptic
    HapticService.mediumImpact();
  }
}
```

### Workflows and Sequencing

**Sequence: Player Pans Camera**
```
1. User swipes finger across screen
   ↓
2. GestureDetector onPanStart() captures start position
   ↓
3. onPanUpdate() calculates delta (start - current)
   ↓
4. CameraController updates camera.position
   ↓
5. _clampToBounds() ensures position stays in 0-50 range
   ↓
6. onPanEnd() applies momentum/inertia
   ↓
7. Camera animates with deceleration curve
   ↓
8. Grid re-renders with new camera position (60 FPS)
   ↓
9. CullingSystem hides off-screen components
```

**Sequence: Player Pinch-Zooms**
```
1. User places two fingers on screen → pinch gesture
   ↓
2. GestureDetector onScaleStart() captures initial zoom
   ↓
3. onScaleUpdate() calculates scale factor (details.scale)
   ↓
4. CameraController updates camera.zoomLevel (clamped 0.5-2.0)
   ↓
5. camera.zoom = Vector2.all(zoomLevel)
   ↓
6. Zoom centers on pinch midpoint
   ↓
7. Grid re-renders with new zoom (60 FPS)
   ↓
8. Buildings scale accordingly (larger at higher zoom)
```

**Sequence: Player Double-Taps to Recenter**
```
1. User double-taps game canvas
   ↓
2. GestureDetector onDoubleTap() triggered
   ↓
3. CameraController.doubleTapRecenter() called
   ↓
4. camera.panTo(Point(25, 25), 400ms) - smooth animation
   ↓
5. camera.animateZoom(1.5, 400ms) - reset to Build mode
   ↓
6. Tween animation runs (ease-in-out curve)
   ↓
7. Camera position updates every frame (60 FPS)
   ↓
8. HapticService.lightImpact() at t=0ms
   ↓
9. Animation completes at t=400ms
```

**Sequence: Player Toggles Zoom Mode**
```
1. User taps zoom toggle button (top-right UI)
   ↓
2. onPressed() → CameraController.toggleZoomMode()
   ↓
3. Determine target zoom: Planning (0.5×) or Build (1.5×)
   ↓
4. camera.animateZoom(targetZoom, 300ms)
   ↓
5. Button icon swaps (Map ↔ Build icon)
   ↓
6. Tween animation runs (ease-in-out)
   ↓
7. Minimap fades in/out based on mode (300ms)
   ↓
8. HapticService.lightImpact() at t=0ms
   ↓
9. Animation completes at t=300ms
```

**Sequence: Resource Collection with Animation**
```
1. User taps building
   ↓
2. onTapDown() → _handleBuildingTap(building)
   ↓
3. CollectResourcesUseCase.execute() (business logic)
   ↓
4. HapticService.lightImpact() (immediate feedback)
   ↓
5. Building flash white (50ms highlight)
   ↓
6. ResourceSpritePool.acquire(resourceType) (t=100ms)
   ↓
7. Sprite spawns at building.center
   ↓
8. AnimationSystem.animateResourceCollection()
   ↓
9. Sprite moves to inventory bar (300ms ease-out)
   ↓
10. Inventory number increments with pop effect (t=300ms)
    ↓
11. "+X Resource" floating text appears (floats up 800ms)
    ↓
12. ResourceSpritePool.release(sprite) (cleanup)
    ↓
13. Background: Firestore sync (don't wait)
```

**Sequence: Performance Auto-Reduction**
```
1. PerformanceMonitor tracks FPS every frame
   ↓
2. FPS drops below 45 for 1 second (60 frames)
   ↓
3. _reduceQuality() triggered
   ↓
4. RenderSettings.shadowsEnabled = false
   ↓
5. ParticleSystem.maxParticles = 10 (was 20)
   ↓
6. CullingSystem.margin = 0.5 (render fewer off-screen tiles)
   ↓
7. FPS improves to 55+
   ↓
8. After 1 second at 55+ FPS: _restoreQuality()
   ↓
9. Settings restored to default
```

## Non-Functional Requirements

### Performance

**Frame Budget (60 FPS = 16.67ms per frame):**
- Input processing: 2ms (12%) - tap detection, gestures
- Game logic: 4ms (24%) - resource flow, A* pathfinding
- Rendering: 8ms (48%) - sprite rendering, animations
- Flutter UI: 2ms (12%) - HUD, buttons, modals
- Buffer: 0.67ms (4%) - safety margin

**Target Metrics:**
- **Sustained FPS:** 60 FPS for 30 minutes continuous play
- **Tap Response:** <50ms from tap to haptic feedback
- **Animation Smoothness:** 60 FPS during all animations (no frame drops)
- **Camera Performance:** 60 FPS during pan/zoom gestures
- **Collection Performance:** 60 FPS with 10 buildings collecting simultaneously

**Memory Budget:**
- App baseline: 80-100 MB
- Game assets: +50 MB (sprites, sounds)
- Runtime state: +20 MB (game state, components)
- **Total:** ~150 MB (safe for 2GB RAM devices)

**Benchmark Device:**
- Primary: Snapdragon 660 (budget Android, ~60% of users)
- Secondary: iPhone 8 (iOS baseline)
- All performance targets must pass on these devices

### Security

**Input Validation:**
- Gesture coordinates clamped to screen bounds
- Camera position clamped to 0-50 grid range
- Zoom level clamped to 0.5-2.0 range
- Prevent rapid-fire taps (debounce 100ms)

**Performance Protection:**
- Auto-quality reduction prevents device overheating
- FPS monitoring prevents battery drain
- Object pooling prevents memory leaks

### Reliability/Availability

**Gesture Reliability:**
- Tap detection: 95%+ accuracy (tested with user studies)
- Gesture conflicts resolved (tap vs long-press priority)
- No accidental triggers (swipe threshold 10px)

**Fallback Mechanisms:**
- Reduced Motion Mode: Animations → instant (0ms duration)
- Gesture Alternatives: D-pad for pan, +/- buttons for zoom
- Haptic Failure: Silent fallback (no error if haptics unsupported)

**Error Recovery:**
- Animation failures → skip to end state (no broken UI)
- Performance degradation → auto-reduce quality
- Camera out of bounds → auto-clamp to valid range

### Observability

**Performance Metrics (Firebase Performance):**
- FPS distribution (histogram: 0-30, 30-45, 45-55, 55-60, 60+)
- Frame time percentiles (p50, p95, p99)
- Tap response time (p95: <50ms target)
- Animation frame drops (count per session)

**User Interaction Metrics (Firebase Analytics):**
- `gesture_used`: {type: 'swipe'|'pinch'|'double_tap', duration}
- `zoom_mode_toggle`: {from_mode, to_mode}
- `haptic_disabled`: {user_preference: true/false}
- `accessibility_enabled`: {feature: 'large_text'|'reduced_motion'|'colorblind'}

**Device Metrics:**
- Device model distribution (Snapdragon 660, iPhone 8, etc.)
- Screen size distribution (5.5"-6.7")
- OS version distribution (Android 10-14, iOS 15-17)
- Performance tier classification (low/mid/high-end)

**Logging:**
- Debug: Gesture events, camera updates
- Info: Zoom mode toggles, quality reductions
- Warning: FPS drops below 45
- Error: Animation failures, haptic errors

## Dependencies and Integrations

### Internal Dependencies

**Required Before EPIC-05:**
- ✅ EPIC-00: Project Setup (Flutter, Flame configured)
- ✅ EPIC-01: Core Gameplay Loop (buildings, resources functional)

**Works With:**
- EPIC-02: Tier 1 Economy (tap to collect resources)
- EPIC-03: Tier 2 Automation (Planning Mode for conveyor layout)
- EPIC-04: Offline Production (animations work offline)

**Blocks:**
- All future epics depend on mobile UX being polished

### External Dependencies

**Flutter Packages:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.12.0                    # Game engine with gesture support
  flutter_riverpod: ^3.0.0          # State management
  shared_preferences: ^2.2.0        # Store haptic/a11y preferences

dev_dependencies:
  flutter_test:
    sdk: flutter
```

**Platform APIs:**
- **Android:** HapticFeedback, MediaQuery, SystemChrome
- **iOS:** UIImpactFeedbackGenerator, UIDevice

**Firebase Services:**
- Firebase Performance Monitoring (FPS tracking)
- Firebase Analytics (gesture usage tracking)
- Crashlytics (animation failure tracking)

**Assets:**
- Design system: Color palette, typography, spacing constants
- Icons: Build, Market, Settings, Zoom toggle icons
- Animations: Particle sprites for upgrade effects

### Integration Points

**Flame Engine:**
- `HasTappableComponents` mixin for tap detection
- `Camera` system for pan/zoom
- `GestureDetector` widget wrapper for gestures

**Flutter UI:**
- `GameWidget.controlled()` embeds Flame game
- Overlay widgets: Bottom toolbar, top HUD, modals
- Animation controllers: Tween animations for UI effects

**Platform Integration:**
- Haptic feedback: iOS UIImpactFeedbackGenerator, Android HapticFeedback
- Screen metrics: MediaQuery for responsive layouts
- Orientation lock: SystemChrome.setPreferredOrientations

## Acceptance Criteria (Authoritative)

### AC-1: Touch Controls Responsiveness
- [ ] Tap response time <50ms (measured with stopwatch)
- [ ] All tap targets minimum 44×44px (verified with ruler tool)
- [ ] Swipe gesture pans camera smoothly (60 FPS)
- [ ] Pinch gesture zooms smoothly (60 FPS)
- [ ] Double-tap recenters camera in 400ms
- [ ] Long-press shows tooltip after 500ms hold

### AC-2: Haptic Feedback
- [ ] Light impact on resource collect (10ms vibration)
- [ ] Medium impact on upgrade complete (20ms vibration)
- [ ] No haptic on failed actions (empty building, insufficient gold)
- [ ] User can disable haptics in Settings
- [ ] Haptics work on both iOS and Android

### AC-3: Camera System
- [ ] Zoom range: 0.5× - 2.0× (verified with logging)
- [ ] Planning Mode (0.5×) shows entire 50×50 grid
- [ ] Build Mode (1.5×) makes buildings 60×60px (tappable)
- [ ] Zoom toggle animates in 300ms (smooth ease-in-out)
- [ ] Pan bounds: Cannot go outside 0-50 grid range
- [ ] Momentum/inertia on pan release (smooth deceleration)

### AC-4: Performance - 60 FPS Target
- [ ] Sustained 60 FPS for 30 minutes on Snapdragon 660
- [ ] Performance test: 50 conveyors + 10 buildings + 20 resources = 60 FPS
- [ ] No frame drops during resource collection animation
- [ ] No frame drops during camera pan/zoom
- [ ] Auto-quality reduction triggers if FPS <45 for 1 second

### AC-5: One-Handed UI
- [ ] Bottom toolbar: All 5 buttons in thumb-reachable zone
- [ ] Top HUD: Read-only (no interactive buttons)
- [ ] Modal dialogs: Bottom-anchored (easy to reach)
- [ ] No critical buttons in top corners (verified with thumb heatmap)

### AC-6: Accessibility - WCAG AAA
- [ ] All text contrast ratios ≥ 7:1 (measured with contrast checker)
- [ ] Colorblind modes: deuteranopia, protanopia, tritanopia
- [ ] Large text mode: +2sp to all text
- [ ] Reduced motion mode: All animations skippable
- [ ] Gesture alternatives: D-pad for pan, +/- for zoom

### AC-7: Animation Quality
- [ ] Resource collection: 300ms smooth animation (ease-out curve)
- [ ] Building upgrade: Sparkles + glow + floating text
- [ ] Zoom mode toggle: 300ms smooth zoom
- [ ] Floating text: Appears within 100ms, floats up 800ms
- [ ] All animations maintain 60 FPS (no frame drops)

### AC-8: Memory & Stability
- [ ] Total app memory <150 MB (measured with DevTools)
- [ ] No memory leaks (object pooling verified)
- [ ] Crash rate <1% (measured with Crashlytics)
- [ ] No ANR (Application Not Responding) on Android

## Traceability Mapping

| AC | Spec Section | Components/APIs | Test Idea |
|----|--------------|-----------------|-----------|
| AC-1 | Touch Controls | CameraController, HasTappableComponents | Integration test: Tap building → response time <50ms |
| AC-2 | Haptic Feedback | HapticService | Unit test: Call lightImpact() → verify platform API called |
| AC-3 | Camera System | GridCamera, toggleZoomMode() | Integration test: Toggle → verify zoom changes to 0.5×/1.5× |
| AC-4 | Performance | PerformanceMonitor, sprite batching | Performance test: FPS counter overlay, 30min stress test |
| AC-5 | One-Handed UI | Bottom toolbar layout | Widget test: Verify all buttons in bottom 200px of screen |
| AC-6 | Accessibility | AccessibilityService, colorblind modes | Manual test: ColorOracle validation, screen reader testing |
| AC-7 | Animation Quality | AnimationSystem, Tween controllers | Widget test: Verify animation duration, curve type |
| AC-8 | Memory & Stability | ResourceSpritePool, object pooling | Performance test: DevTools memory profiler, leak detection |

## Risks, Assumptions, Open Questions

### Risks

**RISK-1: Performance on Low-End Devices**
- Snapdragon 660 może nie utrzymać 60 FPS z 50 conveyorami
- **Mitigation:** Progressive quality reduction, sprite batching, spatial culling
- **Severity:** High
- **Probability:** Medium

**RISK-2: Gesture Conflicts**
- Tap vs long-press mogą kolidować (user frustration)
- **Mitigation:** Long-press threshold 500ms (industry standard)
- **Severity:** Medium
- **Probability:** Low

**RISK-3: Haptic API Inconsistencies**
- iOS i Android mają różne haptic feedback patterns
- **Mitigation:** HapticService wrapper abstrahuje platformowe różnice
- **Severity:** Low
- **Probability:** Medium

**RISK-4: Animation Frame Drops**
- Złożone animacje (sparkles + glow + floating text) mogą powodować frame drops
- **Mitigation:** Object pooling, GPU-accelerated transforms only
- **Severity:** Medium
- **Probability:** Low

### Assumptions

**ASSUMPTION-1:** 80% graczy używa portrait mode (one-handed)
- Validated with: Market research (95% mobile games are portrait)

**ASSUMPTION-2:** Snapdragon 660 reprezentuje "budget device"
- Validated with: Device analytics (~60% users mają podobną spec)

**ASSUMPTION-3:** 60 FPS jest zauważalnie lepsze niż 30 FPS dla graczy
- Validated with: User studies (gamers prefer 60 FPS)

**ASSUMPTION-4:** Gracze preferują haptic feedback
- Validated with: Industry best practices (wszystkie top mobile games używają haptics)

### Open Questions

**Q1:** Czy landscape mode powinien być wspierany w Tier 1?
- **Recommendation:** Nie, defer do Month 3-4 iteration
- **Decision:** Zatwierdzone, portrait-only dla MVP

**Q2:** Czy pinch-to-zoom jest intuitive bez tutoriala?
- **Recommendation:** Tak, industry standard gesture (all users know it)
- **Decision:** Zatwierdzone, no tutorial needed

**Q3:** Czy Planning Mode (0.5× zoom) jest użyteczny przed Tier 2 (conveyors)?
- **Recommendation:** Tak, gracze lubią zobaczyć "whole factory view"
- **Decision:** Include w EPIC-05, testuj w playtest sessions

## Test Strategy Summary

### Test Pyramid

```
         ┌───────────────┐
        /  E2E Tests (5%) \
       /     - 8 tests     \
      ┌─────────────────────┐
     /  Integration (15%)   \
    /    - 25 tests          \
   ┌───────────────────────────┐
  /   Unit Tests (80%)         \
 /     - 100+ tests             \
└─────────────────────────────────┘
```

### Unit Tests (100+ tests)

**Camera System Tests:**
- `grid_camera_test.dart`: Verify zoom clamping, bounds checking (15 tests)
- `camera_controller_test.dart`: Test gesture handlers (20 tests)
  - Pan updates position correctly
  - Zoom clamps to 0.5-2.0 range
  - Double-tap recenters to (25, 25)
  - Bounds checking prevents out-of-range

**Haptic Service Tests:**
- `haptic_service_test.dart`: Mock platform API (10 tests)
  - lightImpact() calls platform API
  - Disabled state skips platform calls
  - Preference saves to SharedPreferences

**Performance Monitor Tests:**
- `performance_monitor_test.dart`: Quality reduction logic (12 tests)
  - FPS <45 for 1 second → reduces quality
  - FPS >55 for 1 second → restores quality
  - Quality reduction disables shadows, reduces particles

**Design System Tests:**
- `colors_test.dart`: Verify contrast ratios (8 tests)
- `accessibility_service_test.dart`: Colorblind mode adjustments (15 tests)

**Object Pooling Tests:**
- `resource_sprite_pool_test.dart`: Verify acquire/release (10 tests)
  - Acquire creates new sprite if pool empty
  - Acquire reuses sprite if available
  - Release returns sprite to pool

### Integration Tests (25 tests)

**Gesture Integration:**
- `pan_gesture_test.dart`: Swipe → verify camera position changes
- `pinch_gesture_test.dart`: Pinch → verify zoom level changes
- `double_tap_test.dart`: Double-tap → verify camera recenters

**Animation Integration:**
- `resource_collection_animation_test.dart`: Tap building → sprite flies to inventory
- `upgrade_animation_test.dart`: Upgrade → sparkles + glow appear

**Performance Integration:**
- `fps_stress_test.dart`: 50 conveyors + 10 buildings → verify 60 FPS
- `quality_reduction_test.dart`: Simulate low FPS → verify quality reduces

### E2E Tests (8 tests)

**Complete Gesture Flows:**
- `e2e_camera_navigation_test.dart`:
  1. Swipe to pan across grid
  2. Pinch to zoom out (Planning Mode)
  3. Pinch to zoom in (Build Mode)
  4. Double-tap to recenter
  5. Verify 60 FPS throughout

**Complete Collection Flow:**
- `e2e_collection_with_animation_test.dart`:
  1. Tap building
  2. Haptic feedback triggers
  3. Sprite animates to inventory (300ms)
  4. Inventory count updates
  5. Floating text appears

### Performance Tests

**FPS Benchmarks:**
```dart
test('60 FPS with 50 conveyors + 10 buildings', () async {
  final game = TradeFactoryGame();
  await game.onLoad();

  // Add 50 conveyors
  for (int i = 0; i < 50; i++) {
    game.add(ConveyorComponent(/* ... */));
  }

  // Add 10 buildings
  for (int i = 0; i < 10; i++) {
    game.add(BuildingComponent(/* ... */));
  }

  // Measure FPS over 30 seconds
  final fpsReadings = <double>[];
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsedMilliseconds < 30000) {
    final frameStart = DateTime.now();
    game.update(0.016);
    game.render(MockCanvas());
    final frameDuration = DateTime.now().difference(frameStart);

    fpsReadings.add(1000 / frameDuration.inMilliseconds);
    await Future.delayed(Duration(milliseconds: 16));
  }

  final avgFPS = fpsReadings.reduce((a, b) => a + b) / fpsReadings.length;

  expect(avgFPS, greaterThanOrEqualTo(55)); // Allow 5 FPS margin
});
```

**Tap Response Time:**
```dart
test('Tap response <50ms', () async {
  final stopwatch = Stopwatch()..start();

  // Tap building
  await tester.tap(find.byType(BuildingComponent));
  await tester.pump();

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(50));
});
```

### Manual Testing Checklist

**Device Testing:**
- [ ] Test on Snapdragon 660 Android device (budget)
- [ ] Test on Snapdragon 8 Gen 2 Android device (high-end)
- [ ] Test on iPhone 8 (iOS baseline)
- [ ] Test on iPhone 15 Pro (iOS high-end)

**Accessibility Testing:**
- [ ] ColorOracle validation (all colorblind modes)
- [ ] Screen reader testing (TalkBack on Android, VoiceOver on iOS)
- [ ] Large text mode testing (verify no UI breaks)
- [ ] Reduced motion mode testing (verify animations skip)

**Gesture Testing:**
- [ ] Tap accuracy: 95%+ successful taps on buildings
- [ ] Long-press: Tooltip appears after 500ms hold
- [ ] Swipe: Camera pans smoothly, momentum works
- [ ] Pinch: Zoom responds smoothly, no jitter
- [ ] Double-tap: Recenters camera reliably

**Performance Testing:**
- [ ] FPS overlay: Verify 60 FPS for 30 minutes
- [ ] DevTools memory profiler: Verify <150 MB
- [ ] Battery drain test: <10% per hour (reasonable)
- [ ] Device temperature: No overheating

### Test Coverage Target

- **Unit Tests:** 90%+ coverage
- **Integration Tests:** 80%+ coverage
- **E2E Tests:** Critical paths only
- **Overall:** 85%+ coverage

---

---

## UI Screen Specifications

Szczegółowe specyfikacje layoutów ekranów (Hub Screen, Grid World, Gathering, etc.) znajdują się w:
- `docs/sprint-artifacts/tech-spec-epic-02-UI.md`

Te ekrany implementują koncepty Mobile-First UX opisane w tym dokumencie (touch targets, one-handed UI, animations).

---

## Dependencies

**Depends On:**
- ✅ EPIC-00 (Project Setup)
- ✅ EPIC-01 (Core Gameplay Loop)
- ✅ EPIC-02 (Tier 1 Economy - UI screens)

**Blocks:**
- → Wszystkie przyszłe epiki zależą od polished mobile UX

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 2.0 (Merged to epics folder)
