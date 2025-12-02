# Epic 1 - Issues & Bug Report

<!-- AI-INDEX: epic-1, bugs, issues, fixes, critical -->

**Project:** Trade Factory Masters
**Date:** 2025-12-02
**Status:** 🔴 CRITICAL - Blocking Epic Completion
**Reviewer:** Claude (Deep Dive Analysis)

---

## Executive Summary

Despite completion report claiming "100% done, all tests passing", deep code analysis found **3 critical bugs** and **6 medium issues** that prevent core gameplay from working.

**Status:** ❌ **NOT PRODUCTION READY** - requires fixes before proceeding to Epic 2

| Severity | Count | Impact |
|----------|-------|--------|
| 🔴 CRITICAL | 3 | Gameplay breaks, tests fail |
| 🟠 MEDIUM | 6 | Code quality, missing features |
| 🟡 LOW | 3 | Maintainability |

---

## Critical Issues (Must Fix)

### Bug #1: Integration Test Won't Compile

**File:** `integration_test/core_gameplay_loop_test.dart`
**Lines:** 167, 278, 326, 388
**Severity:** 🔴 CRITICAL

**Issue:**
Integration tests use wrong parameter name:

```dart
// ❌ WRONG (current code):
buildingId: testBuilding.id,

// ✅ CORRECT (expected):
building: testBuilding,
```

**Why It's Broken:**
- Method signature in `UpgradeBuilding.execute()` expects `building: Building` parameter
- Test passes `buildingId: String` parameter
- Parameter mismatch causes compilation error
- Integration test cannot run at all

**Current Error:**
```
The named parameter 'buildingId' isn't defined.
```

**Impact:**
- Cannot verify if gameplay actually works
- Integration test suite incomplete
- Claim "integration tests pass" is FALSE

**Fix Instructions:**

1. Open `integration_test/core_gameplay_loop_test.dart`
2. Find all instances of `buildingId:` (should find 4)
3. For each instance, replace:
   ```dart
   buildingId: testBuilding.id,    // Line 167
   buildingId: expensiveBuilding.id,  // Line 278
   buildingId: maxLevelBuilding.id,   // Line 326
   buildingId: currentEconomy.buildings.first.id,  // Line 388
   ```

   With:
   ```dart
   building: testBuilding,
   building: expensiveBuilding,
   building: maxLevelBuilding,
   building: currentEconomy.buildings.first,
   ```

4. Verify: `flutter test integration_test/core_gameplay_loop_test.dart`

**Effort:** 5 minutes
**Risk:** Very Low (parameter name only)

---

### Bug #2: Resource Inventory Logic Broken

**File:** `lib/domain/entities/player_economy.dart`
**Lines:** 52-56
**Severity:** 🔴 CRITICAL

**Issue:**
The `addResource()` method contradicts its documentation:

```dart
/// If resource doesn't exist in inventory, creates it  ← DOCS SAY THIS
PlayerEconomy addResource(String resourceId, int amountToAdd) {
  if (!inventory.containsKey(resourceId)) {
    return this;  // ❌ BUG: Returns unchanged instead of creating!
  }
  // ... rest of method
}
```

**Why It's Broken:**
1. Documentation says: "Creates resource if doesn't exist"
2. Code actually does: Returns unchanged economy
3. When `CollectResourcesUseCase` tries to add resources to empty inventory:
   - Inventory is initially `{}`
   - `addResource('wood', 50)` called
   - Check: `inventory.containsKey('wood')` → false
   - Returns unchanged economy → **resources are LOST**
4. Player collects nothing, gameplay breaks

**Real-World Impact:**
- Core gameplay loop: COLLECT → UPGRADE
- Collection phase fails silently
- Resources never appear in inventory
- Upgrade phase can't happen (no resources)
- **Game is unplayable**

**Expected Behavior:**

```dart
PlayerEconomy addResource(String resourceId, int amountToAdd) {
  if (!inventory.containsKey(resourceId)) {
    // CREATE new resource if doesn't exist
    final newResource = Resource(
      id: resourceId,
      displayName: resourceId,  // Should come from config
      type: ResourceType.tier1,
      amount: amountToAdd,
      maxCapacity: 1000,
      iconPath: 'assets/images/resources/$resourceId.png',
    );
    final updatedInventory = Map<String, Resource>.from(inventory);
    updatedInventory[resourceId] = newResource;
    return copyWith(inventory: updatedInventory);
  }

  // Otherwise, add to existing
  final existing = inventory[resourceId]!;
  final newAmount = min(
    existing.amount + amountToAdd,
    existing.maxCapacity,
  );
  final updated = existing.copyWith(amount: newAmount);
  final updatedInventory = Map<String, Resource>.from(inventory);
  updatedInventory[resourceId] = updated;
  return copyWith(inventory: updatedInventory);
}
```

**Fix Instructions:**

1. Open `lib/domain/entities/player_economy.dart`
2. Locate `addResource()` method (lines 52-56)
3. Replace the logic with code above
4. Add tests:
   ```dart
   test('addResource creates new resource if not in inventory', () {
     final empty = PlayerEconomy(inventory: {});
     final result = empty.addResource('wood', 50);

     expect(result.inventory.containsKey('wood'), true);
     expect(result.inventory['wood']!.amount, 50);
   });

   test('addResource updates existing resource', () {
     final initial = PlayerEconomy(inventory: {
       'wood': Resource(amount: 30, ...)
     });
     final result = initial.addResource('wood', 20);

     expect(result.inventory['wood']!.amount, 50);
   });
   ```

5. Run: `flutter test test/domain/entities/player_economy_test.dart`

**Effort:** 30 minutes (logic + tests)
**Risk:** Medium (core domain logic - need thorough testing)

---

### Bug #3: Type Cast Syntax Error

**File:** `lib/main.dart`
**Line:** 325
**Severity:** 🔴 CRITICAL

**Issue:**
Incorrect operator precedence in cast expression:

```dart
// ❌ WRONG:
final cullRate = (metrics['cullRate'] as double * 100).toStringAsFixed(1);

// ✅ CORRECT:
final cullRate = ((metrics['cullRate'] as double) * 100).toStringAsFixed(1);
```

**Why It's Wrong:**
- Syntax: `(expr as Type op operand)` is invalid
- Should be: `((expr as Type) op operand)`
- Missing parentheses causes type error or runtime crash

**Potential Error:**
```
The '-' operator cannot be applied to type cast.
```

**Fix Instructions:**

1. Open `lib/main.dart` at line 325
2. Find:
   ```dart
   (metrics['cullRate'] as double * 100)
   ```
3. Replace with:
   ```dart
   ((metrics['cullRate'] as double) * 100)
   ```

4. Run: `flutter analyze` to verify

**Effort:** 2 minutes
**Risk:** Very Low (syntax fix)

---

## Medium Issues (Should Fix)

### Issue #4: Incomplete Camera Animation

**File:** `lib/game/camera/grid_camera.dart`
**Line:** 302
**Severity:** 🟠 MEDIUM

**Status:** ⚠️ Partially works (snaps instead of animates)

**Issue:**
```dart
void moveTo(Vector2 position, {bool animate = false}) {
  if (animate) {
    // TODO: Implement smooth camera movement animation
    // For now, just snap to position
```

**Current Behavior:**
- Camera movement works but snaps instantly
- API exposes `animate` parameter but doesn't use it
- Documented in architecture but not implemented

**Impact:** Low - gameplay works, just less polished

**Fix:**
1. Implement smooth tweening animation
2. Use Flame's animation system or Tween
3. Estimated effort: 20 minutes
4. Can defer to Epic 3 (UI Polish)

---

### Issue #5: Hardcoded Configuration Values

**File:** `lib/main.dart`
**Lines:** 68-88

**Issue:**
Grid and camera configuration hardcoded in main.dart:

```dart
// ❌ HARDCODED:
const GridConfig(
  gridWidth: 50,
  gridHeight: 50,
  tileWidth: 64.0,
  tileHeight: 32.0,
  showGridLines: true,
);

const GridCameraConfig(
  minZoom: 0.3,
  maxZoom: 2.0,
  zoomTransitionDuration: 0.3,
  panSpeed: 1.0,
);
```

**Impact:** Medium - Technical debt
- Hard to adjust game balance
- No single source of truth for config
- Difficult to test different configs

**Fix:**
1. Create `lib/config/game_config.dart`
2. Define constants there
3. Import and use in main.dart
4. Estimated effort: 15 minutes

---

### Issue #6: Firebase Not Optional

**File:** `lib/main.dart`
**Lines:** 34-45

**Issue:**
```dart
// No try-catch around Firebase init
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Problem:**
- App crashes if Firebase isn't configured
- Can't test without Firebase setup
- No offline-first fallback

**Impact:** Medium - Development friction
- Local testing harder
- CI/CD pipeline may fail without secrets

**Fix:**
1. Wrap Firebase init in try-catch
2. Fallback to local-only mode if fails
3. Estimated effort: 20 minutes

---

### Issue #7: Documentation Inconsistency

**File:** `docs/sprint-artifacts/sprint-status.yaml`

**Issue:**
Sprint status shows all Epic 1 stories as `backlog`, but completion report claims `done`:

```yaml
# In sprint-status.yaml:
epic-01: backlog
01-1-building-entity: backlog
01-2-resource-entity: backlog
...
```

But completion report says: "All 12 stories completed, 100% done"

**Impact:** Low - Confusion only
- New developers may re-implement done work
- Status tracking is inaccurate

**Fix:**
1. Update `sprint-status.yaml` to show stories as `done` (once bugs are fixed)
2. Add note explaining the bugs found

---

### Issue #8: Unsafe Type Casts

**File:** `lib/game/components/building_component.dart` (if present)

**Issue:**
Magic numbers without named constants:

```dart
// ❌ Magic numbers:
final pulseAlpha = (0.5 + 0.5 * (now % 2.0 / 2.0));
canvas.drawCircle(
  Offset(size.x / 2 - 5, -size.y / 2 + 5),  // Hardcoded offsets
  4,  // Hardcoded radius
  ...
);
```

**Impact:** Low - Readability

**Fix:**
1. Extract constants:
   ```dart
   static const double PULSE_MIN_ALPHA = 0.5;
   static const double PULSE_AMPLITUDE = 0.5;
   static const double INDICATOR_OFFSET = 5.0;
   static const double INDICATOR_RADIUS = 4.0;
   ```
2. Use in code
3. Estimated effort: 10 minutes

---

## Testing Status

### Current Test Coverage

| Test Suite | Status | Notes |
|-----------|--------|-------|
| Unit Tests | ✅ ~70-80 tests | Most pass, depends on Bug #2 fix |
| Integration Tests | ❌ Won't Compile | Bug #1 blocks all integration tests |
| Widget Tests | ⏳ Minimal | Basic placeholder test only |

### Test Verification Strategy

**After fixing critical bugs:**

```bash
# 1. Fix Bug #1 - Integration test compilation
flutter test integration_test/core_gameplay_loop_test.dart

# 2. Fix Bug #2 - Resource logic
flutter test test/domain/entities/player_economy_test.dart

# 3. Fix Bug #3 - Type cast
flutter analyze

# 4. Run all tests
flutter test
```

---

## Fix Priority & Timeline

### Immediate (Must Do Before Epic 2)

| Bug | Effort | Risk | Impact | Priority |
|-----|--------|------|--------|----------|
| #1 - Integration test | 5 min | Very Low | CRITICAL | P0 |
| #2 - Resource logic | 30 min | Medium | CRITICAL | P0 |
| #3 - Type cast | 2 min | Very Low | CRITICAL | P0 |

**Total Effort:** ~37 minutes
**Estimated Time:** 1 hour (with testing)

### Should-Do (Before Release)

| Issue | Effort | Risk | Impact | Priority |
|-------|--------|------|--------|----------|
| #4 - Camera animation | 20 min | Low | Low | P2 |
| #5 - Hardcoded config | 15 min | Low | Medium | P1 |
| #6 - Firebase optional | 20 min | Medium | Medium | P1 |
| #7 - Doc consistency | 10 min | Very Low | Low | P3 |
| #8 - Magic numbers | 10 min | Very Low | Low | P3 |

**Total Effort:** ~75 minutes
**Can defer to Epic 2 sprint if needed**

---

## Recommended Action Plan

### Phase 1: Critical Bug Fixes (1 hour)

1. ✅ Fix Bug #1 (5 min)
2. ✅ Fix Bug #2 (30 min)
3. ✅ Fix Bug #3 (2 min)
4. ✅ Run all tests (15 min)
5. ✅ Commit: `fix: critical Epic 1 bug fixes`

### Phase 2: Medium Issues (1.5 hours)

After Phase 1 tests pass:

1. ✅ Fix Issue #5 (hardcoded config) - 15 min
2. ✅ Fix Issue #6 (Firebase optional) - 20 min
3. ✅ Fix Issue #7 (doc consistency) - 10 min
4. ✅ Add Issue #4, #8 to backlog for Epic 3
5. ✅ Run full test suite
6. ✅ Commit: `refactor: improve code quality`

### Phase 3: Documentation Update

1. Update CLAUDE.md (remove from Known Issues once fixed)
2. Update FILE-MAP.md status
3. Update project-status.md
4. Update sprint-status.yaml

---

## How to Track Fixes

After each fix:

1. Update this file: change ✅ marker when done
2. Update `.claude/FILE-MAP.md` status column
3. Test: run `flutter test`
4. Commit with clear message
5. Update `docs/2-MANAGEMENT/project-status.md`

---

## Verification Checklist

Before moving to Epic 2:

- [ ] Bug #1 fixed and integration test compiles
- [ ] Bug #2 fixed and resource collection works
- [ ] Bug #3 fixed and code analyzes clean
- [ ] All unit tests pass (flutter test)
- [ ] All integration tests pass
- [ ] No warnings from flutter analyze
- [ ] Documentation updated
- [ ] Commits pushed to branch

---

## Related Documents

- 📄 Deep dive analysis: See CLAUDE.md "Known Issues" section
- 📄 Code patterns: `.claude/PATTERNS.md`
- 📄 File locations: `.claude/FILE-MAP.md`
- 📄 Epic 1 completion report: `docs/sprint-artifacts/epic-1-completion-report.md`

---

## Status Updates

| Date | Status | Notes |
|------|--------|-------|
| 2025-12-02 | 🔴 CREATED | Deep dive analysis complete, bugs documented |
| TBD | ⏳ IN PROGRESS | Fixes being implemented |
| TBD | ✅ RESOLVED | All critical bugs fixed, tests passing |

---

**Document Owner:** Claude (Code Quality Agent)
**Last Updated:** 2025-12-02
**Next Review:** After bug fixes complete
