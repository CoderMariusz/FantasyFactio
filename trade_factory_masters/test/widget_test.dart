// Basic Flame game test for Trade Factory Masters

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/main.dart';

void main() {
  testWidgets('Flame game initializes', (WidgetTester tester) async {
    // Build our game and trigger a frame
    await tester.pumpWidget(
      GameWidget(
        game: TradeFactoryGame(),
      ),
    );

    // Verify the game widget is rendered
    expect(find.byType(GameWidget<TradeFactoryGame>), findsOneWidget);

    // Allow the game to load
    await tester.pump();
  });

  test('TradeFactoryGame can be instantiated', () {
    final game = TradeFactoryGame();
    expect(game, isA<FlameGame>());
  });
}
