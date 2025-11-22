import 'package:flutter_test/flutter_test.dart';
import 'package:trade_factory_masters/domain/entities/resource.dart';

void main() {
  group('Resource', () {
    test('creates instance with required properties', () {
      const resource = Resource(
        id: 'wood',
        displayName: 'Wood',
        type: ResourceType.tier1,
        iconPath: 'assets/images/resources/wood.png',
      );

      expect(resource.id, equals('wood'));
      expect(resource.displayName, equals('Wood'));
      expect(resource.type, equals(ResourceType.tier1));
      expect(resource.iconPath, equals('assets/images/resources/wood.png'));
    });

    test('uses default values for amount and maxCapacity', () {
      const resource = Resource(
        id: 'stone',
        displayName: 'Stone',
        type: ResourceType.tier1,
        iconPath: 'assets/images/resources/stone.png',
      );

      expect(resource.amount, equals(0));
      expect(resource.maxCapacity, equals(1000));
    });

    test('allows custom amount and maxCapacity', () {
      const resource = Resource(
        id: 'iron',
        displayName: 'Iron Ore',
        type: ResourceType.tier1,
        amount: 500,
        maxCapacity: 2000,
        iconPath: 'assets/images/resources/iron.png',
      );

      expect(resource.amount, equals(500));
      expect(resource.maxCapacity, equals(2000));
    });

    group('isFull', () {
      test('returns false when amount is less than maxCapacity', () {
        const resource = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 500,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource.isFull, isFalse);
      });

      test('returns true when amount equals maxCapacity', () {
        const resource = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 1000,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource.isFull, isTrue);
      });

      test('returns true when amount exceeds maxCapacity', () {
        const resource = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 1500,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource.isFull, isTrue);
      });
    });

    group('remainingCapacity', () {
      test('calculates correctly with partial amount', () {
        const resource = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 300,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource.remainingCapacity, equals(700));
      });

      test('returns 0 when full', () {
        const resource = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 1000,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource.remainingCapacity, equals(0));
      });

      test('returns negative when overfull', () {
        const resource = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 1200,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource.remainingCapacity, equals(-200));
      });
    });

    group('copyWith', () {
      const original = Resource(
        id: 'wood',
        displayName: 'Wood',
        type: ResourceType.tier1,
        amount: 100,
        maxCapacity: 1000,
        iconPath: 'assets/images/resources/wood.png',
      );

      test('creates copy with updated amount', () {
        final updated = original.copyWith(amount: 500);

        expect(updated.amount, equals(500));
        expect(updated.id, equals(original.id));
        expect(updated.displayName, equals(original.displayName));
      });

      test('creates copy with updated maxCapacity', () {
        final updated = original.copyWith(maxCapacity: 2000);

        expect(updated.maxCapacity, equals(2000));
        expect(updated.amount, equals(original.amount));
      });

      test('creates identical copy when no parameters provided', () {
        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.displayName, equals(original.displayName));
        expect(copy.amount, equals(original.amount));
        expect(copy.maxCapacity, equals(original.maxCapacity));
      });
    });

    group('equality', () {
      test('equal resources have same hash code', () {
        const resource1 = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 100,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        const resource2 = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 100,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource1, equals(resource2));
        expect(resource1.hashCode, equals(resource2.hashCode));
      });

      test('different resources are not equal', () {
        const resource1 = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 100,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        const resource2 = Resource(
          id: 'stone',
          displayName: 'Stone',
          type: ResourceType.tier1,
          amount: 100,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/stone.png',
        );

        expect(resource1, isNot(equals(resource2)));
      });

      test('resources with different amounts are not equal', () {
        const resource1 = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 100,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        const resource2 = Resource(
          id: 'wood',
          displayName: 'Wood',
          type: ResourceType.tier1,
          amount: 200,
          maxCapacity: 1000,
          iconPath: 'assets/images/resources/wood.png',
        );

        expect(resource1, isNot(equals(resource2)));
      });
    });

    test('toString returns formatted string', () {
      const resource = Resource(
        id: 'wood',
        displayName: 'Wood',
        type: ResourceType.tier1,
        amount: 350,
        maxCapacity: 1000,
        iconPath: 'assets/images/resources/wood.png',
      );

      final str = resource.toString();
      expect(str, contains('wood'));
      expect(str, contains('Wood'));
      expect(str, contains('350'));
      expect(str, contains('1000'));
    });
  });

  group('ResourceType', () {
    test('has all expected types', () {
      expect(ResourceType.values, hasLength(3));
      expect(ResourceType.values, contains(ResourceType.tier1));
      expect(ResourceType.values, contains(ResourceType.tier2));
      expect(ResourceType.values, contains(ResourceType.tier3));
    });
  });
}
