import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'config/game_config.dart';
import 'domain/entities/resource.dart';
import 'domain/entities/building.dart';
import 'domain/entities/player_economy.dart';
import 'domain/usecases/collect_resources.dart';
import 'game/components/grid_component.dart';
import 'game/camera/grid_camera.dart';
import 'game/components/building_component.dart';

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

  // Initialize Firebase (optional - app works in offline mode if Firebase unavailable)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');

    // Test Firebase Auth (Anonymous Sign-In)
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint('✅ Firebase Auth Success! User ID: ${userCredential.user?.uid}');
    } catch (e) {
      debugPrint('⚠️ Firebase Auth Error (continuing in offline mode): $e');
    }
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed (continuing in offline mode): $e');
    debugPrint('ℹ️ App will run with local storage only (Hive)');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trade Factory Masters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Factory Masters'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Trade Factory Masters!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Screen'),
      ),
      body: Center(
        child: GameWidget(
          game: TradeFactoryGame(),
        ),
      ),
    );
  }
}

/// Trade Factory Masters - Isometric factory builder game
/// Features: 50x50 grid, dual-zoom camera, gesture controls
class TradeFactoryGame extends FlameGame {
  late GridComponent gridComponent;
  late GridCamera gridCamera;
  late CameraInfoDisplay cameraInfoDisplay;
  late PlayerEconomy playerEconomy;
  final List<BuildingComponent> buildingComponents = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configure camera for isometric world
    final gridConfig = const GridConfig(
      gridWidth: GridConstants.gridWidth,
      gridHeight: GridConstants.gridHeight,
      tileWidth: GridConstants.tileWidth,
      tileHeight: GridConstants.tileHeight,
      showGridLines: GridConstants.showGridLines,
    );

    // Calculate world bounds
    final worldBounds = gridConfig.getWorldBounds();

    // Setup camera configuration
    final cameraConfig = GridCameraConfig(
      worldSize: Vector2(worldBounds.width, worldBounds.height),
      minZoom: CameraConstants.minZoom,
      maxZoom: CameraConstants.maxZoom,
      zoomTransitionDuration: CameraConstants.zoomTransitionDuration,
      panSpeed: CameraConstants.panSpeed,
      enableBounds: true,
      boundsPadding: CameraConstants.boundsPadding,
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
        position: Vector2(DisplayConstants.fpsCounterX, DisplayConstants.fpsCounterY),
      ),
    );

    // Add camera info display
    cameraInfoDisplay = CameraInfoDisplay(
      position: Vector2(DisplayConstants.cameraInfoX, DisplayConstants.cameraInfoY),
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

    // Initialize player economy with starting resources
    playerEconomy = PlayerEconomy(
      gold: EconomyConstants.startingGold,
      inventory: {},
      buildings: [],
      tier: EconomyConstants.startingTier,
      lastSeen: DateTime.now(),
    );

    // Add test buildings to the game
    _addTestBuildings(gridConfig);

    debugPrint('✅ Player economy initialized (1000 gold, ${buildingComponents.length} buildings)');
  }

  /// Add test buildings for BATCH 4 demonstration
  void _addTestBuildings(GridConfig gridConfig) {
    final testBuildings = [
      // Mining at (10, 10) - Wood Mining
      Building(
        id: 'building_1',
        type: BuildingType.mining,
        level: 1,
        gridPosition: const GridPosition(x: 10, y: 10),
        production: const ProductionConfig(
          baseRate: 5.0,
          resourceType: ResourceIds.wood,
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 100,
          costIncrement: 50,
          maxLevel: 10,
        ),
        lastCollected: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      ),
      // Smelter at (15, 10) - Processes ore
      Building(
        id: 'building_2',
        type: BuildingType.smelter,
        level: 3,
        gridPosition: const GridPosition(x: 15, y: 10),
        production: const ProductionConfig(
          baseRate: 3.0,
          resourceType: ResourceIds.ironBar,
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 150,
          costIncrement: 75,
          maxLevel: 10,
        ),
        lastCollected: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
      ),
      // Storage at (20, 10)
      Building(
        id: 'building_3',
        type: BuildingType.storage,
        level: 2,
        gridPosition: const GridPosition(x: 20, y: 10),
        production: const ProductionConfig(
          baseRate: 0.0,
          resourceType: 'None', // Storage doesn't produce
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 200,
          costIncrement: 100,
          maxLevel: 10,
        ),
        lastCollected: DateTime.now(),
        isActive: true,
      ),
      // Mining at (10, 15) - Stone Mining
      Building(
        id: 'building_4',
        type: BuildingType.mining,
        level: 5,
        gridPosition: const GridPosition(x: 10, y: 15),
        production: const ProductionConfig(
          baseRate: 4.0,
          resourceType: ResourceIds.stone,
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 100,
          costIncrement: 50,
          maxLevel: 10,
        ),
        lastCollected: DateTime.now().subtract(const Duration(minutes: 30)),
        isActive: true,
      ),
      // Farm at (25, 25) - Converts items to gold
      Building(
        id: 'building_5',
        type: BuildingType.farm,
        level: 1,
        gridPosition: const GridPosition(x: 25, y: 25),
        production: const ProductionConfig(
          baseRate: 2.0,
          resourceType: ResourceIds.gold,
        ),
        upgradeConfig: const UpgradeConfig(
          baseCost: 500,
          costIncrement: 250,
          maxLevel: 10,
        ),
        lastCollected: DateTime.now().subtract(const Duration(hours: 5)),
        isActive: true,
      ),
    ];

    // Create BuildingComponents and add to world
    for (final building in testBuildings) {
      final component = BuildingComponent(
        building: building,
        gridConfig: gridConfig,
        playerEconomy: playerEconomy,
        onResourcesCollected: _onResourcesCollected,
      );

      world.add(component);
      buildingComponents.add(component);

      // Update player economy with building
      playerEconomy = playerEconomy.copyWith(
        buildings: [...playerEconomy.buildings, building],
      );
    }
  }

  /// Handle resource collection callback
  void _onResourcesCollected(Building building, CollectResourcesResult result) {
    // Update player economy
    playerEconomy = result.economy;

    debugPrint(
      '💰 Economy updated: ${result.resourcesCollected} ${building.production.resourceType} collected (Total gold: ${playerEconomy.gold})',
    );

    // Update camera info display to show new economy state
    cameraInfoDisplay.updateEconomy(playerEconomy);
  }
}

/// Camera and performance info display
class CameraInfoDisplay extends PositionComponent with HasGameRef {
  final GridCamera gridCamera;
  final GridComponent gridComponent;
  PlayerEconomy? _economy;

  CameraInfoDisplay({
    required super.position,
    required this.gridCamera,
    required this.gridComponent,
  });

  void updateEconomy(PlayerEconomy economy) {
    _economy = economy;
  }

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
    final cullRate = ((metrics['cullRate'] as double) * 100).toStringAsFixed(1);
    textPaint.render(
      canvas,
      'Tiles: ${metrics['renderedTiles']}/${metrics['totalTiles']} ($cullRate% culled)',
      Vector2(0, 40),
    );

    // Display economy info if available
    if (_economy != null) {
      textPaint.render(
        canvas,
        'Gold: ${_economy!.gold} | Buildings: ${_economy!.buildings.length}',
        Vector2(0, 60),
      );

      // Show inventory count
      final resourceCount = _economy!.inventory.values
          .fold<double>(0, (sum, resource) => sum + resource.amount);
      textPaint.render(
        canvas,
        'Resources: ${resourceCount.toStringAsFixed(1)}',
        Vector2(0, 80),
      );
    }

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
        Vector2(0, 100),
      );
    }
  }
}
