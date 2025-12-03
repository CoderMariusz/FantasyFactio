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

/// HelloWorld Flame game for testing 60 FPS rendering
class TradeFactoryGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add FPS counter
    add(
      FpsTextComponent(
        position: Vector2(10, 10),
      ),
    );

    // Add welcome text
    add(
      TextComponent(
        text: 'Trade Factory Masters',
        position: Vector2(size.x / 2, size.y / 2 - 50),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: 'Flame Engine Initialized ✓',
        position: Vector2(size.x / 2, size.y / 2 + 20),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 24,
          ),
        ),
      ),
    );

    // Add rotating circle to test rendering
    add(
      RotatingCircle(
        position: Vector2(size.x / 2, size.y / 2 + 100),
      ),
    );
  }
}

/// Simple rotating circle component to verify smooth 60 FPS
class RotatingCircle extends PositionComponent {
  RotatingCircle({super.position})
      : super(
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      40,
      paint,
    );

    // Draw a dot to see rotation
    final dotPaint = Paint()..color = Colors.red;
    canvas.drawCircle(
      Offset(size.x / 2 + 40, size.y / 2),
      5,
      dotPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += dt * 2; // Rotate 2 radians per second
  }
}
