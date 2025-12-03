# Epic 0: Project Setup - Technical Specification

<!-- AI-INDEX: epic, tech-spec, project-setup, flutter, firebase, hive -->

**Epic:** EPIC-00 - Project Setup
**Total SP:** 13
**Duration:** 1 week (Sprint 1)
**Status:** ✅ Implemented
**Date:** 2025-12-03
**Priority:** P0 (Critical Path - blocks all development)

---

## Overview

EPIC-00 to fundament projektu: inicjalizacja Flutter/Flame, integracja Firebase, CI/CD pipeline i lokalne storage (Hive).

**Design Philosophy:** "Solid foundation first" - bez tej bazy nic nie ruszy.

**Kluczowe cele:**
- **Flutter 3.16+ / Flame 1.33+** - game engine foundation
- **Firebase integration** - Auth, Firestore, Analytics, Crashlytics
- **CI/CD pipeline** - GitHub Actions z 80%+ coverage
- **Hive local storage** - offline-first architecture

---

## Implementation Status

| Story | Title | SP | Status |
|-------|-------|-----|--------|
| 00.1 | Flutter Project Init | 2 | ✅ Done |
| 00.2 | Firebase Configuration | 3 | ✅ Done |
| 00.3 | CI/CD Pipeline | 3 | ✅ Done |
| 00.4 | Hive Local Storage | 5 | ✅ Done |

---

## System Architecture

### Project Structure
```
trade_factory_masters/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase config (generated)
│   ├── domain/                   # Business logic
│   │   ├── core/                 # Shared types (Result, etc.)
│   │   ├── entities/             # Domain models
│   │   └── usecases/             # Use cases
│   ├── data/                     # Data layer
│   │   ├── models/               # Data models (Hive)
│   │   ├── datasources/          # Local & remote
│   │   └── repositories/         # Repository implementations
│   ├── game/                     # Flame game engine
│   │   ├── camera/               # Camera system
│   │   └── components/           # Game components
│   └── presentation/             # Flutter UI (future)
├── test/                         # Unit & widget tests
├── integration_test/             # Integration tests
├── .github/workflows/            # CI/CD
└── pubspec.yaml                  # Dependencies
```

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  flame: ^1.33.0
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.14.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0
  hive_flutter: ^1.1.0
  riverpod: ^2.4.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test: sdk
  build_runner: ^2.4.0
  hive_generator: ^2.0.1
  integration_test: sdk
```

---

## Firebase Configuration

### Services Enabled
- ✅ Authentication (Anonymous, Google, Apple)
- ✅ Cloud Firestore (with security rules)
- ✅ Analytics
- ✅ Crashlytics

### Security Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: CI Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
```

---

## Hive Configuration

### Registered Adapters
| TypeId | Class | Purpose |
|--------|-------|---------|
| 0 | ResourceAdapter | Resource entity |
| 1 | ResourceTypeAdapter | Resource type enum |
| 2 | BuildingAdapter | Building entity |
| 3 | BuildingTypeAdapter | Building type enum |
| 4 | GridPositionAdapter | Grid coordinates |
| 5 | PlayerEconomyAdapter | Player state |
| 6 | ProductionConfigAdapter | Production config |
| 7 | UpgradeConfigAdapter | Upgrade config |

### Initialization
```dart
Future<void> initHive() async {
  await Hive.initFlutter();
  // Register all adapters
  Hive.registerAdapter(ResourceAdapter());
  Hive.registerAdapter(BuildingAdapter());
  // ...etc
  await Hive.openBox<PlayerEconomy>('gameState');
}
```

---

## Dependencies

**Depends On:**
- Nothing (starting point)

**Blocks:**
- → EPIC-01 (Core Gameplay)
- → EPIC-05 (Mobile UX)
- → EPIC-09 (Firebase Backend)

---

## Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Flutter build | APK builds | ✅ |
| Firebase Auth | Anonymous works | ✅ |
| CI Pipeline | All checks pass | ✅ |
| Hive storage | Data persists | ✅ |
| Test coverage | 80%+ | ⚠️ Ongoing |

---

**Status:** ✅ Implemented
**Last Updated:** 2025-12-03
**Version:** 1.0
