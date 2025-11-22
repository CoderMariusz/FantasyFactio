# Trade Factory Masters

Mobile factory automation game built with Flutter & Flame Engine.

## 🎮 About

Trade Factory Masters is a mobile idle/incremental game where players build and automate factory production chains to manufacture resources and trade them for profit.

**Tech Stack:**
- Flutter 3.16+
- Flame 1.33+ (Game Engine)
- Riverpod 2.6+ (State Management with code generation)
- Hive 2.2+ (Local Storage)
- Firebase (Cloud Save, Analytics, Crashlytics)

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.16 or higher
- Android Studio / Xcode (for mobile development)
- Firebase CLI (for backend configuration)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/CoderMariusz/FantasyFactio.git
   cd FantasyFactio/trade_factory_masters
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if needed):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/                 # Core utilities, constants, extensions
├── domain/              # Business logic layer
│   ├── entities/        # Domain entities (Building, Resource, etc.)
│   ├── usecases/        # Business use cases
│   └── repositories/    # Repository interfaces
├── data/                # Data layer
│   ├── models/          # Data models (JSON serialization)
│   ├── datasources/     # Data sources (API, local DB)
│   └── repositories/    # Repository implementations
├── presentation/        # UI layer
│   ├── screens/         # Screen widgets
│   ├── widgets/         # Reusable widgets
│   └── providers/       # Riverpod providers
└── game/                # Flame game components
    ├── components/      # Game components
    └── systems/         # Game systems
```

## 🛠️ Development

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format .
```

### Building

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build IOS (macOS only)
flutter build ios --release
```

## 📊 MVP Scope

**Development Timeline:** 8 weeks (170 Story Points)

**Core Features:**
- ✅ Core gameplay loop (COLLECT → DECIDE → UPGRADE)
- ✅ 5 building types + 7 resources
- ✅ Conveyor automation (A* pathfinding)
- ✅ Offline production (Tier 1 + Tier 2)
- ✅ NPC Market buy/sell
- ✅ Cloud save (Firebase)
- ✅ 60 FPS on Snapdragon 660

## 📝 Documentation

Full project documentation is available in the `docs/` folder:

- [Product Requirements Document](../docs/prd-trade-factory-masters-2025-11-17.md)
- [System Architecture](../docs/architecture-trade-factory-masters-2025-11-17.md)
- [UX Design Document](../docs/ux-design-trade-factory-masters-2025-11-17.md)
- [Test Design Document](../docs/test-design-trade-factory-masters-2025-11-17.md)
- [Epics & Stories](../docs/epics-stories-trade-factory-masters-2025-11-17.md)
- [Sprint Planning](../docs/sprint-planning-review-2025-11-17.md)

## 🤝 Contributing

This is a solo development project following the BMAD methodology. See [START_HERE.md](../START_HERE.md) for the implementation plan.

## 📄 License

Copyright © 2025 Mariusz K. All rights reserved.

---

**Status:** 🚀 Sprint 1 - Foundation (Week 1)
**Last Updated:** 2025-11-22
