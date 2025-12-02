# Trade Factory Masters - START HERE

Welcome! This is your guide to the FantasyFactio project.

---

## 🚀 Quick Start (5 minutes)

### For Developers

1. **Read this:** You're reading it! ✓
2. **Read next:** `/CLAUDE.md` (in project root) - AI-friendly overview
3. **Get latest status:** `/docs/2-MANAGEMENT/project-status.md`
4. **Setup environment:** See "Development Setup" below

### For Project Managers / Stakeholders

1. **Quick Facts:** `/CLAUDE.md` (Quick Facts table)
2. **Current Status:** `/docs/2-MANAGEMENT/project-status.md`
3. **What's Done/TODO:** `/docs/2-MANAGEMENT/MVP-TODO.md`
4. **Epic Details:** `/docs/2-MANAGEMENT/epics/epic-*.md`

---

## 📚 Documentation Structure

```
Root
├── CLAUDE.md                          ← AI Assistant Guide
├── README.md                          ← Project overview
│
├── .claude/                           ← AI-optimized docs
│   ├── FILE-MAP.md                    ← Code file index
│   ├── TABLES.md                      ← Database schema
│   ├── PATTERNS.md                    ← Code patterns
│   └── PROMPTS.md                     ← Task templates
│
└── docs/                              ← Human-readable docs
    ├── 00-START-HERE.md               ← This file
    ├── BMAD-STRUCTURE.md              ← How docs organized
    │
    ├── 1-BASELINE/                    ← Requirements & Design
    │   ├── product/
    │   │   ├── prd-v1.0.md
    │   │   ├── product-brief.md
    │   │   └── market-research.md
    │   └── architecture/
    │       └── system-architecture.md
    │
    ├── 2-MANAGEMENT/                  ← Status & Tracking
    │   ├── project-status.md
    │   ├── MVP-TODO.md
    │   ├── EPIC-1-ISSUES.md            ← Bug tracker
    │   └── epics/
    │       ├── epic-00-project-setup.md
    │       ├── epic-01-core-gameplay.md
    │       └── ...epic-02-12...
    │
    ├── 4-DEVELOPMENT/                 ← Developer guides
    │   ├── SETUP.md                    ← Environment setup
    │   ├── DEVELOPMENT.md              ← Dev guidelines
    │   └── TROUBLESHOOTING.md
    │
    └── 5-ARCHIVE/                     ← Old docs
        └── [deprecated files]
```

---

## 🎯 Current Status at a Glance

| Aspect | Status | Details |
|--------|--------|---------|
| **Overall** | 🔴 Epic 1 Buggy | 47/289 SP (16%), but critical bugs found |
| **Epic 1** | ❌ NOT READY | Code complete, but 3 critical bugs block testing |
| **Epic 2-12** | ⏳ PLANNED | 8 epics ready for implementation |
| **Documentation** | ✅ Reorganized | New BMAD V6 structure in place |

**Bottom Line:** Planning complete, Epic 1 needs bug fixes before Epic 2 can start.

---

## 🔧 Development Setup

### Prerequisites

- Flutter 3.16+
- Dart 3.2+
- Android SDK / Xcode (for iOS)
- Git

### Installation

```bash
# Clone repository
git clone <repo-url>
cd FantasyFactio

# Switch to development branch
git checkout claude/project-status-display-01WgeBaEE9s5pXkKZraeZEwN

# Install dependencies
cd trade_factory_masters
flutter pub get
flutter pub run build_runner build

# Run the app (hot reload enabled)
flutter run
```

### First Time Development Check

```bash
# Verify setup
flutter doctor

# Run tests
flutter test

# Check code quality
flutter analyze
```

See `/docs/4-DEVELOPMENT/SETUP.md` for detailed setup guide.

---

## 🐛 Known Issues

**CRITICAL - Epic 1 Bugs:**
1. Integration tests won't compile (parameter name mismatch)
2. Resource inventory logic broken (resources won't be added)
3. Type cast syntax error in main.dart

👉 **See:** `/docs/2-MANAGEMENT/EPIC-1-ISSUES.md` for full details and fixes

---

## 📖 Documentation by Role

### 👨‍💻 Developer Working on Code

1. Read: `CLAUDE.md` (full guide for AI)
2. Reference: `.claude/FILE-MAP.md` (find files quickly)
3. Code: Use `.claude/PATTERNS.md` (follow patterns)
4. Test: `flutter test` and verify results
5. Commit: Use `.claude/PROMPTS.md` for message format

**Quick Links:**
- Code Structure: `.claude/FILE-MAP.md`
- How to Code: `.claude/PATTERNS.md`
- Where to Find Things: `.claude/FILE-MAP.md`

### 🎬 Product Manager / Scrum Master

1. Read: `/docs/2-MANAGEMENT/project-status.md` (current status)
2. Review: `/docs/2-MANAGEMENT/MVP-TODO.md` (what's left)
3. Epic Details: `/docs/2-MANAGEMENT/epics/epic-N.md` (specific epics)
4. Issues: `/docs/2-MANAGEMENT/EPIC-1-ISSUES.md` (blockers)

**Key Metrics:**
- Total Scope: 289 Story Points (MVP)
- Completed: 47 SP (Epic 1, with bugs)
- Remaining: 242 SP
- Velocity: 25 SP/week (solo dev)
- Timeline: ~8 weeks to MVP

### 🏗️ Architect / Tech Lead

1. Read: `CLAUDE.md` (Quick Facts)
2. Design: `/docs/1-BASELINE/architecture/system-architecture.md`
3. Data: `.claude/TABLES.md` (schema)
4. Code: `.claude/PATTERNS.md` (standards)
5. Issues: `/docs/2-MANAGEMENT/EPIC-1-ISSUES.md` (technical debt)

**Architecture Decisions:**
- Framework: Flutter 3.16+
- Game Engine: Flame 1.33.0
- State Management: Riverpod 3.0
- Backend: Firebase
- Storage: Hive (local), Firestore (cloud)
- Pattern: Clean Architecture + DDD

---

## 🚦 Next Steps (After Bug Fixes)

### Immediate (This Week)

1. **Fix Critical Epic 1 Bugs** (1-2 hours)
   - See `/docs/2-MANAGEMENT/EPIC-1-ISSUES.md` for fixes
   - Run all tests to verify

2. **Plan Epic 2 Implementation** (2-3 hours)
   - Read: `/docs/2-MANAGEMENT/epics/epic-02-tier-1-economy.md`
   - Technical context already exists

### Soon (Next 1-2 Weeks)

1. **Implement Epic 2 Stories** (26 SP, ~2 weeks)
   - Start with Building Definitions (STORY-02.1)
   - Follow Sprint 2 planning

2. **Parallel: Epic Context Documentation** (Ongoing)
   - Complete tech contexts for Epic 3-6
   - Prepare Sprint 3 planning

---

## 📞 Getting Help

### Common Questions

**Q: How do I run the app?**
A: `flutter run` in the `trade_factory_masters/` directory

**Q: How do I run tests?**
A: `flutter test` (unit) or `flutter test integration_test/` (integration)

**Q: Where are the bugs documented?**
A: `/docs/2-MANAGEMENT/EPIC-1-ISSUES.md`

**Q: What should I work on next?**
A: Check `/docs/2-MANAGEMENT/project-status.md` for priorities

**Q: How do I follow code patterns?**
A: See `.claude/PATTERNS.md` for examples

### Troubleshooting

- **Builds failing?** → `/docs/4-DEVELOPMENT/TROUBLESHOOTING.md`
- **Tests not running?** → Check Flutter/Dart versions, run `flutter doctor`
- **Firebase issues?** → Check `lib/main.dart` initialization

---

## 📊 Project Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| **Total Stories** | 68 | Across 12 epics |
| **Total Story Points** | 289 SP | MVP scope |
| **Completed** | 47 SP (16%) | Epic 1 (with bugs) |
| **Estimated Velocity** | 25 SP/week | Solo developer |
| **MVP Timeline** | 8 weeks | Should complete by ~mid-2026 |
| **Test Coverage** | ~70-80 tests | Unit tests mostly complete |

---

## 🎓 Learning Resources

### Project-Specific
- Architecture: `/docs/1-BASELINE/architecture/system-architecture.md`
- Business Logic: `/docs/1-BASELINE/product/prd-v1.0.md`
- Game Design: `/docs/1-BASELINE/product/product-brief.md`

### External
- Flutter: https://flutter.dev/docs
- Flame: https://flame-engine.org/
- Firebase: https://firebase.google.com/docs
- Riverpod: https://riverpod.dev/

---

## 📝 How to Update Documentation

1. Identify the right file (see structure above)
2. Use patterns from existing docs
3. Add AI-INDEX comment at top of .md files
4. Update "Last Updated" date
5. Reference related docs where relevant

See `BMAD-STRUCTURE.md` for detailed guidelines.

---

## 🔗 Key Links

| What | Where | Purpose |
|------|-------|---------|
| **AI Guide** | `/CLAUDE.md` | Everything an AI needs to know |
| **File Index** | `.claude/FILE-MAP.md` | Find any code file |
| **Code Patterns** | `.claude/PATTERNS.md` | How to write code |
| **Current Status** | `docs/2-MANAGEMENT/project-status.md` | What's done/in progress |
| **Bugs** | `docs/2-MANAGEMENT/EPIC-1-ISSUES.md` | Known issues & fixes |
| **Epic Details** | `docs/2-MANAGEMENT/epics/` | Specific work items |

---

## 👤 Project Ownership

- **Lead Developer:** Mariusz (CoderMariusz)
- **AI Assistant:** Claude (BMAD Documentation Agent)
- **Git Branch:** `claude/project-status-display-01WgeBaEE9s5pXkKZraeZEwN`

---

## 📅 Timeline

| Date | Milestone |
|------|-----------|
| 2025-11-23 | ✅ Epic 1 Completion (with bugs) |
| 2025-12-02 | 🔄 Documentation Reorganization |
| TBD | ⏳ Epic 1 Bug Fixes |
| TBD | ⏳ Epic 2 Implementation (Tier 1 Economy) |
| TBD | ⏳ MVP Release |

---

## Questions?

- Check the relevant section above
- Search for your question in the FAQ
- Review the epic files for specific features
- Check TROUBLESHOOTING.md for common issues

**Last Updated:** 2025-12-02
**Next Review:** After Epic 1 bug fixes
