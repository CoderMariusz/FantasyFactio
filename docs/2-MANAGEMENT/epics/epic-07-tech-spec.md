# Epic 7: Discovery Tutorial - Technical Specification

<!-- AI-INDEX: epic, tech-spec, tutorial, onboarding, ftue -->

**Epic:** EPIC-07 - Discovery Tutorial
**Total SP:** 21
**Duration:** 1-2 weeks (Sprint 10, post-MVP)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03
**Priority:** P2 (Medium - improves onboarding)

---

## Overview

EPIC-07 implementuje event-based tutorial system z podejściem "show don't tell". Tutorial prowadzi graczy przez podstawowe mechaniki (budowanie, zbieranie, ulepszanie, handel) bez przytłaczających ścian tekstu.

**Design Philosophy:** "Show don't tell" - gracze uczą się przez działanie, nie czytanie.

**Kluczowe cele:**
- **80%+ completion rate** dla pierwszych 3 kroków
- **3-5 minut** na pełny tutorial
- **Skippable** w każdym momencie
- **Event-driven** - tooltip pojawia się gdy gracz jest gotowy

---

## Objectives and Scope

### In Scope

**Tutorial State Machine:**
- ✅ 7 stanów: welcome → firstBuilding → firstCollect → firstUpgrade → openMarket → tier2Unlock → complete
- ✅ Event-driven transitions
- ✅ Persistent state (Hive)
- ✅ Skip at any time

**Tooltip System:**
- ✅ 7 tooltips (jeden per stan)
- ✅ Arrow pointing at target element
- ✅ Auto-dismiss after 10s or player action
- ✅ Skip Tutorial button

**First-Time User Experience (FTUE):**
- ✅ Welcome screen
- ✅ First building auto-placed (Lumbermill)
- ✅ Guided first collection
- ✅ 3-5 minute complete loop

**Analytics:**
- ✅ Tutorial funnel tracking
- ✅ Drop-off point identification
- ✅ Firebase Analytics events

### Out of Scope

- ❌ Advanced tooltips (contextual help) - Phase 2
- ❌ Video tutorials - nie planowane
- ❌ Interactive tutorial quests - overkill
- ❌ Tutorial rewards beyond progression - Phase 2

---

## System Architecture

### Domain Layer
```
lib/domain/entities/
├── tutorial_state.dart          # TutorialState enum
└── tutorial_step.dart           # Step definition (text, target, position)

lib/domain/usecases/
└── tutorial/
    ├── advance_tutorial_usecase.dart
    ├── skip_tutorial_usecase.dart
    └── get_current_step_usecase.dart
```

### Presentation Layer
```
lib/presentation/
├── widgets/
│   ├── tutorial_tooltip.dart      # Tooltip with arrow
│   ├── tutorial_overlay.dart      # Full-screen overlay
│   ├── welcome_screen.dart        # FTUE welcome
│   └── skip_tutorial_button.dart  # Skip option
└── providers/
    └── tutorial_provider.dart     # Riverpod state
```

### Data Layer
```
lib/data/
├── models/
│   └── tutorial_state_model.dart  # Hive serialization
└── repositories/
    └── tutorial_repository_impl.dart
```

---

## Tutorial Flow

### State Machine

```
┌─────────────────────────────────────────────────────────────┐
│                    TUTORIAL STATE MACHINE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────┐    App Start    ┌───────────────┐            │
│   │ WELCOME │ ───────────────>│ FIRST_BUILDING│            │
│   └─────────┘                 └───────┬───────┘            │
│                                       │                     │
│                               Building Placed               │
│                                       │                     │
│                                       ▼                     │
│                               ┌───────────────┐            │
│                               │ FIRST_COLLECT │            │
│                               └───────┬───────┘            │
│                                       │                     │
│                               Resource Collected            │
│                                       │                     │
│                                       ▼                     │
│                               ┌───────────────┐            │
│                               │ FIRST_UPGRADE │            │
│                               └───────┬───────┘            │
│                                       │                     │
│                               Building Upgraded             │
│                                       │                     │
│                                       ▼                     │
│                               ┌───────────────┐            │
│                               │  OPEN_MARKET  │            │
│                               └───────┬───────┘            │
│                                       │                     │
│                                 Market Opened               │
│                                       │                     │
│                                       ▼                     │
│                               ┌───────────────┐            │
│                               │ TIER2_UNLOCK  │            │
│                               └───────┬───────┘            │
│                                       │                     │
│                                Tier 2 Unlocked              │
│                                       │                     │
│                                       ▼                     │
│                               ┌───────────────┐            │
│                               │   COMPLETE    │            │
│                               └───────────────┘            │
│                                                             │
│   ─────────────────────────────────────────────────────    │
│                        SKIP (any time)                      │
│   ─────────────────────────────────────────────────────    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tooltip Definitions

| State | Target | Text | Position |
|-------|--------|------|----------|
| **welcome** | Center screen | "Welcome to Trade Factory Masters!" | Center modal |
| **firstBuilding** | Grid area | "Tap here to place your first building" | Above grid |
| **firstCollect** | Building | "Tap the building to collect resources" | Above building |
| **firstUpgrade** | Upgrade button | "Great! Now tap here to upgrade" | Left of button |
| **openMarket** | Market button | "Visit the market to trade resources" | Above button |
| **tier2Unlock** | Progress bar | "Keep building to unlock Tier 2!" | Below progress |
| **complete** | - | "Tutorial complete! Enjoy the game!" | Center modal |

---

## UI Specifications

### Tooltip Widget

```
┌─────────────────────────────────────┐
│  Tap to collect resources!          │
│  +10 Wood is ready                  │
│                                     │
│  [Skip Tutorial]                    │
└─────────────────┬───────────────────┘
                  │ ← Arrow
                  ▼
          [Building Sprite]
```

**Tooltip Properties:**
- Max width: 280px
- Padding: 16px
- Border radius: 12px
- Background: Dark semi-transparent (#1E1E1E, 90%)
- Text: White, 14sp
- Arrow: 12px triangle pointing at target

### Welcome Screen

```
┌──────────────────────────────────────────────┐
│                                              │
│         🏭 Trade Factory Masters 🏭          │
│                                              │
│     Welcome, Factory Manager!                │
│                                              │
│     Build your industrial empire:            │
│     • Place buildings to produce             │
│     • Collect resources                      │
│     • Trade for profit                       │
│     • Unlock automation                      │
│                                              │
│      ┌────────────────────────────┐         │
│      │       Start Building       │         │
│      └────────────────────────────┘         │
│                                              │
│           [Skip Tutorial]                    │
│                                              │
└──────────────────────────────────────────────┘
```

---

## Analytics Events

| Event | Parameters | Trigger |
|-------|------------|---------|
| `tutorial_started` | - | Welcome screen shown |
| `tutorial_step_completed` | `step_name`, `duration_seconds` | Each step complete |
| `tutorial_skipped` | `at_step`, `time_in_tutorial` | Skip button pressed |
| `tutorial_completed` | `total_duration_seconds` | All steps done |

### Expected Funnel

```
100% tutorial_started
 95% tutorial_first_building
 85% tutorial_first_collect
 75% tutorial_first_upgrade
 65% tutorial_market
 55% tutorial_tier2
 50% tutorial_completed
```

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Tooltip render | <50ms |
| State transition | <16ms (1 frame) |
| Arrow positioning | <10ms |
| Persistence save | <30ms |

---

## Dependencies

**Depends On:**
- ✅ EPIC-01 (Building placement)
- ✅ EPIC-02 (Resource collection, market)
- ✅ EPIC-06 (Progression tracker)

**Blocks:**
- Nothing (optional feature)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| First 3 steps completion | 80%+ |
| Full tutorial completion | 50%+ |
| Tutorial duration | 3-5 minutes |
| Skip rate | <30% |

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 1.0
