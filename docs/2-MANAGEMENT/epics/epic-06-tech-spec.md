# Epic 6: Progression & Quality System - Technical Specification

<!-- AI-INDEX: epic, tech-spec, progression, achievements, skills -->

**Epic:** EPIC-06 - Progression & Quality System
**Total SP:** 28
**Duration:** 2 weeks (Sprint 9, post-MVP)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03

---

## Overview

EPIC-06 implementuje system progresji, który prowadzi graczy od Tier 1 (podstawowa kolekcja) do Tier 2 (automatyzacja) przez jasne milestone'y i satysfakcjonujące celebracje. Epic jest krytyczny dla **retencji graczy** i **głębokości sesji**.

**Design Philosophy:** "Clear goals drive engagement" - jasne cele zwiększają D7 retention o 25-40%.

**Kluczowe cele:**
- **Tier 2 Unlock Gate:** 5 typów budynków + 10 budynków + 500 gold
- **60%+ Unlock Rate:** Gracze odblokowują Tier 2 w 2-3 godziny
- **Achievement System:** 7+ osiągnięć dla "completionist" gameplay
- **Extended Skills:** Rozbudowany system umiejętności (z EPIC-02)

---

## Objectives and Scope

### In Scope

**Tier 2 Unlock Requirements:**
- ✅ Wymagania: 5 typów budynków + 10 budynków + 500 gold
- ✅ Real-time progress tracking
- ✅ Walidacja przed unlock
- ✅ Persist do Firestore

**Progression Tracker UI:**
- ✅ Always-visible widget: "Tier 2: 3/5 types, 7/10 buildings, 350/500g"
- ✅ Progress bars z animacjami
- ✅ Tap to expand dla szczegółów
- ✅ 60 FPS updates

**Unlock Celebration:**
- ✅ Full-screen modal z fireworks
- ✅ Confetti particle effects
- ✅ Lista odblokowanych features
- ✅ "Continue" button

**Achievement System:**
- ✅ 7 osiągnięć Tier 1
- ✅ Achievement notifications (toast)
- ✅ Persistent storage (Hive + Firestore)
- ✅ Firebase Analytics tracking

**Extended Skill System:**
- ✅ Skill trees dla Mining, Smelting, Trading
- ✅ Skill points earned through gameplay
- ✅ Bonusy: speed, yield, prices
- ✅ Max level 10 per skill

### Out of Scope

- ❌ Tier 3+ progression (Month 2-3)
- ❌ Achievement leaderboards (v1.1)
- ❌ Daily/weekly challenges (Phase 2)
- ❌ Prestige system (v2.0)

---

## System Architecture

### Domain Layer
```
lib/domain/entities/
├── progression_state.dart       # Tier unlock progress
├── achievement.dart             # Achievement definition
├── skill_tree.dart              # Extended skill system
└── tier_unlock_requirements.dart

lib/domain/usecases/
├── progression/
│   ├── check_tier_unlock_usecase.dart
│   ├── track_progression_usecase.dart
│   └── unlock_tier_usecase.dart
├── achievements/
│   ├── check_achievements_usecase.dart
│   └── unlock_achievement_usecase.dart
└── skills/
    ├── upgrade_skill_usecase.dart
    └── calculate_skill_bonus_usecase.dart
```

### Presentation Layer
```
lib/presentation/
├── screens/
│   └── achievements_screen.dart
├── widgets/
│   ├── progression_tracker_widget.dart
│   ├── tier_unlock_celebration_modal.dart
│   ├── achievement_notification.dart
│   └── skill_tree_panel.dart
└── providers/
    ├── progression_provider.dart
    ├── achievement_provider.dart
    └── skill_provider.dart
```

---

## Key Specifications

### Tier 2 Unlock Requirements

| Requirement | Target | Description |
|-------------|--------|-------------|
| Building Types | 5/5 | All types placed (Mining, Storage, Smelter, Workshop, Farm) |
| Total Buildings | 10 | Any combination |
| Gold Earned | 500g | Lifetime total |

### Achievement Definitions

| ID | Title | Description | Trigger |
|----|-------|-------------|---------|
| `first_building` | First Steps | Place your first building | buildings >= 1 |
| `five_buildings` | Small Factory | Place 5 buildings | buildings >= 5 |
| `ten_buildings` | Growing Empire | Place 10 buildings | buildings >= 10 |
| `all_types` | Master Builder | Place all 5 building types | types >= 5 |
| `100_gold` | First Fortune | Earn 100 gold | gold >= 100 |
| `500_gold` | Wealthy Trader | Earn 500 gold | gold >= 500 |
| `tier2_unlocked` | Automation Master | Unlock Tier 2 | tier2 == true |

### Extended Skill System

| Skill | Levels | Bonus per Level | Max Bonus |
|-------|--------|-----------------|-----------|
| **Mining** | 1-10 | -5% cycle time | -50% time |
| **Smelting** | 1-10 | +5% yield | +50% yield |
| **Trading** | 1-10 | +5% sell price | +50% price |
| **Crafting** | 1-10 | -5% recipe cost | -50% cost |
| **Automation** | 1-10 | +10% conveyor speed | +100% speed |

**Skill Points:**
- Earn 1 SP per milestone (every 50 gold, every 5 buildings)
- Earn 1 SP per achievement unlock
- Can redistribute (reset) with gold cost

---

## UI Specifications

### Progression Tracker Widget

```
┌─────────────────────────────────────────────┐
│  TIER 2 PROGRESS                       ▼   │
│  ████████░░ 75%                            │
│                                             │
│  ✓ Building Types  5/5  ████████████ 100%  │
│  ○ Total Buildings 7/10 ███████░░░░  70%   │
│  ○ Gold Earned    350/500 ███████░░░  70%  │
└─────────────────────────────────────────────┘
```

**Behavior:**
- Collapsed: Shows overall % only
- Tap: Expands to show breakdown
- Updates: Smooth animation on progress

### Celebration Modal

```
┌──────────────────────────────────────────────┐
│                                              │
│           🎉 TIER 2 UNLOCKED! 🎉             │
│                                              │
│        ✨ [Fireworks Animation] ✨           │
│        🎊 [Confetti Falling]   🎊           │
│                                              │
│   Congratulations! You've mastered          │
│   the basics and unlocked:                  │
│                                              │
│   ✓ Conveyors (Automated transport)         │
│   ✓ Advanced Production Chains              │
│   ✓ Splitters & Filters                     │
│                                              │
│      ┌────────────────────────────┐         │
│      │   Continue to Tier 2      │         │
│      └────────────────────────────┘         │
│                                              │
└──────────────────────────────────────────────┘
```

**Animation Timeline:**
- 0.0s: Modal fades in (300ms)
- 0.3s: Title appears with scale
- 0.6s: Fireworks start (2s duration)
- 0.8s: Confetti falls
- 1.0s: Feature list animates in
- 2.0s: Continue button appears

### Skill Tree Panel

```
┌─────────────────────────────────────────────┐
│  SKILLS                      SP: 5 ⬆       │
├─────────────────────────────────────────────┤
│  ⛏ Mining         Lv 3  ████░░░░░░  +15%  │
│  🔥 Smelting       Lv 2  ██░░░░░░░░  +10%  │
│  💰 Trading        Lv 5  █████░░░░░  +25%  │
│  🔧 Crafting       Lv 1  █░░░░░░░░░  +5%   │
│  ⚙️ Automation     Lv 0  ░░░░░░░░░░  -     │
│                                             │
│  [Upgrade Mining - 1 SP]                    │
└─────────────────────────────────────────────┘
```

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Progression UI updates | <16ms (60 FPS) |
| Celebration animation | 60 FPS sustained |
| State save (Hive) | <50ms |
| Achievement check | <10ms |
| Modal load time | <300ms |

---

## Dependencies

**Depends On:**
- ✅ EPIC-01 (Building placement)
- ✅ EPIC-02 (Gold tracking, basic skills)

**Blocks:**
- → EPIC-03 (Tier 2 gates conveyors)
- → EPIC-07 (Tutorial uses progression)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Tier 2 Unlock Rate | 60%+ within 2-3 hours |
| Progression UI Visibility | 100% see tracker in first 60s |
| Celebration Engagement | 90%+ watch full animation |
| Achievement Awareness | 50%+ tap notifications |
| Code Coverage | 100% for progression logic |

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 1.0
