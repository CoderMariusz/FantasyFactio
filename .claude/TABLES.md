# TABLES - Database Schema & Entity Models

<!-- AI-INDEX: database, schema, entities, models, data-structure, firestore -->

Last Updated: 2025-12-02

---

## Quick Reference

Game state is stored in:
- **Local:** Hive (offline-first, on device)
- **Remote:** Firebase Firestore (cloud sync, multi-device)

**Sync Strategy:** Optimistic local updates → async cloud sync

---

## Core Data Models

### 1. PlayerEconomy (Game State)

**Purpose:** Represents current player progress and inventory

**Location:** `lib/domain/entities/player_economy.dart`

**Fields:**

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| playerId | String | ✓ | UUID | Who owns this economy |
| gold | int | ✓ | ≥ 0 | Currency for upgrades |
| buildings | List<Building> | ✓ | 0-50 | Player's buildings |
| inventory | Map<String, Resource> | ✓ | Max capacity | Resources held |
| tier | int | ✓ | 1-3 | Progression tier |
| lastSeen | DateTime | ✓ | - | For offline production calc |

**Example in Code:**

```dart
const economy = PlayerEconomy(
  playerId: 'player-123',
  gold: 500,
  buildings: [farmBuilding, minerBuilding],
  inventory: {
    'wood': Resource(amount: 150),
    'iron': Resource(amount: 80),
  },
  tier: 1,
  lastSeen: DateTime.now(),
);
```

**Firestore Collection:** `players/{playerId}/economy`

**Hive Box:** `player_economy` (key: playerId)

---

### 2. Building (Domain Entity)

**Purpose:** Definition of a building type and current instance

**Location:** `lib/domain/entities/building.dart`

**Fields:**

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | String | ✓ | "farm-1", "mine-2" | Unique building instance |
| name | String | ✓ | 1-50 chars | Display name |
| type | BuildingType | ✓ | enum | farm, mine, factory, etc |
| level | int | ✓ | 1-10 | Upgrade level |
| gridX | int | ✓ | 0-49 | Grid position |
| gridY | int | ✓ | 0-49 | Grid position |
| productionRate | double | ✓ | ≥ 0.1 | Resources per second |
| production | String | ✓ | "wood", "iron" | What it produces |
| upgradeCost | int | ✓ | ≥ 10 | Gold per upgrade |
| maxLevel | int | ✓ | 5-10 | Level cap |

**Firestore:** `players/{playerId}/buildings/{buildingId}`

**Hive:** Nested in `player_economy` → buildings list

**Example:**

```dart
const farm = Building(
  id: 'farm-1',
  name: 'Farm',
  type: BuildingType.farm,
  level: 1,
  gridX: 5,
  gridY: 10,
  productionRate: 1.0,
  production: 'wood',
  upgradeCost: 100,
  maxLevel: 10,
);
```

---

### 3. Resource (Game Item)

**Purpose:** Represents a tradeable/usable resource

**Location:** `lib/domain/entities/resource.dart`

**Fields:**

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | String | ✓ | "wood", "iron" | Unique resource type |
| displayName | String | ✓ | 1-50 chars | UI display |
| type | ResourceType | ✓ | tier1, tier2 | Gameplay tier |
| amount | int | ✓ | 0 to maxCapacity | Current quantity held |
| maxCapacity | int | ✓ | ≥ 100 | Inventory limit per resource |
| iconPath | String | ✓ | "assets/..." | Sprite path for UI |

**Firestore:** Nested in inventory under `players/{playerId}/economy`

**Example:**

```dart
const wood = Resource(
  id: 'wood',
  displayName: 'Wood',
  type: ResourceType.tier1,
  amount: 150,
  maxCapacity: 500,
  iconPath: 'assets/images/resources/wood.png',
);
```

---

## Firestore Collection Structure

```
firestore/
└── players/ (Collection)
    └── {playerId}/ (Document)
        ├── email: "user@example.com"
        ├── createdAt: Timestamp
        ├── economy/ (Document)
        │   ├── gold: 500
        │   ├── tier: 1
        │   ├── lastSeen: Timestamp
        │   ├── buildings: [
        │   │   {id, name, level, gridX, gridY, ...},
        │   │   ...
        │   │ ]
        │   └── inventory: {
        │       "wood": {id, amount, maxCapacity, ...},
        │       "iron": {...},
        │       ...
        │     }
        └── metadata/ (Document)
            ├── lastModified: Timestamp
            ├── dataVersion: 1
            └── platform: "mobile"
```

---

## Hive Box Structure

Hive is used for local-first offline storage, synced to Firestore when online.

### boxes Configuration

```dart
// lib/infrastructure/hive/hive_boxes.dart

class HiveBoxes {
  static const String playerEconomy = 'player_economy';
  static const String buildings = 'buildings';
  static const String resources = 'resources';
  static const String metadata = 'metadata';
}
```

### Data in Hive

```
Hive Boxes:
├── player_economy
│   └── playerId -> PlayerEconomy object
├── buildings
│   └── buildingId -> Building object
├── resources
│   └── resourceId -> Resource object
└── metadata
    └── 'last_sync' -> DateTime
    └── 'app_version' -> String
```

---

## Important Data Rules

### 1. Immutability

All entities are **immutable** - updates create new instances via `copyWith()`:

```dart
// ❌ DON'T
economy.gold += 100;

// ✅ DO
economy = economy.copyWith(gold: economy.gold + 100);
```

### 2. Grid Constraints

Building positions must respect grid:

```dart
// Grid is 50x50 (0-49 for both X and Y)
if (building.gridX < 0 || building.gridX >= 50) {
  return false; // Invalid position
}
if (building.gridY < 0 || building.gridY >= 50) {
  return false; // Invalid position
}
```

### 3. Resource Capacity

Resources cannot exceed maxCapacity:

```dart
final newAmount = min(resource.amount + collected, resource.maxCapacity);
```

### 4. Level Constraints

Buildings have minimum (1) and maximum (maxLevel) levels:

```dart
if (building.level < 1 || building.level > building.maxLevel) {
  return false; // Invalid level
}
```

---

## Tier-Based Content Unlock

Game has 3 tiers with progressive unlocks:

| Tier | Buildings | Resources | Features | Unlock Condition |
|------|-----------|-----------|----------|-----------------|
| **1** | Farm, Mine | Wood, Iron | Manual collecting | Default |
| **2** | Conveyor, Splitter | Gold (ore) | Automation system | Reach Tier 2 milestone |
| **3** | Advanced Conveyor | Advanced resources | Economy deepens | Reach Tier 3 milestone |

---

## Migration Strategy

### Data Version

All player data includes `dataVersion` to track schema changes:

```dart
{
  "playerId": "...",
  "dataVersion": 1,  // ← Schema version
  "economy": { ... }
}
```

**Current Version:** 1

**Migration Example:**

```dart
// When schema changes, increment version and migrate
if (loadedData.dataVersion < 2) {
  // Apply migrations
  loadedData = migrateV1toV2(loadedData);
  loadedData.dataVersion = 2;
}
```

---

## Type Enums

### BuildingType

```dart
enum BuildingType {
  farm,      // Produces wood
  mine,      // Produces iron
  factory,   // Refines resources (Tier 2+)
  conveyor,  // Transports resources (Tier 2+)
}
```

### ResourceType

```dart
enum ResourceType {
  tier1,     // Basic resources (wood, iron)
  tier2,     // Refined resources (copper, gold)
  tier3,     // Advanced resources
}
```

---

## Backup & Sync

### Local Backup (Hive)

- Stored automatically on device
- Survives app crashes
- Used for offline play

### Cloud Sync (Firestore)

- Manual sync trigger via `SyncManager`
- Conflict resolution: client wins for UX (user action = authority)
- Async operation (doesn't block gameplay)

### Edge Cases

| Scenario | Handling |
|----------|----------|
| Offline then online | Local changes sync, cloud wins if older |
| Multi-device login | Latest timestamp wins |
| Server error | Retry with exponential backoff |
| Data corruption | Restore from backup |

---

## How to Add New Data Models

When adding new entity:

1. Create `lib/domain/entities/{name}.dart`
2. Make immutable with `copyWith()`
3. Implement `==` and `hashCode`
4. Add to FILE-MAP.md
5. Create Firestore path in docs
6. Add Hive box (if persistent)
7. Add tests in `test/domain/entities/{name}_test.dart`

**Example of adding new entity:**

```dart
// lib/domain/entities/conveyor.dart
class Conveyor {
  final String id;
  final int gridXStart;
  final int gridYStart;
  final int gridXEnd;
  final int gridYEnd;
  final double efficiency;

  const Conveyor({
    required this.id,
    required this.gridXStart,
    required this.gridYStart,
    required this.gridXEnd,
    required this.gridYEnd,
    required this.efficiency,
  });

  Conveyor copyWith({...}) {
    return Conveyor(...);
  }

  @override
  bool operator ==(Object other) => ...;

  @override
  int get hashCode => ...;
}
```

---

## Performance Considerations

### Index Strategy (Firestore)

For efficient queries, create indexes on:
- `players.createdAt` (user listing)
- `players.economy.lastModified` (sync detection)

### Hive Optimization

- Use TypeID adapters for custom objects
- Keep box size reasonable (split if > 1MB)
- Don't serialize unnecessary fields

### Data Size

**Target:** < 500KB per player (uncompressed)

| Component | Typical Size |
|-----------|--------------|
| Buildings (50 max) | ~50 KB |
| Inventory (20 resources) | ~5 KB |
| Metadata | ~1 KB |
| **Total** | **~56 KB** |

---

## Query Examples

### Get Current Player Economy

```dart
// From Firestore
final doc = await FirebaseFirestore.instance
    .collection('players')
    .doc(playerId)
    .collection('economy')
    .doc('current')
    .get();

// From Hive
final economy = hiveBox.get(playerId) as PlayerEconomy;
```

### Get All Buildings

```dart
// From economy object (local)
final buildings = economy.buildings;

// From Firestore (if stored separately)
final snapshot = await FirebaseFirestore.instance
    .collection('players/$playerId/buildings')
    .get();
```

---

## Last Updated

- Date: 2025-12-02
- Schema Version: 1
- Firestore Paths: Finalized
- Hive Structure: Finalized
