import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Test Firebase Auth (Anonymous Sign-In)
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    print('✅ Firebase Auth Success! User ID: ${userCredential.user?.uid}');
  } catch (e) {
    print('❌ Firebase Auth Error: $e');
  }

  runApp(
    GameWidget(
      game: TradeFactoryGame(),
    ),
  );
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
