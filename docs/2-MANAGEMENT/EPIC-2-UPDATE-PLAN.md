# Epic 2 Documentation Update Plan

**Date:** 2025-12-03
**Status:** Planning phase - 3 new major systems added to tech-spec
**Task:** Restructure stories to incorporate Offline Production, Grid Expansion, and Storage Filtering

---

## Summary: What Changed

### Before (26 SP)
```
STORY-02.1: Resource Definitions (2 SP)
STORY-02.2: Building Definitions (3 SP)
STORY-02.3: NPC Trading System (5 SP)
STORY-02.4: Grid & Building Placement (8 SP)
  └─ Grid system basics only
STORY-02.5: Production & Inventory (5 SP)
  └─ No offline production
STORY-02.6: Economic Balance (3 SP)
─────────────────────────────────
TOTAL: 26 SP
```

### After (38-42 SP estimated)
```
STORY-02.1: Resource Definitions (2 SP)
STORY-02.2: Building Definitions (3 SP)
STORY-02.3: NPC Trading System (5 SP)
STORY-02.4: Grid & Building Placement (10 SP) ← Expanded with grid expansion
STORY-02.5: Production & Inventory (8 SP) ← Expanded with offline production
STORY-02.6: Storage Item Filtering (6 SP) ← NEW story
STORY-02.7: Economic Balance & Testing (3 SP) ← Adjusted from STORY-02.6
─────────────────────────────────
TOTAL: 37-38 SP (14% increase)
```

---

## Impact Analysis

### STORY-02.4: Grid & Building Placement

**Current (8 SP):**
- Grid initialization (20×20)
- Tile properties and biom distribution
- Building placement validation
- Basic layering (conveyors)

**NEEDS ADDITION:**
✅ Grid expansion mechanics (20×20 → 30×30 → 40×40)
✅ Expansion triggers (building capacity OR resource scarcity)
✅ Expansion costs and beton crafting integration
✅ Expansion animations and visual feedback
✅ Grid expansion state persistence
✅ Resource depletion tracking per biom

**Estimated Impact:** +2 SP → **NEW: 10 SP**

**Acceptance Criteria to Add:**
- [ ] AC8: Grid expansion to 30×30 triggers correctly
- [ ] AC9: Grid expansion to 40×40 triggers correctly
- [ ] AC10: Expansion animations smooth and satisfying
- [ ] AC11: All buildings preserved after expansion
- [ ] AC12: New bioms distributed in expanded areas
- [ ] AC13: Resource scarcity tracked per biom
- [ ] AC14: 3+ expansions planned for future phases

---

### STORY-02.5: Production & Inventory

**Current (5 SP):**
- Production cycle system
- Mining facility mechanics
- Smelter/Workshop production
- Conveyor transport
- Farm monetization
- Skill progression

**NEEDS ADDITION:**
✅ Offline production calculation
✅ 80% efficiency for farm when offline
✅ Game state persistence for offline
✅ Return notification system
✅ Gold animation and welcome-back UI
✅ Offline earnings breakdown
✅ Future premium features (out of scope but noted)

**Estimated Impact:** +2-3 SP → **NEW: 7-8 SP**

**Acceptance Criteria to Add:**
- [ ] AC10: Game state saved when player offline
- [ ] AC11: Offline production calculated correctly (80% efficiency)
- [ ] AC12: Return notification shows earnings breakdown
- [ ] AC13: Gold animation plays (2s, satisfying)
- [ ] AC14: Farm queue preserved across offline sessions
- [ ] AC15: Storage items never decay while offline
- [ ] AC16: Conveyor items frozen, safe from loss

---

### NEW STORY-02.6: Storage Item Filtering (6 SP)

**This is a NEW story - not in original 6 stories**

**Scope:**
- Global accept/reject filters
- Per-port white-list/black-list modes
- Port configuration UI
- Item routing logic
- Visual feedback (green/red items)
- Error handling and recovery
- Advanced filtering examples

**Why new story?**
- Storage filtering is complex enough for its own story
- Involves UI, logic, and integration testing
- Not technically "building placement" (02.4)
- Not technically "basic production" (02.5)
- Requires detailed acceptance criteria and testing

**Estimated:** **6 SP**

**Acceptance Criteria:**
- [ ] AC1: Global filters accept/reject items correctly
- [ ] AC2: Port modes work (accept-all, white-list, black-list, single-type)
- [ ] AC3: Item routing through ports works
- [ ] AC4: Port configuration UI functional
- [ ] AC5: Visual feedback (green/red/yellow items)
- [ ] AC6: Error handling when port blocks items
- [ ] AC7: Multi-storage networks work correctly
- [ ] AC8: Filtering difficulty progression (early/mid/late game)

---

## Story Restructuring Plan

### OPTION A: Keep 7 Stories (Recommended)

**Pros:**
- Cleaner breakdown
- Each story has focused scope
- Easier to track progress
- Better for sprint planning

**Cons:**
- Epic 2 grows from 26 SP → 37 SP (14% larger)
- Might exceed sprint capacity

**New Structure:**
```
STORY-02.1: Resource Definitions (2 SP)
STORY-02.2: Building Definitions (3 SP)
STORY-02.3: NPC Trading System (5 SP)
STORY-02.4: Grid System & Expansion (10 SP) ← Expanded
STORY-02.5: Production & Offline System (8 SP) ← Expanded
STORY-02.6: Storage Item Filtering (6 SP) ← NEW
STORY-02.7: Economic Balance & Testing (3 SP) ← Renamed
──────────────────────────────────────
TOTAL: 37 SP (Sprints 2-3, ~2.5 weeks)
```

### OPTION B: Consolidate (Alternative)

**Combine storage filtering into 02.5:**
- STORY-02.5: Production, Inventory, Storage Filtering (11 SP)
- STORY-02.6: Economic Balance & Testing (3 SP)
- **TOTAL: 34 SP**

**Pros:** Reduces story count, keeps items related
**Cons:** STORY-02.5 becomes very large, harder to track

### OPTION C: Extract Grid Expansion

**Separate grid basics from expansion:**
- STORY-02.4a: Basic Grid & Placement (8 SP)
- STORY-02.4b: Grid Expansion System (5 SP)
- STORY-02.5: Production & Offline (8 SP)
- STORY-02.6: Storage Filtering (6 SP)
- STORY-02.7: Economic Balance (3 SP)
- **TOTAL: 38 SP**

**Pros:** Each story smaller, easier to review
**Cons:** More stories to track (7 total)

---

## Recommended Approach: OPTION A

**Rationale:**
1. Storage filtering is significant enough for own story
2. Grid expansion is part of placement system (not separate)
3. Offline production is part of production system (not separate)
4. 7 stories is manageable
5. 37 SP is stretching but feasible for 2-3 weeks

**Timeline (Option A):**
```
Sprint 2 (Week 1):
├─ STORY-02.1: Resources (2 SP) ✓ Quick
├─ STORY-02.2: Buildings (3 SP) ✓ Quick
└─ STORY-02.3: NPCs (5 SP) ✓ Moderate
= 10 SP

Sprint 2 (Week 2):
├─ STORY-02.4: Grid & Expansion (10 SP) ⚠️ Complex
└─ Start STORY-02.5: Production (8 SP)
= 10-12 SP (split across weeks)

Sprint 3 (Week 3):
├─ Finish STORY-02.5: Production (8 SP) ✓
├─ STORY-02.6: Storage Filtering (6 SP) ✓ Moderate
└─ STORY-02.7: Balance & Testing (3 SP) ✓
= 17 SP

TOTAL: 37 SP over 3 weeks (~12-13 SP/week)
```

---

## Tasks to Complete

### Phase 1: Story Updates (This week)
- [ ] Update STORY-02.4 with grid expansion details (add ~3 SP of AC)
- [ ] Update STORY-02.5 with offline production details (add ~3 SP of AC)
- [ ] Create new STORY-02.6 for Storage Filtering (new 6 SP story)
- [ ] Renumber existing STORY-02.6 → STORY-02.7
- [ ] Add new acceptance criteria for all three systems
- [ ] Add implementation notes for new features

### Phase 2: Dependencies & Sequencing
- [ ] Map dependencies between new stories
- [ ] Ensure STORY-02.4 (grid) doesn't block STORY-02.5 (production)
- [ ] Note that STORY-02.6 (filtering) can run parallel with 02.5
- [ ] Verify STORY-02.7 (balance testing) depends on all others

### Phase 3: Update Project Status
- [ ] Update project-status.md: Epic 2 now 37 SP (was 26 SP)
- [ ] Update timeline estimates
- [ ] Adjust sprint capacity if needed
- [ ] Add "Grid Expansion" to priority features
- [ ] Add "Storage Filtering" to priority features

### Phase 4: Implementation Readiness
- [ ] Ensure all ACs are testable
- [ ] Add code examples for new features
- [ ] Create implementation patterns for filtering logic
- [ ] Add offline calculation formulas
- [ ] Prepare unit test templates

---

## Critical Decisions Needed

### 1. When to Implement Storage Filtering?

**Option A: As part of Epic 2 (current plan)**
- Included in STORY-02.6
- Ready for MVP
- Adds storage depth to game
- +6 SP to Epic 2

**Option B: Defer to Epic 3 (Automation)**
- Move to Phase 2
- Reduce Epic 2 to 31 SP
- MVP has basic storage (no filtering)
- Filtering is "advanced feature"

**Recommendation:** Option A (MVP now)
- Storage filtering is core to automation strategy
- Without it, advanced players limited to simple routing
- Relatively low complexity (entity/logic, no UI framework needed)

### 2. Offline Production - Always 80%?

**Option A: Fixed 80% (current plan)**
- Consistent, predictable
- Fair balance
- Psychological: "Always 80%"

**Option B: Skill-based (alternative)**
- Trading skill 5: 85% efficiency
- Trading skill 10: 90% efficiency
- More progression feel
- More complex

**Recommendation:** Option A (fixed)
- Simpler to implement
- Clear value proposition
- Premium features can be "150% efficiency"

### 3. Grid Expansion - Resource Scarcity?

**Option A: Dual triggers (current plan)**
- Building capacity OR resource depletion
- Either trigger works
- More motivation paths

**Option B: Capacity only**
- Just place 6 buildings → expansion
- Simpler
- Resources never "run out"

**Recommendation:** Option A (dual triggers)
- More engaging progression
- Teaches resource scarcity concept
- Foreshadows future complexity

---

## Summary for Implementation

### Files to Update

| File | Action | Details |
|------|--------|---------|
| `epic-02-stories.md` | Modify STORY-02.4 | +10 AC for grid expansion |
| `epic-02-stories.md` | Modify STORY-02.5 | +7 AC for offline production |
| `epic-02-stories.md` | Add STORY-02.6 | New 6 SP story: Storage filtering |
| `epic-02-stories.md` | Renumber STORY-02.6 | → STORY-02.7 (Economic Balance) |
| `project-status.md` | Update metrics | Epic 2: 26 SP → 37 SP |
| `project-status.md` | Update timeline | Adjust sprint estimates |
| `.claude/PATTERNS.md` | Add patterns | Offline calculation, filter logic |

### New AC Count

```
Before:
├─ STORY-02.4: 7 AC
├─ STORY-02.5: 9 AC
└─ STORY-02.6: 8 AC

After:
├─ STORY-02.4: 14 AC (+7 for grid expansion)
├─ STORY-02.5: 16 AC (+7 for offline)
├─ STORY-02.6: 8 AC (NEW story)
└─ STORY-02.7: 8 AC (renamed)

Total new AC: 22 (across 4 modified/new stories)
```

---

## Next Steps (Prioritized)

### IMMEDIATE (Today/Tomorrow)
1. ✅ Tech-spec updated with all three systems (DONE)
2. ⏳ **UPDATE STORY-02.4** with grid expansion ACs
3. ⏳ **UPDATE STORY-02.5** with offline production ACs
4. ⏳ **CREATE STORY-02.6** for storage filtering (new story)
5. ⏳ **RENUMBER** old STORY-02.6 → STORY-02.7

### THIS WEEK
6. ⏳ **UPDATE project-status.md** (37 SP, new timeline)
7. ⏳ **Add implementation patterns** to .claude/PATTERNS.md
8. ⏳ **Review all stories** for conflicts/dependencies
9. ⏳ **Create updated epic-02-stories.md** (complete, 7 stories)
10. ⏳ **Commit and push** final stories document

### READY FOR DEVELOPMENT
11. Developers start STORY-02.1 (Resources)
12. Developers start STORY-02.2 (Buildings)
13. Developers start STORY-02.3 (NPCs)

---

## Questions to Answer

1. **Offline production only for Farm?**
   - Or should Mining/Smelters also work offline in Phase 2?
   - Current: Only Farm (80%), others paused

2. **Grid expansion as single action?**
   - Or preview expansion before confirming?
   - Current: Single tap, immediate craft

3. **Storage filtering complexity**
   - Include port-specific filters in MVP?
   - Or just global accept/reject?
   - Current: Full filtering system

4. **When to split 02.4 vs 02.5?**
   - Are they dependent?
   - Can they run in parallel?
   - Current: 02.4 (grid) doesn't block 02.5 (production)

---

## Status

| Component | Status | Updated |
|-----------|--------|---------|
| Tech-spec: Offline Production | ✅ Complete | 5200 words |
| Tech-spec: Grid Expansion | ✅ Complete | 3100 words |
| Tech-spec: Storage Filtering | ✅ Complete | 3800 words |
| Tech-spec: Total | ✅ 890+ lines | +12,100 words |
| Stories: Restructure plan | ✅ Complete | This doc |
| Stories: Implementation | ⏳ Pending | Next step |
| Stories: SP recount | ⏳ Pending | After updates |
| Project status: Update | ⏳ Pending | After stories |

---

**Document Status:** 📋 Action Plan Ready
**Next Action:** Update STORY-02.4, STORY-02.5, Create STORY-02.6
**Timeline:** Complete updates by 2025-12-04
**Last Updated:** 2025-12-03
