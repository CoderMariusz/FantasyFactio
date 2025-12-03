# Epic 5: Mobile-First UX - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, mobile, ux, performance -->

**Epic:** EPIC-05 - Mobile-First UX
**Total SP:** 29
**Duration:** 2 weeks (Sprints 6-7)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-05-tech-spec.md](epic-05-tech-spec.md)

**Prerequisites:**
- ✅ EPIC-00 (Project Setup)
- ✅ EPIC-01 (Core Gameplay Loop)
- ✅ EPIC-02 (Tier 1 Economy - UI foundations)

**Design Philosophy:** "Touch-first, not touch-adapted" - gra zaprojektowana od podstaw dla mobile.

---

## STORY-05.1: Touch Controls System (5 SP)

### Objective
Implement comprehensive touch control system with tap, long-press, swipe, pinch, and double-tap gestures.

### User Story
As a mobile player, I want intuitive touch controls so I can navigate and interact with my factory naturally using standard mobile gestures.

### Description
Touch controls are the primary input mechanism. All gestures must respond within 50ms and feel native to mobile users who are familiar with standard gesture patterns.

### Acceptance Criteria

#### AC1: Tap Gesture
```
✅ Single tap (< 200ms duration):
   - Select building
   - Collect resources
   - Press buttons
   - Response time: <50ms to visual feedback

✅ Tap detection:
   - Minimum tap target: 44×44px (Apple HIG)
   - Tap anywhere on building hitbox
   - Visual feedback: Flash white (50ms)
```

#### AC2: Long-Press Gesture
```
✅ Long-press (≥ 500ms hold):
   - Show tooltip with building details
   - Trigger haptic feedback at 500ms
   - Cancel if finger moves > 10px

✅ Tooltip content:
   - Building name and level
   - Current production status
   - Storage contents
   - Upgrade cost
```

#### AC3: Swipe Gesture
```
✅ One-finger swipe:
   - Pan camera across 50×50 grid
   - Threshold: Start after 10px movement
   - Smooth 60 FPS panning

✅ Momentum/inertia:
   - On finger release: Continue with velocity
   - Deceleration curve: ease-out
   - Duration: 300-500ms based on velocity
```

#### AC4: Pinch Gesture
```
✅ Two-finger pinch:
   - Zoom camera: 0.5× - 2.0× range
   - Pinch center: Zoom focal point
   - Smooth 60 FPS zooming

✅ Zoom levels:
   - 0.5×: Planning mode (see entire factory)
   - 1.0×: Default view
   - 1.5×: Build mode (detailed)
   - 2.0×: Maximum zoom
```

#### AC5: Double-Tap Gesture
```
✅ Double-tap (two taps < 300ms apart):
   - Recenter camera to factory center (25, 25)
   - Reset to Build mode (1.5× zoom)
   - Animation duration: 400ms ease-in-out
   - Haptic feedback on trigger
```

#### AC6: Unit Tests Pass
```
✅ Test: Tap detected within 200ms
✅ Test: Long-press triggers at 500ms
✅ Test: Swipe threshold 10px
✅ Test: Pinch zoom clamps to 0.5-2.0
✅ Test: Double-tap within 300ms window
✅ Test: Gesture conflicts resolved (tap vs long-press)
✅ Test: Response time <50ms
```

### Implementation Notes

**Files to Create:**
- `lib/game/input/touch_controller.dart` - Gesture detection
- `lib/game/input/gesture_detector_wrapper.dart` - Flutter GestureDetector
- `test/game/input/touch_controller_test.dart` - Tests

**Gesture Detector Setup:**
```dart
GestureDetector(
  onTapDown: _onTapDown,
  onLongPress: _onLongPress,
  onPanStart: _onPanStart,
  onPanUpdate: _onPanUpdate,
  onPanEnd: _onPanEnd,
  onScaleStart: _onScaleStart,
  onScaleUpdate: _onScaleUpdate,
  onDoubleTap: _onDoubleTap,
  child: GameWidget(game: game),
)
```

**Dependencies:**
- EPIC-01 Game loop

**Blocks:**
- STORY-05.2 (Camera uses gestures)

---

## STORY-05.2: Camera System (5 SP)

### Objective
Implement GridCamera with dual zoom modes, smooth animations, pan bounds, and momentum.

### User Story
As a player, I want to easily navigate my factory with smooth camera controls so I can view the whole factory or focus on specific buildings.

### Description
The camera system provides two main modes: Planning (0.5×) for overview and Build (1.5×) for interaction. All camera movements must be smooth and respect grid boundaries.

### Acceptance Criteria

#### AC1: GridCamera Entity
```dart
✅ GridCamera class:
   - position: Point<double> (center in grid coords)
   - zoomLevel: double (0.5 - 2.0)
   - currentMode: ZoomMode (planning/build)
   - viewportSize: Size (screen pixels)
   - gridBounds: Rect (0, 0, 50, 50)

✅ Computed properties:
   - viewport: Visible area rectangle
   - isVisible(component): Culling check
```

#### AC2: Zoom Modes
```
✅ Planning Mode (0.5×):
   - Shows entire 50×50 grid
   - Buildings appear small (overview)
   - Ideal for conveyor planning
   - Toggle button: Map icon

✅ Build Mode (1.5×):
   - Buildings 60×60px (easily tappable)
   - Detailed view for interaction
   - Default mode on game start
   - Toggle button: Build icon
```

#### AC3: Smooth Animations
```
✅ Zoom animation:
   - Duration: 300ms
   - Curve: ease-in-out
   - Maintains focal point

✅ Pan animation (recenter):
   - Duration: 400ms
   - Curve: ease-in-out
   - Smooth position interpolation

✅ Mode toggle:
   - Animate zoom level change
   - Haptic feedback at start
   - Button icon swaps
```

#### AC4: Pan Bounds
```
✅ Bounds checking:
   - Camera position clamped to 0-50 range
   - Cannot pan outside grid
   - Elastic effect at edges (optional)

✅ Implementation:
   position.x.clamp(0.0, 50.0)
   position.y.clamp(0.0, 50.0)
```

#### AC5: Momentum/Inertia
```
✅ On pan release:
   - Capture finger velocity
   - Apply momentum animation
   - Decelerate over 300-500ms
   - Respect bounds during momentum

✅ Velocity handling:
   - High velocity: Longer momentum
   - Low velocity: Short momentum
   - Bounds collision: Stop at edge
```

#### AC6: Unit Tests Pass
```
✅ Test: Zoom clamps to 0.5-2.0
✅ Test: Pan bounds respected
✅ Test: Zoom animation 300ms
✅ Test: Recenter animation 400ms
✅ Test: Mode toggle changes zoom
✅ Test: Momentum applies on release
✅ Test: isVisible() culling correct
```

### Implementation Notes

**Files to Create:**
- `lib/game/camera/grid_camera.dart` - Camera entity
- `lib/game/camera/camera_controller.dart` - Control logic
- `lib/game/camera/zoom_mode.dart` - Mode enum
- `test/game/camera/grid_camera_test.dart` - Tests

**Animation Controller:**
```dart
final _zoomController = AnimationController(
  duration: Duration(milliseconds: 300),
  vsync: this,
);

void animateZoom(double targetZoom) {
  final tween = Tween(begin: zoomLevel, end: targetZoom);
  _zoomController.forward(from: 0);
}
```

**Dependencies:**
- STORY-05.1 (Touch controls)

**Blocks:**
- STORY-05.4 (Performance uses camera culling)

---

## STORY-05.3: Haptic Feedback System (2 SP)

### Objective
Implement HapticService with light, medium, heavy impacts and user preferences.

### User Story
As a player, I want tactile feedback when I interact with the game so my actions feel responsive and satisfying.

### Description
Haptic feedback adds a physical dimension to interactions. Different actions trigger different intensities, and users can disable haptics in settings.

### Acceptance Criteria

#### AC1: Impact Patterns
```dart
✅ HapticService class:
   - lightImpact() - 10ms: Resource collect, button tap
   - mediumImpact() - 20ms: Upgrade complete, milestone
   - heavyImpact() - 30ms: Major events (reserved)
   - selectionClick(): Selection changes
   - error(): Short vibrate for failures

✅ Usage mapping:
   - Tap building: lightImpact()
   - Collect resource: lightImpact()
   - Upgrade building: mediumImpact()
   - Tier unlock: mediumImpact()
   - Failed action: No haptic (silent failure)
```

#### AC2: Platform Integration
```
✅ Android:
   - HapticFeedback.lightImpact()
   - HapticFeedback.mediumImpact()
   - HapticFeedback.heavyImpact()

✅ iOS:
   - UIImpactFeedbackGenerator (light/medium/heavy)
   - Fallback to vibrate() if unsupported

✅ Abstraction:
   - HapticService wraps platform differences
   - Same API on both platforms
```

#### AC3: User Preferences
```
✅ Settings toggle:
   - "Enable Haptic Feedback" switch
   - Default: enabled
   - Persists to SharedPreferences

✅ Service respects setting:
   - If disabled: All methods no-op
   - No platform calls when disabled
```

#### AC4: Unit Tests Pass
```
✅ Test: lightImpact() calls platform API
✅ Test: Disabled setting skips calls
✅ Test: Preference persists across sessions
✅ Test: All impact types work
✅ Test: Error case handles gracefully
```

### Implementation Notes

**Files to Create:**
- `lib/core/services/haptic_service.dart` - Service
- `test/core/services/haptic_service_test.dart` - Tests

**Implementation:**
```dart
class HapticService {
  static bool _isEnabled = true;

  static void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }

  static Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('haptics_enabled') ?? true;
  }
}
```

**Dependencies:**
- SharedPreferences package

**Blocks:**
- All touch interactions use haptics

---

## STORY-05.4: Performance Optimization (6 SP)

### Objective
Implement sprite batching, spatial culling, object pooling, and auto-quality reduction for 60 FPS.

### User Story
As a player on a budget device, I want the game to run smoothly at 60 FPS so I have a great experience regardless of my phone's specs.

### Description
Performance optimization ensures 60 FPS on budget devices (Snapdragon 660). Techniques include batching draw calls, culling off-screen objects, pooling sprites, and auto-reducing quality when FPS drops.

### Acceptance Criteria

#### AC1: Sprite Batching
```dart
✅ ConveyorBatch class:
   - Groups all conveyors into single draw call
   - Uses Canvas.drawAtlas() for efficiency
   - Separate batches: horizontal vs vertical

✅ Performance gain:
   - 50 conveyors: 1 draw call (not 50)
   - Reduces GPU state changes
   - Maintains 60 FPS
```

#### AC2: Spatial Culling
```
✅ CullingSystem:
   - Track camera viewport
   - Only render visible components + 1 tile buffer
   - Skip update() for off-screen components

✅ Implementation:
   - camera.isVisible(component) check
   - Buffer margin: 1 tile (prevent pop-in)
   - Update margin based on zoom level
```

#### AC3: Object Pooling
```dart
✅ ResourceSpritePool:
   - acquire(type): Get sprite from pool or create new
   - release(sprite): Return to pool for reuse
   - prewarm(type, count): Pre-create sprites

✅ Benefits:
   - No GC pauses from sprite creation
   - Constant memory usage
   - Smooth animations
```

#### AC4: Auto-Quality Reduction
```
✅ PerformanceMonitor:
   - Track FPS over last 60 frames (1 second)
   - FPS < 45 for 1 second: Reduce quality
   - FPS > 55 for 1 second: Restore quality

✅ Quality reduction:
   - Disable shadows
   - Reduce particle count (20 → 10)
   - Increase culling margin (less off-screen)

✅ Quality restoration:
   - Re-enable shadows
   - Restore particle count
   - Restore culling margin
```

#### AC5: Frame Budget
```
✅ 60 FPS = 16.67ms per frame:
   - Input: 2ms (12%)
   - Game logic: 4ms (24%)
   - Rendering: 8ms (48%)
   - Flutter UI: 2ms (12%)
   - Buffer: 0.67ms (4%)

✅ Profiling:
   - Firebase Performance Monitoring
   - FPS histogram tracking
   - Frame time percentiles
```

#### AC6: Unit Tests Pass
```
✅ Test: Batching renders 50 conveyors in 1 call
✅ Test: Culling skips off-screen components
✅ Test: Pool reuses sprites correctly
✅ Test: Quality reduces when FPS < 45
✅ Test: Quality restores when FPS > 55
✅ Test: Frame budget meets 16.67ms target
```

### Implementation Notes

**Files to Create:**
- `lib/game/rendering/conveyor_batch.dart` - Batching
- `lib/game/rendering/culling_system.dart` - Culling
- `lib/game/rendering/resource_sprite_pool.dart` - Pooling
- `lib/game/systems/performance_monitor.dart` - FPS tracking
- `test/game/systems/performance_monitor_test.dart` - Tests

**Benchmark Test:**
```dart
test('60 FPS with 50 conveyors + 10 buildings', () async {
  // Add components
  // Run 30 seconds
  // Assert avgFPS >= 55
});
```

**Dependencies:**
- STORY-05.2 (Camera for culling)

**Blocks:**
- Nothing (performance layer)

---

## STORY-05.5: One-Handed UI Layout (4 SP)

### Objective
Implement mobile-optimized UI layout with bottom toolbar, top HUD, and bottom-anchored modals.

### User Story
As a player using my phone one-handed, I want all important controls within thumb reach so I can play comfortably.

### Description
80% of UI should be in thumb-reachable zones. Bottom toolbar for actions, top HUD for info (read-only), modals anchored to bottom.

### Acceptance Criteria

#### AC1: Bottom Toolbar
```
✅ 5 buttons in bottom toolbar:
   - Build: Place buildings
   - Conveyor: Conveyor mode
   - Market: NPC trading
   - Stats: Production stats
   - Settings: Game settings

✅ Button specifications:
   - Size: 56×56dp minimum
   - Spacing: 8dp between
   - Position: Bottom 80px of screen
   - Touch target: 48×48dp minimum
```

#### AC2: Top HUD
```
✅ Read-only information:
   - Gold count (left side)
   - Resource counts (right side)
   - No interactive buttons in top area

✅ Layout:
   - Height: 48-64dp
   - Safe area: Respects notch/status bar
   - Semi-transparent background
```

#### AC3: Modal Dialogs
```
✅ Bottom-anchored modals:
   - Slide up from bottom
   - Easy thumb reach for buttons
   - Swipe down to dismiss

✅ Modal types:
   - Building details
   - Upgrade confirmation
   - NPC trade dialog
   - Settings panel
```

#### AC4: Thumb Zone Compliance
```
✅ Thumb heatmap zones:
   - Green (easy): Bottom 40% of screen
   - Yellow (stretch): Middle 30%
   - Red (hard): Top 30%

✅ Critical actions in green zone:
   - Build button
   - Confirm/Cancel buttons
   - Primary actions
```

#### AC5: Responsive Layout
```
✅ Screen size adaptation:
   - Small phones (< 5.5"): Compact spacing
   - Medium phones (5.5-6.2"): Normal spacing
   - Large phones (> 6.2"): Extra spacing

✅ Safe areas:
   - Respect notch (iPhone)
   - Respect gesture bar (Android)
   - Use MediaQuery.padding
```

#### AC6: Unit Tests Pass
```
✅ Test: Toolbar buttons in bottom 80px
✅ Test: No buttons in top 100px
✅ Test: Modal anchored to bottom
✅ Test: Touch targets ≥ 48dp
✅ Test: Safe areas respected
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/widgets/bottom_toolbar.dart` - Toolbar
- `lib/presentation/widgets/top_hud.dart` - HUD
- `lib/presentation/widgets/bottom_modal.dart` - Modal base
- `test/presentation/widgets/bottom_toolbar_test.dart` - Tests

**Layout Structure:**
```dart
Stack(
  children: [
    GameWidget(game: game), // Full screen
    Positioned(top: 0, child: TopHUD()),
    Positioned(bottom: 0, child: BottomToolbar()),
  ],
)
```

**Dependencies:**
- Design system (STORY-05.6)

**Blocks:**
- All UI screens

---

## STORY-05.6: Animation System (4 SP)

### Objective
Implement resource collection, building upgrade, and floating text animations at 60 FPS.

### User Story
As a player, I want satisfying visual feedback when I collect resources and upgrade buildings so my actions feel impactful.

### Description
Animations provide immediate visual feedback. Resource collection shows sprites flying to inventory, upgrades show sparkles and glow, floating text confirms actions.

### Acceptance Criteria

#### AC1: Resource Collection Animation
```
✅ Animation flow:
   1. Tap building → Sprite spawns at building center
   2. Sprite flies to inventory bar (300ms ease-out)
   3. Inventory count increments with pop effect
   4. "+X Resource" floating text appears

✅ Specifications:
   - Duration: 300ms
   - Curve: ease-out
   - Uses object pooling (no GC)
```

#### AC2: Building Upgrade Animation
```
✅ Animation flow:
   1. Upgrade confirmed → Sparkle particles burst
   2. Building glows green (500ms)
   3. "+20% production" floating text
   4. Medium haptic feedback

✅ Specifications:
   - Particle count: 20 sparkles
   - Glow color: successGreen
   - Glow duration: 500ms
```

#### AC3: Floating Text
```
✅ Floating text behavior:
   - Appears at source position
   - Floats up 40px over 800ms
   - Fades out during last 200ms
   - Auto-removes after animation

✅ Text types:
   - Resource gain: "+5 Wood" (white)
   - Gold gain: "+10g" (gold color)
   - Upgrade: "+20% production" (green)
   - Error: "Not enough gold" (red)
```

#### AC4: Zoom Mode Animation
```
✅ Zoom toggle animation:
   - Duration: 300ms
   - Curve: ease-in-out
   - Smooth zoom level change
   - Button icon animates (rotate/swap)
```

#### AC5: 60 FPS Requirement
```
✅ All animations maintain 60 FPS:
   - Use GPU-accelerated transforms
   - Object pooling for sprites
   - No heavy calculations during animation
   - Reduced motion mode: Skip to end state
```

#### AC6: Unit Tests Pass
```
✅ Test: Collection animation 300ms duration
✅ Test: Upgrade particles spawn correctly
✅ Test: Floating text fades out
✅ Test: Reduced motion skips animation
✅ Test: 60 FPS during animations
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/animations/animation_system.dart` - Core
- `lib/presentation/animations/resource_collection.dart` - Collection
- `lib/presentation/animations/upgrade_effect.dart` - Upgrade
- `lib/presentation/widgets/floating_text.dart` - Text
- `test/presentation/animations/animation_system_test.dart` - Tests

**Animation Controller:**
```dart
static void animateResourceCollection({
  required Building building,
  required Resource resource,
  required VoidCallback onComplete,
}) {
  final sprite = ResourceSpritePool.instance.acquire(resource.type);
  // Tween animation from building to inventory
}
```

**Dependencies:**
- STORY-05.4 (Object pooling)

**Blocks:**
- All interactive feedback

---

## STORY-05.7: Accessibility Features (3 SP)

### Objective
Implement colorblind modes, large text mode, reduced motion, and gesture alternatives for WCAG AAA compliance.

### User Story
As a player with accessibility needs, I want customizable visual and interaction options so I can enjoy the game comfortably.

### Description
Accessibility features ensure the game is playable by everyone. WCAG AAA contrast (7:1), colorblind support, scalable text, and alternatives to gestures.

### Acceptance Criteria

#### AC1: Colorblind Modes
```
✅ Three modes:
   - Deuteranopia (red-green, most common)
   - Protanopia (red-green, less common)
   - Tritanopia (blue-yellow, rare)

✅ Implementation:
   - Palette adjustments per mode
   - All game colors transformed
   - Settings toggle per mode
```

#### AC2: Large Text Mode
```
✅ Text scaling:
   - Normal: 1.0× scale
   - Large: 1.15× scale (+2sp effect)
   - Applies to all game text

✅ Implementation:
   - AccessibilityService.getFontScale()
   - All TextStyles use scale multiplier
   - UI layouts accommodate larger text
```

#### AC3: Reduced Motion Mode
```
✅ Animation handling:
   - All animations skip to end state
   - Duration = 0ms
   - No particles or effects
   - Instant state changes

✅ Implementation:
   - AccessibilityService.getAnimationDuration()
   - Returns Duration.zero if enabled
   - All animations check this
```

#### AC4: Gesture Alternatives
```
✅ Alternative controls:
   - D-pad overlay for camera pan
   - +/- buttons for zoom
   - Tap-only mode (no gestures required)

✅ Settings:
   - "Show gesture alternatives" toggle
   - Overlay appears when enabled
   - Can use both gestures and alternatives
```

#### AC5: Contrast Compliance
```
✅ WCAG AAA (7:1 ratio):
   - All text meets 7:1 contrast
   - Critical UI elements meet 7:1
   - Measured with contrast checker tools

✅ Color palette:
   - Dark backgrounds: #1E1E1E
   - Light text: #FFFFFF
   - All combinations verified
```

#### AC6: Unit Tests Pass
```
✅ Test: Colorblind mode transforms colors
✅ Test: Large text scales correctly
✅ Test: Reduced motion returns zero duration
✅ Test: Gesture alternatives appear when enabled
✅ Test: All colors meet 7:1 contrast
```

### Implementation Notes

**Files to Create:**
- `lib/core/services/accessibility_service.dart` - Service
- `lib/core/constants/colorblind_palettes.dart` - Color transforms
- `lib/presentation/widgets/gesture_alternatives.dart` - D-pad/zoom
- `test/core/services/accessibility_service_test.dart` - Tests

**Accessibility Service:**
```dart
class AccessibilityService {
  static ColorblindMode _colorblindMode = ColorblindMode.none;
  static bool _largeTextEnabled = false;
  static bool _reducedMotionEnabled = false;

  static Color adjustColor(Color original) {
    switch (_colorblindMode) {
      case ColorblindMode.deuteranopia:
        return _adjustForDeuteranopia(original);
      // ...
    }
  }
}
```

**Dependencies:**
- Design system (colors)

**Blocks:**
- Final polish

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-05.1** | 5 | Touch Controls | EPIC-01 |
| **STORY-05.2** | 5 | Camera System | 05.1 |
| **STORY-05.3** | 2 | Haptic Feedback | - |
| **STORY-05.4** | 6 | Performance | 05.2 |
| **STORY-05.5** | 4 | One-Handed UI | - |
| **STORY-05.6** | 4 | Animation System | 05.4 |
| **STORY-05.7** | 3 | Accessibility | - |
| **TOTAL** | **29 SP** | Mobile-First UX | - |

---

## Implementation Order

**Recommended Sprint 6-7:**

**Week 1:** Core Systems
1. STORY-05.1: Touch Controls (5 SP)
2. STORY-05.2: Camera System (5 SP)
3. STORY-05.3: Haptic Feedback (2 SP)

**Week 2:** Polish & Performance
4. STORY-05.4: Performance Optimization (6 SP)
5. STORY-05.5: One-Handed UI (4 SP)
6. STORY-05.6: Animation System (4 SP)
7. STORY-05.7: Accessibility (3 SP)

---

## Success Metrics

**After EPIC-05 Complete:**
- ✅ Tap response <50ms
- ✅ All tap targets ≥44×44px
- ✅ 60 FPS sustained on Snapdragon 660
- ✅ Camera pan/zoom smooth (60 FPS)
- ✅ Haptic feedback working on iOS/Android
- ✅ One-handed UI: 80% in thumb zone
- ✅ WCAG AAA contrast (7:1)
- ✅ Colorblind modes functional
- ✅ Animations maintain 60 FPS

**Quality Metrics:**
- Tap accuracy: 95%+
- User satisfaction: Native feel
- Crash rate: <1%
- Memory: <150 MB

**When EPIC-05 Complete:**
- Overall Progress: ~48% (170/289 SP)
- Professional mobile experience
- Differentiator from desktop ports
- Ready for public testing

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 1.0
**Next Review:** After STORY-05.1 complete
