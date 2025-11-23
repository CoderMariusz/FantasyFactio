# 🔄 BATCH IMPLEMENTATION PLAN - Sprint 2, 3, 4

**Total:** 47 SP across 10 stories
**Estimated Duration:** 6-7 days (hybrid approach)
**Parallel Tracks:** 4 independent tracks

---

## 📊 PARALLEL TRACKS

### Track 1: Core Rendering 🎨
**Focus:** Visual presentation layer
**Stories:** 1 (3 SP)

```
STORY-01.7: Building Sprite Component (3 SP)
├─ Can start: IMMEDIATELY ✅
└─ Independent: No blockers
```

### Track 2: Firebase Backend ☁️
**Focus:** Authentication & cloud storage
**Stories:** 2 (9 SP)

```
STORY-09.1: Firebase Auth (4 SP)
├─ Can start: IMMEDIATELY ✅
└─ Blocks: STORY-09.2

STORY-09.2: Firestore Schema (5 SP)
├─ Depends on: STORY-09.1
└─ Sequential with 09.1
```

### Track 3: Economy System 💰
**Focus:** Game economy & market
**Stories:** 5 (23 SP)

```
STORY-02.1: Building Definitions (3 SP)
├─ Can start: IMMEDIATELY ✅
├─ Blocks: 02.2, 02.5
└─ Critical: Unblocks 3 stories!

STORY-02.2: Resource Definitions (2 SP)
├─ Depends on: STORY-02.1
└─ Blocks: 02.3

STORY-02.5: Building Placement (8 SP)
├─ Depends on: STORY-02.1
└─ Parallel to Market chain

STORY-02.3: NPC Market UI (5 SP)
├─ Depends on: STORY-02.2
└─ Blocks: 02.4

STORY-02.4: Market Transaction (5 SP)
└─ Depends on: STORY-02.3
```

### Track 4: Automation System 🤖
**Focus:** Pathfinding & conveyors
**Stories:** 2 (10 SP)

```
STORY-03.1: A* Pathfinding (8 SP)
├─ Can start: IMMEDIATELY ✅
└─ Blocks: STORY-03.2

STORY-03.2: Conveyor Entity (2 SP)
└─ Depends on: STORY-03.1
```

---

## 🎯 BATCH GROUPINGS

### BATCH 1: Foundation Parallel (4 stories, 18 SP)
**Day 1-2** | All dependencies met ✅

| Story | Track | SP | Can Parallelize? |
|-------|-------|-----|------------------|
| STORY-01.7 Sprite | Rendering | 3 | ✅ Session 1 |
| STORY-09.1 Auth | Firebase | 4 | ✅ Session 2 |
| STORY-02.1 Definitions | Economy | 3 | ✅ Session 3 |
| STORY-03.1 A* Pathfinding | Automation | 8 | ✅ Session 4 |

**Deliverable:** Sprites render, Firebase auth works, building defs ready, A* works

---

### BATCH 2: Secondary Builds (2 stories, 7 SP)
**Day 3** | Depends on BATCH 1

| Story | Track | SP | Depends On |
|-------|-------|-----|------------|
| STORY-02.2 Resources | Economy | 2 | STORY-02.1 |
| STORY-09.2 Firestore | Firebase | 5 | STORY-09.1 |

**Can Parallelize:** ✅ Yes (different tracks)

**Deliverable:** Resource definitions done, Firestore schema ready

---

### BATCH 3: Small Finisher (1 story, 2 SP)
**Day 4** | Depends on BATCH 1

| Story | Track | SP | Depends On |
|-------|-------|-----|------------|
| STORY-03.2 Conveyor | Automation | 2 | STORY-03.1 |

**Deliverable:** Conveyor entity complete (finishes automation track)

---

### BATCH 4: Building Systems (1 story, 8 SP)
**Day 5** | Depends on BATCH 2

| Story | Track | SP | Depends On |
|-------|-------|-----|------------|
| STORY-02.5 Placement | Economy | 8 | STORY-02.1 |

**Deliverable:** Building placement works (drag & drop)

---

### BATCH 5: Market System (2 stories, 10 SP)
**Day 6-7** | Depends on BATCH 2 & 4

| Story | Track | SP | Depends On |
|-------|-------|-----|------------|
| STORY-02.3 Market UI | Economy | 5 | STORY-02.2 |
| STORY-02.4 Transaction | Economy | 5 | STORY-02.3 |

**Sequential:** Market UI → Transaction logic

**Deliverable:** Full market system functional

---

## 📅 RECOMMENDED TIMELINE

### Option A: Maximum Parallelization ⚡
**Duration:** 4-5 days
**Approach:** Run 4 parallel sessions

```
Day 1-2: BATCH 1 (4 parallel sessions)
  Session 1: STORY-01.7 (Rendering)
  Session 2: STORY-09.1 (Firebase)
  Session 3: STORY-02.1 (Economy)
  Session 4: STORY-03.1 (Automation)

Day 3: BATCH 2 (2 parallel sessions)
  Session 1: STORY-02.2
  Session 2: STORY-09.2

Day 4: BATCH 3 + 4 (2 parallel sessions)
  Session 1: STORY-03.2 (small)
  Session 2: STORY-02.5 (placement)

Day 5: BATCH 5 (sequential)
  Session 1: STORY-02.3 → STORY-02.4
```

**Pros:** Fastest (4-5 days)
**Cons:** High token usage, complex coordination

---

### Option B: Sequential by Track 🐢
**Duration:** 8-10 days
**Approach:** Complete one track at a time

```
Days 1-2:   Track 1 (Rendering) - 3 SP
Days 2-4:   Track 2 (Firebase) - 9 SP
Days 3-8:   Track 3 (Economy) - 23 SP
Days 6-10:  Track 4 (Automation) - 10 SP
```

**Pros:** Simple, no coordination needed
**Cons:** Slowest, wastes parallelization potential

---

### Option C: Hybrid Approach 🎯 **RECOMMENDED**
**Duration:** 6-7 days
**Approach:** Selective parallelization

```
Day 1: BATCH 1A (parallel)
  - STORY-01.7 (Rendering)
  - STORY-09.1 (Firebase)
  Total: 7 SP

Day 2: BATCH 1B (parallel)
  - STORY-02.1 (Economy)
  - STORY-03.1 (Automation)
  Total: 11 SP

Day 3: BATCH 2 (parallel)
  - STORY-02.2 (with 02.1 context)
  - STORY-09.2 (with 09.1 context)
  Total: 7 SP

Day 4: BATCH 3
  - STORY-03.2 (small, with 03.1 context)
  Total: 2 SP

Day 5: BATCH 4
  - STORY-02.5 (Building Placement)
  Total: 8 SP

Day 6: BATCH 5A
  - STORY-02.3 (Market UI)
  Total: 5 SP

Day 7: BATCH 5B
  - STORY-02.4 (Market Transaction)
  Total: 5 SP
```

**Velocity:** 6.7 SP/day
**Pros:** Balanced speed + safety, optimized token usage
**Cons:** None significant

---

## 🔧 TOKEN OPTIMIZATION

### Context Grouping Strategy

**Group 1: Flame Context**
- STORY-01.7 (standalone)

**Group 2: Firebase Context**
- STORY-09.1 → STORY-09.2 (same session)

**Group 3: Economy Definitions**
- STORY-02.1 → STORY-02.2 → STORY-02.5 (building-related)

**Group 4: Market Context**
- STORY-02.3 → STORY-02.4 (UI + logic together)

**Group 5: Automation Context**
- STORY-03.1 → STORY-03.2 (pathfinding + entity)

**Token Savings:** ~40% compared to independent sessions

---

## ⚠️ RISKS & BOTTLENECKS

### Critical Story: STORY-02.1 (Building Definitions)
**Blocks:** 3 downstream stories (02.2, 02.5, 02.3)

**Mitigation:** Prioritize early in Day 2

### High-Risk Stories

| Story | Risk | Mitigation |
|-------|------|------------|
| STORY-03.1 | A* performance <100ms | Profile early, spatial hashing |
| STORY-02.5 | Placement UI complexity | Split into: ghost → validate → place |
| STORY-02.4 | Economic balance | Comprehensive unit tests |

---

## ✅ SUCCESS MILESTONES

- [ ] **Day 2:** All foundation stories complete (BATCH 1)
- [ ] **Day 3:** Firebase + Economy defs complete (BATCH 2)
- [ ] **Day 4:** Automation system complete (BATCH 3)
- [ ] **Day 5:** Building placement works (BATCH 4)
- [ ] **Day 7:** Full market system functional (BATCH 5)

---

## 📈 DEPENDENCY GRAPH

```
PARALLEL TRACKS:

Track 1 (Rendering):  [01.7]

Track 2 (Firebase):   [09.1] ──→ [09.2]

Track 3 (Economy):    [02.1] ──┬──→ [02.2] ──→ [02.3] ──→ [02.4]
                               └──→ [02.5]

Track 4 (Automation): [03.1] ──→ [03.2]


BATCH EXECUTION:

BATCH 1 (Parallel):
  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐
  │ 01.7  │  │ 09.1  │  │ 02.1  │  │ 03.1  │
  └───────┘  └───┬───┘  └───┬───┘  └───┬───┘
                 │          │          │
BATCH 2 (Parallel):        │          │
                 ▼          ▼          │
              ┌───────┐  ┌───────┐    │
              │ 09.2  │  │ 02.2  │    │
              └───────┘  └───┬───┘    │
                             │        │
                         ┌───┴───┐    │
                         │       │    │
BATCH 3:                 │       │    ▼
                         │       │  ┌───────┐
                         │       │  │ 03.2  │
                         │       │  └───────┘
BATCH 4:                 │       │
                         │       ▼
                         │    ┌───────┐
                         │    │ 02.5  │
                         │    └───────┘
BATCH 5:                 ▼
                      ┌───────┐
                      │ 02.3  │
                      └───┬───┘
                          ▼
                      ┌───────┐
                      │ 02.4  │
                      └───────┘
```

---

## 🚀 NEXT STEPS

1. **Choose approach:** Option A, B, or C?
2. **Start BATCH 1:** Pick first story to implement
3. **Track progress:** Update sprint-status.yaml after each story

**Recommended:** Start with **Option C (Hybrid)** - Day 1 BATCH 1A (STORY-01.7 + STORY-09.1)

---

*Generated: 2025-11-23*
*Based on: Dependency analysis of 10 stories across Sprint 2-4*
