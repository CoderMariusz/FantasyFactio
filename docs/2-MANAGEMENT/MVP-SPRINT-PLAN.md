# Trade Factory Masters - MVP Sprint Plan

<!-- AI-INDEX: sprint-plan, timeline, mvp, velocity -->

**Version:** 2.0
**Date:** 2025-12-03
**Duration:** 11 Sprints
**Total SP:** 299 (including Epic 00)

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Total Epics** | 12 (Epic 00-11) |
| **Total Stories** | 66 |
| **Total Story Points** | 299 SP |
| **Velocity** | 25-30 SP/sprint |
| **Duration** | 11 sprints (~11-12 weeks) |
| **Critical Path** | EPIC-00→01→02→03→04→08/09→10→11 |

---

## Sprint Allocation

### Sprint 1: Foundation ✅
**Duration:** Week 1
**Total SP:** 47
**Status:** ✅ COMPLETE

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-00 | 00.1-00.4 | 13 | ✅ Done |
| EPIC-01 | 01.1-01.8 | 34 | ✅ Done (bugs fixed) |

**Deliverables:**
- ✅ Flutter/Flame project initialized
- ✅ Firebase configured
- ✅ CI/CD pipeline working
- ✅ Core gameplay loop (COLLECT → DECIDE → UPGRADE)
- ✅ 50×50 grid with dual-zoom camera

---

### Sprint 2-3: Tier 1 Economy
**Duration:** Weeks 2-3
**Total SP:** 26
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-02 | 02.1-02.7 | 26 | 📋 Ready |

**Deliverables:**
- 6 Building types (Tier 1)
- 7 Resource types
- NPC Market (3 traders: Kupiec, Inżynier, Nomada)
- Hub Screen, Storage, Trading UI

**Exit Criteria:**
- [ ] Player can place all 6 building types
- [ ] Buy/sell resources at NPC Market
- [ ] Economic balance validated (1000g in 30 min)

---

### Sprint 4-5: Automation System
**Duration:** Weeks 4-5
**Total SP:** 42
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-03 | 03.1-03.8 | 42 | 📋 Ready |

**Deliverables:**
- A* Pathfinding (<100ms)
- Conveyor transport system
- Filtering & Splitter nodes
- Storage networks
- 60 FPS with 50 conveyors

**Exit Criteria:**
- [ ] Resources flow automatically via conveyors
- [ ] Filtering routes resources correctly
- [ ] Performance: 60 FPS maintained

---

### Sprint 6: Offline Production
**Duration:** Week 6
**Total SP:** 26
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-04 | 04.1-04.6 | 26 | 📋 Ready |

**Deliverables:**
- Offline calculator (80% efficiency)
- 24-hour cap
- Welcome Back modal
- Ad boost (2× rewards)
- Time validation (anti-cheat)

**Exit Criteria:**
- [ ] Production continues offline
- [ ] Welcome modal shows correct resources
- [ ] Ad boost doubles collection

---

### Sprint 7: Progression System
**Duration:** Week 7
**Total SP:** 28
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-06 | 06.1-06.6 | 28 | 📋 Ready |

**Deliverables:**
- Tier 2 unlock requirements (5 types + 10 buildings + 500g)
- Progress tracker UI
- Celebration animation
- Achievement system
- Extended skill trees (5 trees)

**Exit Criteria:**
- [ ] Tier 2 unlocks after meeting requirements
- [ ] Achievements award correctly
- [ ] Skill system working

---

### Sprint 8: Mobile UX
**Duration:** Week 8
**Total SP:** 29
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-05 | 05.1-05.8 | 29 | 📋 Ready |

**Deliverables:**
- Touch controls (tap, drag, pinch)
- Gesture system optimization
- Haptic feedback
- 60 FPS on Snapdragon 660
- One-handed UI mode
- Accessibility features

**Exit Criteria:**
- [ ] All gestures responsive
- [ ] Haptics feel satisfying
- [ ] Performance targets met

---

### Sprint 9: Tutorial & Firebase
**Duration:** Week 9
**Total SP:** 45
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-07 | 07.1-07.5 | 21 | 📋 Ready |
| EPIC-09 | 09.1-09.6 | 24 | 📋 Ready |

**Deliverables:**

*Tutorial (EPIC-07):*
- Tutorial state machine (7 states)
- Contextual tooltips
- FTUE flow (First 10 minutes)
- Skip option

*Firebase Backend (EPIC-09):*
- Auth flow (Anonymous → Google/Apple)
- Cloud save with Firestore
- Offline-first sync
- Security rules (anti-cheat)
- **Cloud Functions (REQUIRED)** - time validation, receipt validation
- Cost monitoring (<$45/month at 100k MAU)

**Exit Criteria:**
- [ ] New player completes tutorial in 3-5 minutes
- [ ] Cloud save syncs across devices
- [ ] Security rules block cheating

---

### Sprint 10: Monetization & Analytics
**Duration:** Week 10
**Total SP:** 36
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-08 | 08.1-08.5 | 23 | 📋 Ready |
| EPIC-10 | 10.1-10.4 | 13 | 📋 Ready |

**Deliverables:**

*Monetization (EPIC-08):*
- IAP products ($1-$10, lifetime cap $10)
- Purchase manager
- Platform integration (iOS/Android)
- Rewarded ads (ad boost)
- Shop UI

*Analytics (EPIC-10):*
- Firebase Analytics integration
- D7 retention tracking (target: 30-35%)
- Tier 2 unlock rate (target: 60%+)
- Custom gameplay events

**Exit Criteria:**
- [ ] IAP purchases work
- [ ] $10 cap enforced
- [ ] Analytics events appearing in Firebase

---

### Sprint 11: Testing & Launch Prep
**Duration:** Week 11
**Total SP:** 20
**Status:** 📋 Ready

| Epic | Stories | SP | Status |
|------|---------|-----|--------|
| EPIC-11 | 11.1-11.8 | 20 | 📋 Ready |

**Deliverables:**
- 300+ unit tests (80%+ coverage)
- 100+ widget tests
- 50 integration tests
- 10 E2E tests (Firebase Test Lab)
- 5 performance tests
- CI/CD pipeline verification
- Manual QA checklist (50 items)

**Exit Criteria:**
- [ ] All tests pass
- [ ] 80%+ coverage
- [ ] P0/P1 bugs: 0
- [ ] Ready for soft launch

---

## Summary Table

| Sprint | Week | Epics | SP | Cumulative |
|--------|------|-------|-----|------------|
| 1 | 1 | 00, 01 | 47 | 47 ✅ |
| 2-3 | 2-3 | 02 | 26 | 73 |
| 4-5 | 4-5 | 03 | 42 | 115 |
| 6 | 6 | 04 | 26 | 141 |
| 7 | 7 | 06 | 28 | 169 |
| 8 | 8 | 05 | 29 | 198 |
| 9 | 9 | 07, 09 | 45 | 243 |
| 10 | 10 | 08, 10 | 36 | 279 |
| 11 | 11 | 11 | 20 | **299** |

---

## Critical Path

```
EPIC-00 (13 SP) ✅
    │
    ▼
EPIC-01 (34 SP) ✅
    │
    ▼
EPIC-02 (26 SP) ← Sprint 2-3
    │
    ▼
EPIC-03 (42 SP) ← Sprint 4-5 [LONGEST]
    │
    ├─────────────────────────┐
    ▼                         ▼
EPIC-04 (26 SP)          EPIC-06 (28 SP)
    │                         │
    │                         ▼
    │                    EPIC-07 (21 SP)
    │
    ├─────────────────────────┐
    ▼                         ▼
EPIC-08 (23 SP)          EPIC-09 (24 SP)
    │                         │
    └────────────┬────────────┘
                 ▼
           EPIC-10 (13 SP)
                 │
                 ▼
           EPIC-11 (20 SP)
                 │
                 ▼
            🚀 MVP LAUNCH
```

**Critical Path Length:** 47 + 26 + 42 + 26 + 23 + 24 + 13 + 20 = 221 SP
**Parallel Paths:** EPIC-05, EPIC-06, EPIC-07 can run in parallel

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| EPIC-03 takes longer | High | High | Start early, buffer 1 week |
| Firebase costs exceed | Medium | Medium | Monitor weekly, optimize |
| Performance issues | Medium | High | Test on budget devices early |
| IAP integration delays | Medium | Medium | Start store setup in Sprint 8 |

---

## Definition of MVP Done

- [ ] All 12 epics implemented
- [ ] 299 SP completed
- [ ] 80%+ test coverage
- [ ] 0 P0/P1 bugs
- [ ] D7 retention validated (30-35%)
- [ ] Firebase costs <$45/month projected
- [ ] Soft launch on Google Play

---

**Last Updated:** 2025-12-03
**Next Review:** After Sprint 2
