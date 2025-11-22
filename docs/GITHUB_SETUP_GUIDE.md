# GitHub Setup Guide - Trade Factory Masters

This guide walks you through setting up your GitHub repository with all issues, labels, milestones, and project board.

**Time Estimate:** 30-45 minutes for complete setup

---

## Prerequisites

- GitHub account with access to `CoderMariusz/FantasyFactio`
- Web browser

---

## Part 1: Create Labels (5 minutes)

Navigate to: https://github.com/CoderMariusz/FantasyFactio/labels

Click "New label" and create the following:

### Priority Labels

| Name | Color | Description |
|------|-------|-------------|
| `priority: P0 - critical` | `#d73a4a` (red) | Critical path - must complete |
| `priority: P1 - high` | `#ff9800` (orange) | High priority - should complete |
| `priority: P2 - medium` | `#ffc107` (yellow) | Medium priority - nice to have |

### Size Labels

| Name | Color | Description |
|------|-------|-------------|
| `size: S (1-2 SP)` | `#0e8a16` (green) | Small story: 1-2 story points |
| `size: M (3-5 SP)` | `#1d76db` (blue) | Medium story: 3-5 story points |
| `size: L (8-13 SP)` | `#5319e7` (purple) | Large story: 8-13 story points |

### Epic Labels

| Name | Color | Description |
|------|-------|-------------|
| `epic: Setup` | `#006b75` (teal) | EPIC-00: Project Setup |
| `epic: Core Loop` | `#006b75` | EPIC-01: Core Gameplay Loop |
| `epic: Economy` | `#006b75` | EPIC-02: Tier 1 Economy |
| `epic: Automation` | `#006b75` | EPIC-03: Tier 2 Automation |
| `epic: Offline` | `#006b75` | EPIC-04: Offline Production |
| `epic: Mobile UX` | `#006b75` | EPIC-05: Mobile-First UX |
| `epic: Progression` | `#006b75` | EPIC-06: Progression System |
| `epic: Tutorial` | `#006b75` | EPIC-07: Discovery Tutorial |
| `epic: Monetization` | `#006b75` | EPIC-08: Ethical F2P |
| `epic: Backend` | `#006b75` | EPIC-09: Firebase Backend |
| `epic: Analytics` | `#006b75` | EPIC-10: Analytics & Metrics |
| `epic: Testing` | `#006b75` | EPIC-11: Testing & Quality |

### Type Labels

| Name | Color | Description |
|------|-------|-------------|
| `type: feature` | `#a2eeef` (light blue) | New feature implementation |
| `type: infrastructure` | `#7057ff` (violet) | Infrastructure/DevOps work |
| `type: testing` | `#d4c5f9` (lavender) | Testing and QA |

**Total: 21 labels**

---

## Part 2: Create Milestones (3 minutes)

Navigate to: https://github.com/CoderMariusz/FantasyFactio/milestones

Click "New milestone" and create the following:

### MVP Sprints (8 milestones)

Calculate dates from today:

| Title | Due Date | Description |
|-------|----------|-------------|
| Sprint 1: Foundation (Week 1) | Today + 7 days | Setup: Flutter, Firebase, Hive (13 SP) |
| Sprint 2: Core Loop Part 1 (Week 2) | Today + 14 days | Domain entities, gameplay logic (20 SP) |
| Sprint 3: Core Loop Part 2 + Economy (Week 3) | Today + 21 days | Grid rendering, economy definitions (27 SP) |
| Sprint 4: Economy + Automation Part 1 (Week 4) | Today + 28 days | Market, building placement, A* (28 SP) |
| Sprint 5: Automation Part 2 (Week 5) | Today + 35 days | Conveyor system complete (24 SP) |
| Sprint 6: Offline Production (Week 6) | Today + 42 days | Offline production, Welcome Back (26 SP) |
| Sprint 7: Firebase Integration (Week 7) | Today + 49 days | Cloud save, security rules, analytics (22 SP) |
| Sprint 8: Mobile UX + Testing (Week 8) | Today + 56 days | Touch controls, 60 FPS, tests (25 SP) |

### Post-MVP Milestones (2 milestones)

| Title | Description |
|-------|-------------|
| v1.1: Progression + Tutorial | Post-MVP: Tier 2 unlock, tutorial (39 SP) |
| v1.2: Monetization + Analytics | Post-MVP: IAP, ads, full analytics (60 SP) |

**Total: 10 milestones**

---

## Part 3: Create Issues - MVP Sprint 1 (15 issues total)

Navigate to: https://github.com/CoderMariusz/FantasyFactio/issues/new

### STORY-00.1: Flutter Project Initialization

**Title:** `STORY-00.1: Flutter Project Initialization`

**Body:**
```markdown
**As a** developer
**I want** to initialize Flutter project with Flame game engine
**So that** I have a working foundation for game development

**Acceptance Criteria:**
- [ ] Flutter 3.16+ project created with `flutter create trade_factory_masters`
- [ ] Flame 1.12+ added to pubspec.yaml
- [ ] Riverpod 3.0 (@riverpod code generation) configured
- [ ] Project structure created per Architecture doc (lib/core, lib/domain, lib/data, lib/presentation, lib/game)
- [ ] HelloWorld Flame game renders successfully (60 FPS test)
- [ ] README.md created with setup instructions

**Story Points:** 2 SP
**Priority:** P0
**Dependencies:** None
**Sprint:** Sprint 1 (Week 1)

**Documentation:**
- Architecture: docs/architecture-trade-factory-masters-2025-11-17.md
- Epics & Stories: docs/epics-stories-trade-factory-masters-2025-11-17.md
```

**Labels:** `epic: Setup`, `priority: P0 - critical`, `size: S (1-2 SP)`, `type: infrastructure`
**Milestone:** Sprint 1: Foundation (Week 1)
**Assignee:** Yourself

---

### STORY-00.2: Firebase Project Configuration

**Title:** `STORY-00.2: Firebase Project Configuration`

**Body:**
```markdown
**As a** developer
**I want** to configure Firebase backend services
**So that** I can implement authentication, cloud save, and analytics

**Acceptance Criteria:**
- [ ] Firebase project created: `trade-factory-masters`
- [ ] FlutterFire configured (`flutterfire configure`)
- [ ] Firebase Auth enabled (Anonymous, Google Sign-In, Apple Sign-In)
- [ ] Firestore database created with security rules (test mode initially)
- [ ] Firebase Analytics enabled
- [ ] Firebase Crashlytics integrated
- [ ] Test authentication flow works (anonymous sign-in)

**Story Points:** 3 SP
**Priority:** P0
**Dependencies:** STORY-00.1
**Sprint:** Sprint 1 (Week 1)
```

**Labels:** `epic: Setup`, `priority: P0 - critical`, `size: M (3-5 SP)`, `type: infrastructure`
**Milestone:** Sprint 1: Foundation (Week 1)

---

### STORY-00.3: CI/CD Pipeline Setup

**Title:** `STORY-00.3: CI/CD Pipeline Setup`

**Body:**
```markdown
**As a** developer
**I want** automated testing and deployment pipeline
**So that** I catch bugs early and streamline releases

**Acceptance Criteria:**
- [ ] GitHub Actions workflow created (`.github/workflows/test.yml`)
- [ ] Workflow runs on push to `main` and `develop` branches
- [ ] Automated tests: flutter analyze, unit tests, widget tests
- [ ] Coverage report generated (80%+ target)
- [ ] Build APK/IPA on successful test pass
- [ ] Pre-commit hook installed (runs tests before commit)

**Story Points:** 3 SP
**Priority:** P1
**Dependencies:** STORY-00.1
**Sprint:** Sprint 1 (Week 1)
```

**Labels:** `epic: Setup`, `priority: P1 - high`, `size: M (3-5 SP)`, `type: infrastructure`
**Milestone:** Sprint 1: Foundation (Week 1)

---

### STORY-00.4: Hive Local Storage Setup

**Title:** `STORY-00.4: Hive Local Storage Setup`

**Body:**
```markdown
**As a** developer
**I want** Hive local storage configured
**So that** I can implement offline-first architecture

**Acceptance Criteria:**
- [ ] Hive 2.2+ added to pubspec.yaml
- [ ] Hive initialized in main.dart
- [ ] Type adapters generated for data models (Building, Resource, PlayerEconomy)
- [ ] Test: Save/load PlayerEconomy to/from Hive
- [ ] Clear cache functionality implemented

**Story Points:** 5 SP
**Priority:** P1
**Dependencies:** STORY-00.1
**Sprint:** Sprint 1 (Week 1)

**Performance Target:** 10× faster than SQLite (benchmark test)
```

**Labels:** `epic: Setup`, `priority: P1 - high`, `size: M (3-5 SP)`, `type: infrastructure`
**Milestone:** Sprint 1: Foundation (Week 1)

---

## Part 4: Create GitHub Project Board (5 minutes)

Navigate to: https://github.com/CoderMariusz/FantasyFactio/projects

1. Click "New project"
2. Choose "Board" template
3. Title: "Trade Factory Masters - MVP"
4. Description: "8-week MVP development (170 SP)"

### Create Columns:

1. **Backlog** (default)
2. **To Do** - Ready for work
3. **In Progress** - Currently working on
4. **Done** - Completed stories

### Configure Automation (optional):

- To Do → In Progress: When issue assigned
- In Progress → Done: When issue closed

### Add Issues to Board:

1. Go to "Backlog" column
2. Click "+" → "Add item from repository"
3. Search for issues and add all 68 stories
4. Move Sprint 1 issues (STORY-00.1 through STORY-01.1) to "To Do" column

---

## Part 5: Quick Import Method (CSV)

If you want to import issues faster:

1. Use the CSV file: `docs/github-issues-mvp.csv`
2. Install a GitHub Issues importer extension (e.g., "GitHub CSV Tools")
3. Or use GitHub API with a script

**Note:** CSV import requires additional tooling. Manual creation (Part 3) is recommended for first-time setup.

---

## Part 6: Verification Checklist

After setup, verify:

- [ ] 21 labels created
- [ ] 10 milestones created (8 sprints + 2 post-MVP)
- [ ] 68 issues created (start with Sprint 1-3, can add rest later)
- [ ] Project board created with 4 columns
- [ ] Sprint 1 issues (13 SP) moved to "To Do"
- [ ] STORY-00.1 assigned to you
- [ ] STORY-00.1 moved to "In Progress" when you start

---

## Part 7: Daily Workflow

### Starting a New Story:

1. Move issue from "To Do" → "In Progress"
2. Assign issue to yourself
3. Create branch: `git checkout -b story-00-1-flutter-init`
4. Implement acceptance criteria
5. Check off completed criteria in issue
6. Commit code with reference: `git commit -m "Implement STORY-00.1: Flutter project init (#1)"`
7. Push and create PR
8. Link PR to issue
9. After PR merged: Close issue (auto-moves to "Done")

### Sprint Planning (Weekly):

1. Review completed stories in "Done"
2. Calculate velocity (SP completed this week)
3. Move next sprint's stories from "Backlog" → "To Do"
4. Adjust plan based on actual velocity

---

## Summary

**What You Created:**
- ✅ 21 labels (Priority, Size, Epic, Type)
- ✅ 10 milestones (8 MVP sprints + 2 post-MVP)
- ✅ 68 user stories (can start with Sprint 1-3, add rest later)
- ✅ Project board (Backlog, To Do, In Progress, Done)

**Next Step:** Move STORY-00.1 to "In Progress" and start coding! 🚀

---

## Appendix: Remaining Issues to Create

After creating Sprint 1 issues, here are the remaining stories:

**Sprint 2 (20 SP):** STORY-01.2, 01.3, 01.4, 09.1
**Sprint 3 (27 SP):** STORY-01.5, 01.6, 01.7, 02.1, 02.2, 09.2
**Sprint 4 (28 SP):** STORY-02.3, 02.4, 02.5, 03.1, 03.2
**Sprint 5 (24 SP):** STORY-03.3, 03.4, 03.5, 03.6
**Sprint 6 (26 SP):** STORY-04.1, 04.2, 04.3
**Sprint 7 (22 SP):** STORY-09.3, 09.4, 09.6, 10.1, 10.2, 10.3
**Sprint 8 (25 SP):** STORY-05.1, 05.2, 05.3, 11.1, 11.4, 11.5

**Total MVP:** 17 issues across 8 sprints (170 SP)

For full issue templates, see: `docs/epics-stories-trade-factory-masters-2025-11-17.md`
