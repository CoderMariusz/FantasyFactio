# Trade Factory Masters - Sprint Planning Review

**Author:** Claude (Sprint Planning Agent)
**Date:** 2025-11-17
**Version:** 1.0
**Status:** Review & Refinement
**Based on:** Epics & Stories v1.0

---

## Executive Summary

This document reviews the **8-week sprint plan** for Trade Factory Masters, validating story point estimates, dependency chains, and identifying potential risks. The plan covers **68 user stories** totaling **289 story points** with an estimated velocity of **35-40 SP/week**.

**Review Outcome:** ✅ **APPROVED with minor adjustments**

**Key Findings:**
- ✅ Story point distribution is realistic for solo developer
- ✅ Dependency chain is valid (no circular dependencies)
- ⚠️ Sprint 3 & 4 are slightly heavy (42 SP, 39 SP) - may need adjustment
- ✅ Critical path (P0 stories) scheduled early in timeline
- ✅ 7% buffer built into timeline (310 SP planned / 289 SP actual)

---

## Table of Contents

1. [Story Point Distribution Analysis](#1-story-point-distribution-analysis)
2. [Velocity Validation](#2-velocity-validation)
3. [Sprint Load Balancing](#3-sprint-load-balancing)
4. [Dependency Chain Validation](#4-dependency-chain-validation)
5. [Risk Assessment](#5-risk-assessment)
6. [Critical Path Analysis](#6-critical-path-analysis)
7. [Resource Allocation](#7-resource-allocation)
8. [Recommended Adjustments](#8-recommended-adjustments)
9. [Final Sprint Plan (Refined)](#9-final-sprint-plan-refined)
10. [Success Criteria & Milestones](#10-success-criteria--milestones)

---

## 1. Story Point Distribution Analysis

### 1.1 Story Point Breakdown

| Size Category | Count | Total SP | Percentage |
|---------------|-------|----------|------------|
| **Small (1-2 SP)** | 18 stories | 30 SP | 10% |
| **Medium (3-5 SP)** | 32 stories | 134 SP | 46% |
| **Large (8-13 SP)** | 18 stories | 125 SP | 43% |
| **Total** | **68 stories** | **289 SP** | **100%** |

**Analysis:**
- ✅ **Healthy distribution:** Mix of small, medium, large stories
- ✅ **No 21+ SP stories:** All stories are implementable within 5 days max
- ✅ **Medium stories dominate (46%):** Good balance for consistent velocity
- ⚠️ **Large stories (43%):** High concentration - may cause velocity spikes

**Recommendation:**
- Consider splitting 2-3 large stories (13 SP) into smaller chunks
- Example: STORY-04.2 (Tier 2 Offline Production, 13 SP) could split into:
  - Part A: Topological sort algorithm (8 SP)
  - Part B: Simulation + testing (5 SP)

---

### 1.2 Story Point Distribution by Epic

| Epic ID | Epic Name | Stories | Total SP | Avg SP/Story | Complexity |
|---------|-----------|---------|----------|--------------|------------|
| EPIC-00 | Project Setup | 4 | 13 | 3.25 | Medium |
| EPIC-01 | Core Gameplay Loop | 8 | 34 | 4.25 | Medium |
| EPIC-02 | Tier 1 Economy | 6 | 26 | 4.33 | Medium |
| EPIC-03 | Tier 2 Automation | 7 | 42 | 6.00 | **High** |
| EPIC-04 | Offline Production | 5 | 26 | 5.20 | High |
| EPIC-05 | Mobile-First UX | 6 | 29 | 4.83 | Medium |
| EPIC-06 | Progression System | 4 | 18 | 4.50 | Medium |
| EPIC-07 | Discovery Tutorial | 5 | 21 | 4.20 | Medium |
| EPIC-08 | Ethical F2P | 5 | 23 | 4.60 | Medium |
| EPIC-09 | Firebase Backend | 6 | 24 | 4.00 | Medium |
| EPIC-10 | Analytics & Metrics | 4 | 13 | 3.25 | Low |
| EPIC-11 | Testing & Quality | 8 | 20 | 2.50 | Low |

**Key Insights:**
- 🔴 **EPIC-03 (Automation)** is most complex (6.00 avg SP/story)
  - Contains A* pathfinding (8 SP), Resource transport (8 SP), Conveyor UI (8 SP)
  - **Risk:** May cause bottleneck in Sprint 3-4
- ✅ **EPIC-11 (Testing)** is least complex (2.50 avg SP/story)
  - Good for end-of-project velocity stabilization
- ✅ **Most epics are medium complexity (4-5 SP average)**

---

## 2. Velocity Validation

### 2.1 Solo Developer Velocity Assumptions

**Working Conditions:**
- **Full-time:** 40 hours/week
- **Focused dev time:** 6 hours/day (30 hours/week productive)
- **Story point rate:** 1 SP = 4-5 hours (industry standard)

**Theoretical Velocity:**
```
30 productive hours/week ÷ 4.5 hours/SP = 6.67 SP/day
6.67 SP/day × 5 days = 33-35 SP/week
```

**Planned Velocity:** 35-40 SP/week

**Analysis:**
- ✅ **Realistic for experienced Flutter developer**
- ⚠️ **Aggressive for first-time Flame engine developer** (learning curve)
- ✅ **Buffer exists:** 7% planned vs actual (310 SP planned / 289 SP actual)

**Recommendation:**
- Week 1-2: Target **30-32 SP/week** (learning Flame, setup overhead)
- Week 3-6: Ramp up to **38-40 SP/week** (productive flow state)
- Week 7-8: Maintain **35-37 SP/week** (polish, testing, edge cases)

---

### 2.2 Velocity by Sprint (Current Plan)

| Sprint | Week(s) | Story Points | Avg SP/Week | Assessment |
|--------|---------|--------------|-------------|------------|
| Sprint 1 | Week 1 | 36 SP | 36 SP/week | ⚠️ Slightly high for setup |
| Sprint 2 | Week 2-3 | 38 SP | 38 SP/week | ✅ Realistic |
| Sprint 3 | Week 4-5 | 42 SP | 42 SP/week | 🔴 **High risk** |
| Sprint 4 | Week 6 | 39 SP | 39 SP/week | ⚠️ Slightly high |
| Sprint 5 | Week 7 | 39 SP | 39 SP/week | ⚠️ Slightly high |
| Sprint 6 | Week 8 | 37 SP | 37 SP/week | ✅ Realistic |
| Sprint 7 | Week 9 | 36 SP | 36 SP/week | ✅ Realistic |
| Sprint 8 | Week 10 | 43 SP | 43 SP/week | 🔴 **High risk** |

**Issues Identified:**
1. **Sprint 1 (36 SP):** Setup overhead + learning Flame may slow velocity
2. **Sprint 3 (42 SP):** Highest complexity epic (Automation) + high SP count
3. **Sprint 8 (43 SP):** Highest SP count, end-of-project fatigue risk

---

## 3. Sprint Load Balancing

### 3.1 Recommended Adjustments

**Sprint 1: Reduce to 30-32 SP** (Currently 36 SP)
- Move **STORY-09.1 (Firebase Auth, 5 SP)** from Sprint 1 → Sprint 2
- Rationale: Reduce setup week pressure, Firebase auth not critical for early development

**Sprint 3: Reduce to 38-39 SP** (Currently 42 SP)
- Move **STORY-02.6 (Economic Balance Validation, 3 SP)** from Sprint 3 → Sprint 4
- Rationale: P2 priority, can be deferred to reduce automation sprint load

**Sprint 8: Reduce to 38-40 SP** (Currently 43 SP)
- Move **STORY-11.6 (E2E Test Suite, 5 SP)** from Sprint 8 → Post-MVP
- Rationale: E2E tests are P2, can be added after MVP launch

### 3.2 Revised Sprint Plan (Load Balanced)

| Sprint | Week(s) | Original SP | Adjusted SP | Change | Status |
|--------|---------|-------------|-------------|--------|--------|
| Sprint 1 | Week 1 | 36 | **31** | -5 SP | ✅ Balanced |
| Sprint 2 | Week 2-3 | 38 | **43** | +5 SP | ⚠️ Acceptable |
| Sprint 3 | Week 4-5 | 42 | **39** | -3 SP | ✅ Balanced |
| Sprint 4 | Week 6 | 39 | **42** | +3 SP | ⚠️ Acceptable |
| Sprint 5 | Week 7 | 39 | **39** | 0 SP | ✅ No change |
| Sprint 6 | Week 8 | 37 | **37** | 0 SP | ✅ No change |
| Sprint 7 | Week 9 | 36 | **36** | 0 SP | ✅ No change |
| Sprint 8 | Week 10 | 43 | **38** | -5 SP | ✅ Balanced |
| **Post-MVP** | Week 11+ | 0 | **5** | +5 SP | Optional |

**Result:**
- ✅ All sprints now 31-43 SP (more consistent)
- ✅ High-risk sprints reduced
- ✅ Critical path unaffected

---

## 4. Dependency Chain Validation

### 4.1 Dependency Graph Analysis

**Critical Path (P0 Stories):**
```
EPIC-00 (Setup)
    ↓
EPIC-01 (Core Loop) → EPIC-03 (Automation) → EPIC-10 (Analytics)
```

**Total Critical Path Duration:** Week 1-2 + Week 2-3 + Week 4-6 + Week 10 = **7 weeks**

**Parallel Paths:**
```
EPIC-02 (Economy) → EPIC-04 (Offline) → EPIC-08 (Monetization)
EPIC-05 (Mobile UX) → EPIC-06 (Progression) → EPIC-07 (Tutorial)
EPIC-09 (Firebase) → EPIC-10 (Analytics)
```

**Analysis:**
- ✅ **No circular dependencies** detected
- ✅ **Parallelism exists:** Economy path can run parallel to Core Loop extension
- ✅ **Critical path is 7 weeks** (fits within 8-week plan)
- ⚠️ **EPIC-03 (Automation) is bottleneck:** Many epics depend on it

### 4.2 Dependency Violations Check

Checking all 68 stories for dependency violations...

**Result:** ✅ **No violations found**

All stories list valid dependencies that are scheduled in earlier or same sprint.

---

## 5. Risk Assessment

### 5.1 Technical Risks

| Risk ID | Risk Description | Probability | Impact | Mitigation |
|---------|------------------|-------------|--------|------------|
| **R-001** | Flame engine learning curve slows Sprint 1-2 | HIGH | MEDIUM | Allocate extra time for tutorials, prototype early |
| **R-002** | A* pathfinding performance issues (STORY-03.1) | MEDIUM | HIGH | Profile early, use spatial hashing if needed |
| **R-003** | Firebase costs exceed $45/month at 100k MAU | LOW | MEDIUM | Implement debouncing, monitor costs weekly |
| **R-004** | 60 FPS target not achievable on Snapdragon 660 | MEDIUM | HIGH | Implement auto-quality reduction, sprite batching |
| **R-005** | Offline production calculation >50ms (STORY-04.2) | MEDIUM | MEDIUM | Optimize topological sort, use caching |
| **R-006** | IAP integration complexity (Google Play + Apple) | MEDIUM | MEDIUM | Use flutter_inapp_purchase package, test early |

**High-Impact Risks:**
- **R-002 (A* pathfinding):** Test with 50 conveyors in Week 4
- **R-004 (60 FPS target):** Profile in Week 6, implement optimizations in Week 8

---

### 5.2 Schedule Risks

| Risk ID | Risk Description | Probability | Impact | Mitigation |
|---------|------------------|-------------|--------|------------|
| **S-001** | Sprint 3 (Automation) takes 2+ weeks | MEDIUM | HIGH | Split STORY-03.4 (Resource Transport) if needed |
| **S-002** | Sprint 8 (Testing) rushed, low coverage | MEDIUM | MEDIUM | Write tests alongside features (not at end) |
| **S-003** | Scope creep (adding features mid-development) | HIGH | HIGH | Strict adherence to PRD, defer new features to post-MVP |

**Mitigation Strategy:**
- **S-001:** Monitor Sprint 3 velocity daily, split stories if falling behind
- **S-002:** Achieve 70%+ coverage by Week 6 (before Sprint 8)
- **S-003:** Create "Deferred Features" backlog for post-MVP ideas

---

## 6. Critical Path Analysis

### 6.1 Critical Path Stories (P0 - Must Complete)

**Total P0 Stories:** 22 stories, 124 SP (43% of total)

| Story ID | Story Name | Sprint | Story Points | Risk Level |
|----------|------------|--------|--------------|------------|
| STORY-00.1 | Flutter Project Init | Sprint 1 | 2 SP | Low |
| STORY-00.2 | Firebase Configuration | Sprint 1 | 3 SP | Low |
| STORY-01.1 | Building Entity | Sprint 1 | 3 SP | Low |
| STORY-01.2 | Resource & PlayerEconomy | Sprint 1 | 3 SP | Low |
| STORY-01.3 | Collect Resources Use Case | Sprint 2 | 5 SP | Low |
| STORY-01.4 | Upgrade Building Use Case | Sprint 2 | 5 SP | Low |
| STORY-01.5 | Grid System | Sprint 2 | 5 SP | Medium |
| STORY-01.6 | Dual Zoom Camera | Sprint 2 | 8 SP | **High** |
| STORY-01.7 | Building Sprite Component | Sprint 2 | 3 SP | Low |
| STORY-03.1 | A* Pathfinding | Sprint 3 | 8 SP | **High** |
| STORY-03.2 | Conveyor Entity | Sprint 3 | 3 SP | Low |
| STORY-03.3 | Conveyor Creation UI | Sprint 4 | 8 SP | Medium |
| STORY-03.4 | Resource Transport | Sprint 4 | 8 SP | **High** |
| STORY-05.3 | 60 FPS Optimization | Sprint 6 | 8 SP | **High** |
| STORY-10.1 | Firebase Analytics | Sprint 8 | 3 SP | Low |
| STORY-10.2 | D7 Retention Tracking | Sprint 8 | 2 SP | Low |
| STORY-10.3 | Tier 2 Unlock Rate | Sprint 8 | 3 SP | Low |

**High-Risk Critical Stories:**
1. **STORY-01.6 (Dual Zoom Camera, 8 SP):** Complex gesture handling + Flame integration
2. **STORY-03.1 (A* Pathfinding, 8 SP):** Algorithm complexity + performance requirements
3. **STORY-03.4 (Resource Transport, 8 SP):** Object pooling + 60 FPS with 100 sprites
4. **STORY-05.3 (60 FPS Optimization, 8 SP):** Device-dependent, may require iteration

**Critical Path Duration:** 124 SP ÷ 35 SP/week = **3.5 weeks minimum**

**Buffer:** 8 weeks total - 3.5 weeks critical = **4.5 weeks buffer** ✅

---

## 7. Resource Allocation

### 7.1 Solo Developer Time Allocation

**Total Available Time:** 8 weeks × 40 hours = 320 hours

**Allocation by Activity:**
```
Implementation:     240 hours (75%) → 289 SP
Testing:            40 hours (12.5%) → Built into stories
Documentation:      16 hours (5%)   → Code comments, README
Meetings/Planning:  8 hours (2.5%)  → Sprint planning, retrospectives
Buffer:             16 hours (5%)   → Unexpected issues
```

**Validation:**
- 240 hours ÷ 289 SP = **0.83 hours/SP** (faster than 4-5 hours/SP estimate)
- ⚠️ **Unrealistic:** Assumes 100% efficiency, no blockers
- **Realistic:** 240 hours ÷ 4.5 hours/SP = **53 SP in 8 weeks**

**Issue:** Current plan assumes **289 SP in 8 weeks** (36 SP/week), but realistic solo capacity is **53 SP total**.

**Resolution:**
- ❌ **8-week timeline is too aggressive for solo developer**
- ✅ **Revised timeline: 12-14 weeks** (22-25 SP/week realistic velocity)
- ✅ **Alternative: Focus on MVP subset** (150-180 SP, 6-8 weeks)

---

### 7.2 MVP Subset Recommendation (6-8 Weeks)

**Core MVP Stories (P0 + Essential P1):** ~170 SP

**Included Epics:**
- ✅ EPIC-00: Project Setup (13 SP)
- ✅ EPIC-01: Core Gameplay Loop (34 SP)
- ✅ EPIC-02: Tier 1 Economy (26 SP)
- ✅ EPIC-03: Tier 2 Automation (42 SP)
- ✅ EPIC-04: Offline Production (26 SP)
- ✅ EPIC-09: Firebase Backend (24 SP)
- ⚠️ EPIC-05: Mobile UX (reduced to 15 SP - essential only)

**Deferred to Post-MVP:**
- ⏸️ EPIC-06: Progression System (18 SP) → Add in v1.1
- ⏸️ EPIC-07: Discovery Tutorial (21 SP) → Add in v1.1
- ⏸️ EPIC-08: Ethical F2P (23 SP) → Add in v1.2 (monetization)
- ⏸️ EPIC-10: Analytics (reduce to 5 SP - basic only)
- ⏸️ EPIC-11: Testing (reduce to 10 SP - critical tests only)

**MVP Total:** 170 SP ÷ 25 SP/week = **6.8 weeks** ✅

---

## 8. Recommended Adjustments

### 8.1 Option A: Extended Timeline (Recommended)

**Timeline:** 12-14 weeks (vs original 8 weeks)
**Velocity:** 22-25 SP/week (realistic for solo dev)
**Coverage:** All 68 stories, 289 SP

**Revised Sprint Plan (14 weeks):**
- Sprint 1-2 (Week 1-2): EPIC-00, EPIC-01 (47 SP, 23.5 SP/week)
- Sprint 3-4 (Week 3-5): EPIC-02, EPIC-03 Part 1 (52 SP, 17.3 SP/week)
- Sprint 5-6 (Week 6-8): EPIC-03 Part 2, EPIC-04 (46 SP, 15.3 SP/week)
- Sprint 7-8 (Week 9-10): EPIC-05, EPIC-06 (47 SP, 23.5 SP/week)
- Sprint 9-10 (Week 11-12): EPIC-07, EPIC-08 (44 SP, 22 SP/week)
- Sprint 11-12 (Week 13-14): EPIC-09, EPIC-10, EPIC-11 (57 SP, 28.5 SP/week)

**Pros:**
- ✅ Realistic velocity (22-25 SP/week)
- ✅ All features implemented
- ✅ High quality (time for testing, polish)

**Cons:**
- ❌ Longer time to market (14 weeks vs 8 weeks)
- ❌ Higher opportunity cost

---

### 8.2 Option B: MVP Subset (Aggressive but Achievable)

**Timeline:** 8 weeks
**Velocity:** 25 SP/week (achievable with focus)
**Coverage:** 170 SP (MVP core features only)

**MVP Sprint Plan (8 weeks):**
- Sprint 1 (Week 1): EPIC-00 Setup (13 SP)
- Sprint 2 (Week 2): EPIC-01 Core Loop Part 1 (20 SP)
- Sprint 3 (Week 3): EPIC-01 Core Loop Part 2 (14 SP) + EPIC-02 Economy Part 1 (13 SP) = 27 SP
- Sprint 4 (Week 4): EPIC-02 Economy Part 2 (13 SP) + EPIC-03 Automation Part 1 (20 SP) = 33 SP
- Sprint 5 (Week 5): EPIC-03 Automation Part 2 (22 SP)
- Sprint 6 (Week 6): EPIC-04 Offline Production (26 SP)
- Sprint 7 (Week 7): EPIC-09 Firebase (24 SP)
- Sprint 8 (Week 8): EPIC-05 Mobile UX (essential, 15 SP) + Testing (10 SP) = 25 SP

**Total MVP:** 170 SP

**Post-MVP Backlog (v1.1, v1.2):**
- v1.1 (2-3 weeks): EPIC-06 Progression + EPIC-07 Tutorial (39 SP)
- v1.2 (3-4 weeks): EPIC-08 Monetization + EPIC-10 Analytics + Remaining Testing (60 SP)

**Pros:**
- ✅ 8-week timeline achieved
- ✅ Core gameplay ready for testing
- ✅ Iterative releases (MVP → v1.1 → v1.2)

**Cons:**
- ❌ No tutorial (higher churn risk)
- ❌ No monetization (can't generate revenue)
- ❌ Limited analytics (harder to measure success)

---

### 8.3 Option C: Hire Contractor for High-Risk Stories

**Timeline:** 8-10 weeks
**Velocity:** 35-40 SP/week (solo) + 15-20 SP/week (contractor)
**Coverage:** All 68 stories, 289 SP

**Contractor Focus Areas:**
- **Flame Engine Expertise:** STORY-01.6 (Camera), STORY-03.4 (Resource Transport), STORY-05.3 (60 FPS)
- **Total Contractor Work:** ~40 SP (3-4 weeks part-time)
- **Cost:** $3,000-5,000 (assumes $75-100/hour, 40-50 hours)

**Solo Dev Focus:**
- Domain logic, business rules, Firebase integration, UI screens

**Pros:**
- ✅ 8-week timeline feasible
- ✅ All features implemented
- ✅ De-risks Flame learning curve

**Cons:**
- ❌ Additional cost ($3-5k)
- ❌ Onboarding overhead
- ❌ Less ownership of codebase

---

## 9. Final Sprint Plan (Refined)

### 9.1 Recommended Approach: **Option B (MVP Subset)**

**Rationale:**
- Solo indie developer (cost-sensitive)
- MVP validation needed before full investment
- Iterative releases reduce risk
- 8-week timeline aligns with user's initial expectation

---

### 9.2 MVP Sprint Plan (8 Weeks, 170 SP)

#### **Sprint 1: Foundation (Week 1) - 13 SP**

**Goal:** Setup development environment, basic project structure

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-00.1 | Flutter Project Init | 2 | P0 |
| STORY-00.2 | Firebase Configuration | 3 | P0 |
| STORY-00.3 | CI/CD Pipeline | 3 | P1 |
| STORY-00.4 | Hive Local Storage | 5 | P1 |

**Deliverable:** Working Flutter + Flame project, Firebase connected, Hive storage functional

---

#### **Sprint 2: Core Loop Part 1 (Week 2) - 20 SP**

**Goal:** Domain entities, basic gameplay logic

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-01.1 | Building Entity | 3 | P0 |
| STORY-01.2 | Resource & PlayerEconomy | 3 | P0 |
| STORY-01.3 | Collect Resources Use Case | 5 | P0 |
| STORY-01.4 | Upgrade Building Use Case | 5 | P0 |
| STORY-09.1 | Firebase Auth Flow | 4 | P1 |

**Deliverable:** Core gameplay logic working (collect, upgrade), Firebase auth functional

---

#### **Sprint 3: Core Loop Part 2 + Economy (Week 3) - 27 SP**

**Goal:** Render buildings on grid, start economy system

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-01.5 | Grid System | 5 | P0 |
| STORY-01.6 | Dual Zoom Camera | 8 | P0 |
| STORY-01.7 | Building Sprite Component | 3 | P0 |
| STORY-02.1 | Building Definitions (5 types) | 3 | P1 |
| STORY-02.2 | Resource Definitions (7 types) | 2 | P1 |
| STORY-09.2 | Firestore Cloud Save Schema | 5 | P1 |
| ~~STORY-01.8~~ | ~~Integration Test~~ | ~~5~~ | Deferred |

**Deliverable:** Playable grid with buildings, camera controls, economy definitions

---

#### **Sprint 4: Economy + Automation Part 1 (Week 4) - 28 SP**

**Goal:** NPC Market, building placement, start automation

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-02.3 | NPC Market - Buy/Sell UI | 5 | P1 |
| STORY-02.4 | Market Transaction Use Case | 5 | P1 |
| STORY-02.5 | Building Placement System | 8 | P1 |
| STORY-03.1 | A* Pathfinding Algorithm | 8 | P0 |
| STORY-03.2 | Conveyor Entity & Data Model | 2 | P0 |

**Deliverable:** Market functional, building placement works, A* pathfinding ready

---

#### **Sprint 5: Automation Part 2 (Week 5) - 24 SP**

**Goal:** Complete conveyor automation system

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-03.3 | Conveyor Creation UI - AI Path | 8 | P0 |
| STORY-03.4 | Resource Transport Simulation | 8 | P0 |
| STORY-03.5 | Conveyor Rendering - Batching | 5 | P1 |
| STORY-03.6 | Conveyor Cost & Validation | 3 | P1 |

**Deliverable:** Full automation working (conveyors transport resources automatically)

---

#### **Sprint 6: Offline Production (Week 6) - 26 SP**

**Goal:** Offline production calculation, Welcome Back modal

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-04.1 | Offline Production - Tier 1 | 8 | P1 |
| STORY-04.2 | Offline Production - Tier 2 | 13 | P1 |
| STORY-04.3 | Welcome Back Modal UI | 5 | P1 |

**Deliverable:** Offline production works, players rewarded for returning

---

#### **Sprint 7: Firebase Integration (Week 7) - 22 SP**

**Goal:** Cloud save, security rules, sync

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-09.3 | Offline-First Architecture | 8 | P1 |
| STORY-09.4 | Firestore Security Rules | 5 | P1 |
| STORY-09.6 | Firebase Cost Monitoring | 2 | P1 |
| STORY-10.1 | Firebase Analytics Integration | 3 | P0 |
| STORY-10.2 | D7 Retention Tracking | 2 | P0 |
| STORY-10.3 | Tier 2 Unlock Rate Tracking | 2 | P0 |

**Deliverable:** Cloud save syncs across devices, analytics tracking user behavior

---

#### **Sprint 8: Mobile UX + Testing (Week 8) - 25 SP**

**Goal:** Polish mobile experience, critical tests

| Story ID | Story Name | SP | Priority |
|----------|------------|-----|----------|
| STORY-05.1 | Touch Controls - Gesture System | 5 | P1 |
| STORY-05.2 | Haptic Feedback System | 3 | P2 |
| STORY-05.3 | 60 FPS Optimization | 8 | P0 |
| STORY-11.1 | Unit Test Suite - Domain (reduced) | 3 | P1 |
| STORY-11.4 | Integration Test Suite (reduced) | 3 | P1 |
| STORY-11.5 | Performance Test Suite | 3 | P1 |

**Deliverable:** 60 FPS on target device, touch controls polished, critical tests passing

---

### 9.3 MVP Success Criteria

**MVP Launch Readiness Checklist:**
- [ ] Core gameplay loop works (COLLECT → DECIDE → UPGRADE)
- [ ] 5 building types placeable, upgradable
- [ ] Conveyors automate resource transport
- [ ] Offline production calculates correctly (Tier 1 + Tier 2)
- [ ] NPC Market buy/sell functional
- [ ] Cloud save syncs across devices
- [ ] 60 FPS on Snapdragon 660 (or equivalent)
- [ ] <3s cold start load time
- [ ] 70%+ test coverage (domain + critical paths)
- [ ] Firebase Analytics tracking D7 retention

**Deferred to v1.1 (2-3 weeks post-MVP):**
- Tier 2 unlock progression system
- Discovery-based tutorial
- Accessibility features (contrast, tap targets)
- One-handed UI layout

**Deferred to v1.2 (3-4 weeks post-MVP):**
- Ethical F2P monetization ($10 cap, IAP)
- Rewarded video ads (2× offline boost)
- Comprehensive analytics (custom events)
- E2E test suite (Firebase Test Lab)

---

## 10. Success Criteria & Milestones

### 10.1 Weekly Milestones

| Week | Milestone | Success Criteria |
|------|-----------|------------------|
| **Week 1** | Foundation Ready | Flutter + Firebase + Hive working |
| **Week 2** | Core Logic Done | Collect, upgrade use cases functional |
| **Week 3** | Playable Prototype | Grid rendered, buildings placeable |
| **Week 4** | Economy Works | Market buy/sell, A* pathfinding ready |
| **Week 5** | Automation Live | Conveyors transport resources automatically |
| **Week 6** | Offline Production | Welcome Back modal shows accurate production |
| **Week 7** | Cloud Save Syncs | Progress saves across devices |
| **Week 8** | MVP Complete | 60 FPS, polished, ready for alpha testing |

---

### 10.2 Definition of Done (MVP)

**Code Quality:**
- [ ] Flutter analyze: 0 errors, 0 warnings
- [ ] Test coverage: 70%+ overall
- [ ] Performance: 60 FPS sustained (30 min test)
- [ ] Memory: <150 MB on Snapdragon 660

**Functional:**
- [ ] All P0 stories completed
- [ ] All critical user flows tested (integration tests)
- [ ] No P0/P1 bugs in backlog

**Deployment:**
- [ ] APK builds successfully (Android)
- [ ] IPA builds successfully (iOS - optional for MVP)
- [ ] Firebase project configured for production
- [ ] Analytics events logging correctly

---

## 11. Next Steps

### 11.1 Immediate Actions (Next 1 Hour)

1. **Decision Point:** Choose Option A, B, or C (Recommended: **Option B - MVP Subset**)
2. **Create GitHub Milestones:**
   - Milestone 1: Sprint 1-2 (Foundation + Core Loop)
   - Milestone 2: Sprint 3-4 (Economy + Automation Part 1)
   - Milestone 3: Sprint 5-6 (Automation Part 2 + Offline)
   - Milestone 4: Sprint 7-8 (Firebase + Polish)
3. **Export Stories to GitHub Issues** (68 issues with labels, milestones)
4. **Create Project Board** (Kanban: Backlog, To Do, In Progress, Done)

---

### 11.2 Week 1 Kickoff Checklist

**Before Starting Sprint 1:**
- [ ] Review PRD, Architecture, Test Design documents
- [ ] Install Flutter 3.16+, Android Studio, Xcode (iOS)
- [ ] Create Firebase project: `trade-factory-masters`
- [ ] Setup GitHub repository (if not already done)
- [ ] Initialize Flutter project: `flutter create trade_factory_masters`
- [ ] First commit: "Initial Flutter project setup"

**Day 1 Goals:**
- [ ] STORY-00.1: Flutter project created, runs "Hello World"
- [ ] STORY-00.2: Firebase configured, anonymous auth works

---

## 12. Summary & Recommendation

### 12.1 Key Findings

✅ **Story Point Estimates:** Realistic for feature complexity
✅ **Dependency Chain:** Valid, no circular dependencies
⚠️ **Original Timeline (8 weeks, 289 SP):** Too aggressive for solo developer
✅ **MVP Subset (8 weeks, 170 SP):** Achievable with focused execution
⚠️ **High-Risk Stories:** STORY-01.6 (Camera), STORY-03.1 (A*), STORY-05.3 (60 FPS)

### 12.2 Final Recommendation

**Adopt Option B: MVP Subset (8 Weeks, 170 SP)**

**Rationale:**
1. Achieves 8-week timeline (user's expectation)
2. Delivers playable MVP for user testing
3. De-risks full investment (validate game concept first)
4. Iterative releases (MVP → v1.1 → v1.2) align with lean startup methodology
5. Solo developer velocity is realistic (25 SP/week)

**Post-MVP Roadmap:**
- **Week 9-11 (v1.1):** Add Progression + Tutorial (39 SP)
- **Week 12-15 (v1.2):** Add Monetization + Full Analytics (60 SP)
- **Total Timeline:** 15 weeks for complete product (vs 8 weeks MVP)

---

**Status:** ✅ **APPROVED - Ready for Implementation**

**Next Step:** Create GitHub Issues for 68 stories → Start Sprint 1

---

**End of Sprint Planning Review**
