# FantasyFactio / Trade Factory Masters - AI Assistant Guide

<!-- AI-INDEX: game, flutter, flame, factory automation, mobile gaming -->

## Quick Facts

| Aspect | Value |
|--------|-------|
| **Project Name** | Trade Factory Masters |
| **Repository** | FantasyFactio |
| **Type** | Mobile Game (Flutter/Flame) |
| **Primary Tech Stack** | Flutter 3.16+, Flame 1.33.0, Dart 3.2 |
| **State Management** | Riverpod 3.0 |
| **Backend** | Firebase (Auth, Firestore, Analytics) |
| **Local Storage** | Hive |
| **Architecture** | Clean Architecture (Domain, Data, Presentation, Game Engine layers) |
| **Target Platform** | Mobile (Android primary, iOS secondary), Desktop planned Month 6-7 |
| **Performance Target** | 60 FPS on budget Android (Snapdragon 660) |
| **Current Status** | Epic 1 Completed (with bugs), Epic 2+ in Planning |
| **Overall Progress** | ~16% (47 SP / 289 SP MVP scope) |
| **Current Branch** | `claude/project-status-display-01WgeBaEE9s5pXkKZraeZEwN` |

---

## Documentation Index

### Critical AI-Optimized Files (.claude/)

These files are designed to be read by AI first - they contain condensed, structured information:

| File | Purpose | When to Read |
|------|---------|--------------|
| [.claude/FILE-MAP.md](.claude/FILE-MAP.md) | Index of all code files by category | Before any code work |
| [.claude/TABLES.md](.claude/TABLES.md) | Database schema and entity relationships | When implementing data features |
| [.claude/PATTERNS.md](.claude/PATTERNS.md) | Code patterns, conventions, examples | When writing new code |
| [.claude/PROMPTS.md](.claude/PROMPTS.md) | Ready-to-use task prompts | When structuring work |

### Human-Readable Documentation Structure (docs/)

```
docs/
├── 00-START-HERE.md                    ← First read for humans
├── BMAD-STRUCTURE.md                   ← How docs are organized
├── 1-BASELINE/
│   ├── product/
│   │   ├── prd-v1.0.md                 ← Requirements
│   │   ├── product-brief.md            ← Vision & market gap
│   │   └── market-research.md          ← Competitive analysis
│   └── architecture/
│       ├── system-architecture.md      ← Technical design
│       ├── database-schema.md          ← Entity models
│       └── tech-decisions.md           ← Why these choices
│
├── 2-MANAGEMENT/
│   ├── project-status.md               ← Current state
│   ├── MVP-TODO.md                     ← What's left
│   └── epics/
│       ├── epic-00-project-setup.md
│       ├── epic-01-core-gameplay.md
│       └── ...epic-02-12...
│
├── 4-DEVELOPMENT/
│   ├── SETUP.md                        ← How to set up dev environment
│   ├── DEVELOPMENT.md                  ← Dev guidelines & workflow
│   └── TROUBLESHOOTING.md              ← Common issues
│
└── 5-ARCHIVE/
    └── [deprecated docs from 2025-11-17]
```

---

## Code Structure

### Main Directories

```
trade_factory_masters/lib/
├── main.dart                          ← App entry point
├── domain/                            ← Business logic (Framework-independent)
│   ├── core/                          ← Shared domain types (Result, Either)
│   ├── entities/                      ← Building, Resource, PlayerEconomy
│   └── usecases/                      ← CollectResources, UpgradeBuilding
├── game/                              ← Game engine layer (Flame)
│   ├── camera/                        ← GridCamera, zoom system
│   └── components/                    ← BuildingComponent, GridComponent
├── data/                              ← Data persistence
│   ├── models/                        ← JSON serializable data classes
│   ├── repositories/                  ← Hive + Firebase implementations
│   └── datasources/                   ← Local (Hive) and remote (Firebase)
└── presentation/                      ← Flutter UI (if exists)

test/                                  ← Unit tests
integration_test/                      ← Integration tests
```

### Current Implementation Status

| Layer | Status | Key Files |
|-------|--------|-----------|
| **Domain** | ✅ Complete (8 files) | entities/, usecases/, core/ |
| **Game Engine** | ✅ Complete | camera/, components/ |
| **Data** | ⚠️ Partial | models/, datasources/ (Hive working, Firebase untested) |
| **Presentation** | ⏳ Planned | Not yet implemented |
| **Tests** | ⚠️ Partial | Unit tests: ✅, Integration tests: ❌ (won't compile) |

---

## Known Issues & Bugs (Epic 1)

**CRITICAL - Must Fix Before Epic 2:**

1. **Integration Test Won't Compile** - Bug #1
   - Location: `integration_test/core_gameplay_loop_test.dart` (lines 167, 278, 326, 388)
   - Issue: Using parameter name `buildingId` instead of `building`
   - Impact: Cannot run integration tests
   - Fix: Change parameter name from `buildingId` to `building`

2. **Resource Inventory Logic Broken** - Bug #2
   - Location: `lib/domain/entities/player_economy.dart` (lines 52-56)
   - Issue: `addResource()` returns unchanged economy if resource doesn't exist (contradicts docs)
   - Impact: Resources won't be added to inventory, core gameplay loop breaks
   - Fix: Create new Resource if not in inventory, add to inventory
   - Severity: CRITICAL - blocks core gameplay

3. **Type Cast Syntax Error** - Bug #8
   - Location: `lib/main.dart` (line 325)
   - Issue: `(metrics['cullRate'] as double * 100)` - incorrect precedence
   - Fix: Add parentheses: `((metrics['cullRate'] as double) * 100)`

**MEDIUM - Should Fix:**

4. Camera animation TODO (incomplete feature)
5. Hardcoded values in main.dart (should be constants)
6. Firebase not optional (should have fallback)

**Full details:** See `/docs/2-MANAGEMENT/EPIC-1-ISSUES.md`

---

## Current Project Phase

### ✅ COMPLETED
- **Phase 1-3 (Planning):** Full discovery, PRD, architecture, UX design
- **Epic 1:** All stories coded, but with bugs (see Known Issues above)

### ⏳ IN PROGRESS
- **Documentation Reorganization:** Moving to BMAD V6 structure
- **Bug Fixes:** Critical Epic 1 bugs need to be fixed

### ⏳ READY TO START
- **Epic 2 (Tier 1 Economy):** 26 SP, tech context complete
- **Epic 5 (Mobile-First UX):** 29 SP, tech context complete
- **Epic 8 (Ethical F2P):** 23 SP, tech context complete

---

## MVP Scope & Timeline

**Total MVP:** 170 Story Points across 8 sprints

| Sprint | Epic(s) | SP | Status |
|--------|---------|----|----|
| Sprint 1 | EPIC-00, EPIC-01 | 47 SP | ✅ Complete (with bugs) |
| Sprint 2-3 | EPIC-02 (Tier 1 Economy) | 26 SP | ⏳ Ready |
| Sprint 4-5 | EPIC-03 (Automation) | 42 SP | 📋 Planning |
| Sprint 6-7 | EPIC-04 (Offline) | 26 SP | 📋 Planning |
| Sprint 8 | EPIC-05, EPIC-08 | 33 SP | 📋 Planning |

**Velocity:** 25 SP/week (solo dev, adjusted for Flame learning curve)

---

## How to Work on This Project

### Before Starting Any Task

1. **Read this file first** (CLAUDE.md) - you're reading it now ✓
2. **Check project status** - Read `docs/2-MANAGEMENT/project-status.md`
3. **Review task details** - Open epic file in `docs/2-MANAGEMENT/epics/epic-NN.md`
4. **Check code patterns** - Review `.claude/PATTERNS.md` before writing code

### When Implementing a Story

1. Create a **fresh chat** (important for avoiding AI hallucinations)
2. Read the epic story details
3. Use patterns from `.claude/PATTERNS.md`
4. After coding, update `.claude/FILE-MAP.md` if new files created
5. Update epic file with status: ✅ Done
6. Update `docs/2-MANAGEMENT/project-status.md` with progress

### When Fixing Bugs

1. Specify **exact file:line number** of bug
2. Include **expected vs actual behavior**
3. Test after fix: `flutter test` for unit tests
4. Check: `flutter test integration_test/` for integration tests (once fixed)

### When Adding Features

- Follow naming conventions from `.claude/PATTERNS.md`
- Keep Clean Architecture separation (domain/ stays framework-independent)
- Add unit tests in `test/` directory
- Update FILE-MAP.md with new files/classes

---

## Conventions

### Naming

| Element | Format | Example |
|---------|--------|---------|
| Files | snake_case | `player_economy.dart` |
| Classes | PascalCase | `PlayerEconomy`, `BuildingComponent` |
| Functions | camelCase | `getBuilding()`, `addResource()` |
| Constants | UPPER_SNAKE_CASE | `MAX_GRID_WIDTH = 50` |
| Enums | PascalCase | `ResourceType.tier1` |

### File Organization

- Entity files: `lib/domain/entities/{entity_name}.dart`
- UseCase files: `lib/domain/usecases/{usecase_name}_usecase.dart`
- Component files: `lib/game/components/{component_name}_component.dart`
- Test files: mirror lib structure in `test/` and `integration_test/`

### Commit Messages

Format: `type: description`

```
feat: Add CollectResources use case
fix: Fix resource inventory logic bug
docs: Update project documentation
refactor: Extract hardcoded values to constants
test: Add unit tests for PlayerEconomy
```

---

## Quick Commands

```bash
# Setup development environment
flutter pub get
flutter pub run build_runner build

# Run the app (hot reload enabled)
flutter run

# Run all unit tests
flutter test

# Run integration tests (after fixing compilation errors)
flutter test integration_test/

# Code analysis
flutter analyze

# Format code
dart format lib/

# Build APK for Android
flutter build apk

# Build iOS (requires macOS)
flutter build ios
```

---

## AI Instructions

### Reading Strategy (Minimize Tokens)

1. **Always start with CLAUDE.md** (this file) - gives you instant context
2. **Use .claude/* files** - condensed, AI-optimized information
3. **Go to detailed docs only if needed** - most work doesn't need reading all of docs/
4. **Check FILE-MAP.md before code search** - faster than glob patterns

### Documentation Accuracy

- ⚠️ **KNOWN INCONSISTENCY:** The sprint-status.yaml shows Epic 1 stories as "backlog", but completion-report.md claims they're "done". This is a documentation bug - the stories ARE implemented (but with bugs).
- Check `.claude/KNOWN-ISSUES.md` before assuming something is missing

### When Stuck

1. Check `.claude/PATTERNS.md` - does this problem have a solved pattern?
2. Check existing code - search for similar implementations
3. Re-read the relevant epic file - maybe you missed a detail
4. Ask user directly - better than guessing

---

## Multi-Model Workflow (For Project Maintainers)

If using different Claude models:

| Task | Recommended Model | Why |
|------|-------------------|-----|
| Planning, architecture | Opus | Deep analysis, long-context |
| Implementation (per story) | Sonnet | Fast, accurate at code |
| Quick fixes, review | Haiku | Speed + cost efficiency |
| Documentation | Sonnet | Balance of speed & quality |

**Critical:** Use fresh chat for each story to avoid hallucinations.

---

## Resources

### Key Documents
- **Market & Vision:** `/docs/1-BASELINE/product/product-brief.md`
- **Requirements:** `/docs/1-BASELINE/product/prd-v1.0.md`
- **Architecture:** `/docs/1-BASELINE/architecture/system-architecture.md`
- **Epic Details:** `/docs/2-MANAGEMENT/epics/epic-{N}.md`

### External References
- Flame Documentation: https://flame-engine.org/
- Flutter Documentation: https://flutter.dev/docs
- Firebase Docs: https://firebase.google.com/docs
- Riverpod Guide: https://riverpod.dev/

---

## Last Updated

- **Date:** 2025-12-02
- **Status:** Documentation Reorganization in Progress
- **Next Update:** After Bug Fixes & Epic 2 Planning
- **By:** Claude (BMAD Documentation Agent)
