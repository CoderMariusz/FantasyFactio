import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'domain/entities/resource.dart';
import 'domain/entities/building.dart';
import 'domain/entities/player_economy.dart';
import 'game/components/grid_component.dart';
import 'game/camera/grid_camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(ResourceAdapter());
  Hive.registerAdapter(ResourceTypeAdapter());
  Hive.registerAdapter(BuildingAdapter());
  Hive.registerAdapter(BuildingTypeAdapter());
  Hive.registerAdapter(GridPositionAdapter());
  Hive.registerAdapter(PlayerEconomyAdapter());
  Hive.registerAdapter(ProductionConfigAdapter());
  Hive.registerAdapter(UpgradeConfigAdapter());

  debugPrint('✅ Hive initialized with 8 adapters registered');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Test Firebase Auth (Anonymous Sign-In)
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    debugPrint('✅ Firebase Auth Success! User ID: ${userCredential.user?.uid}');
  } catch (e) {
    debugPrint('❌ Firebase Auth Error: $e');
  }

  runApp(
    GameWidget(
      game: TradeFactoryGame(),
    ),
  );
}

/// Trade Factory Masters - Isometric factory builder game
/// Features: 50x50 grid, dual-zoom camera, gesture controls
class TradeFactoryGame extends FlameGame {
  late GridComponent gridComponent;
  late GridCamera gridCamera;
  late CameraInfoDisplay cameraInfoDisplay;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configure camera for isometric world
    final gridConfig = const GridConfig(
      gridWidth: 50,
      gridHeight: 50,
      tileWidth: 64.0,
      tileHeight: 32.0,
      showGridLines: true,
    );

    // Calculate world bounds
    final worldBounds = gridConfig.getWorldBounds();

    // Setup camera configuration
    final cameraConfig = GridCameraConfig(
      worldSize: Vector2(worldBounds.width, worldBounds.height),
      minZoom: 0.3,
      maxZoom: 2.0,
      zoomTransitionDuration: 0.3,
      panSpeed: 1.0,
      enableBounds: true,
      boundsPadding: 300.0,
    );

    // Create grid component
    gridComponent = GridComponent(config: gridConfig);
    world.add(gridComponent);

    // Create camera controller
    gridCamera = GridCamera(
      config: cameraConfig,
      initialZoomLevel: ZoomLevel.strategic,
    );
    world.add(gridCamera);

    // Position camera at center of grid
    camera.viewfinder.position = gridConfig.gridToScreen(25, 25);
    camera.viewfinder.zoom = ZoomLevel.strategic.zoom;

    // Add FPS counter
    camera.viewport.add(
      FpsTextComponent(
        position: Vector2(10, 10),
      ),
    );

    // Add camera info display
    cameraInfoDisplay = CameraInfoDisplay(
      position: Vector2(10, 40),
      gridCamera: gridCamera,
      gridComponent: gridComponent,
    );
    camera.viewport.add(cameraInfoDisplay);

    // Add instructions
    camera.viewport.add(
      TextComponent(
        text: 'Double-tap: Toggle zoom | Drag: Pan | Pinch: Zoom',
        position: Vector2(10, size.y - 30),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );

    debugPrint('✅ Grid System initialized (50x50 isometric grid)');
    debugPrint('✅ Camera System initialized (dual-zoom with gestures)');
  }
}

/// Camera and performance info display
class CameraInfoDisplay extends PositionComponent with HasGameRef {
  final GridCamera gridCamera;
  final GridComponent gridComponent;

  CameraInfoDisplay({
    required super.position,
    required this.gridCamera,
    required this.gridComponent,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final state = gridCamera.getCameraState();
    final metrics = gridComponent.getPerformanceMetrics();

    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'monospace',
      ),
    );

    // Display camera state
    textPaint.render(
      canvas,
      'Zoom: ${state['zoomLevel']} (${state['currentZoom']?.toStringAsFixed(2)})',
      Vector2.zero(),
    );

    textPaint.render(
      canvas,
      'Position: ${state['position']}',
      Vector2(0, 20),
    );

    // Display performance metrics
    final cullRate = (metrics['cullRate'] as double * 100).toStringAsFixed(1);
    textPaint.render(
      canvas,
      'Tiles: ${metrics['renderedTiles']}/${metrics['totalTiles']} ($cullRate% culled)',
      Vector2(0, 40),
    );

    // Display animation status
    if (state['isAnimating'] == true) {
      final animTextPaint = TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      animTextPaint.render(
        canvas,
        '⚡ Animating...',
        Vector2(0, 60),
      );
    }
  }
}
