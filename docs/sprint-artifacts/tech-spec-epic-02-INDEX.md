# Epic 2: Tier 1 Economy - Complete Technical Specification

**Project:** Trade Factory Masters
**Epic:** EPIC-02 - Tier 1 Economy
**Total SP:** 40 (7-8 stories)
**Status:** ✅ COMPLETE TECHNICAL SPECIFICATION
**Date:** 2025-12-03

---

## 📚 Documentation Structure

This technical specification is split into **4 focused documents** for easy navigation:

### Part 1: Core Mechanics
📄 **[tech-spec-epic-02-CORE.md](tech-spec-epic-02-CORE.md)**
- Overview & Objectives
- Resources (7 types, all properties)
- Buildings (6 buildings, full specs)
- Grid System (20×20 start)
- Skill Progression
- Demolition System

**Size:** ~600 lines
**Read time:** 15-20 minutes
**Audience:** Game developers, designers

### Part 2: Advanced Systems
📄 **[tech-spec-epic-02-SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md)**
- Conveyor System (transport, filtering)
- NPC Trading System (3 NPCs)
- Offline Production (80% efficiency)
- Grid Expansion (20→30→40)
- Storage Filtering (port configuration)

**Size:** ~900 lines
**Read time:** 25-30 minutes
**Audience:** Senior developers, architects

### Part 3: User Interface
📄 **[tech-spec-epic-02-UI.md](tech-spec-epic-02-UI.md)**
- Hub Screen (dashboard)
- Grid World Screen (map & placement)
- Biom Gathering Screen (resource collection)
- Storage Management Screen (inventory)
- Crafting Queue Screen (production)
- NPC Trading Screens (commerce)

**Size:** ~1,500-2,000 lines
**Read time:** 40-50 minutes
**Audience:** UI/UX developers, designers

### Part 4: Index & Navigation (THIS FILE)
- Document structure
- Quick reference tables
- Cross-references
- Dependencies
- Implementation checklist

**Size:** ~200 lines
**Read time:** 5-10 minutes
**Audience:** Everyone (start here)

---

## 🗺️ Quick Reference Map

### By Role

**I'm a Game Designer:**
→ Start with [CORE.md](tech-spec-epic-02-CORE.md) (resources, buildings)
→ Then [SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md) (economy, balance)
→ Then [UI.md](tech-spec-epic-02-UI.md) (player experience)

**I'm a Backend Developer:**
→ Start with [CORE.md](tech-spec-epic-02-CORE.md) (data model)
→ Then [SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md) (complex logic)
→ Reference [UI.md](tech-spec-epic-02-UI.md) for state updates

**I'm a UI/UX Developer:**
→ Start with [UI.md](tech-spec-epic-02-UI.md) (screens & interactions)
→ Reference [CORE.md](tech-spec-epic-02-CORE.md) for data types
→ Reference [SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md) for state changes

**I'm a QA/Tester:**
→ Start with [SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md) (features)
→ Reference [CORE.md](tech-spec-epic-02-CORE.md) (edge cases)
→ Reference [UI.md](tech-spec-epic-02-UI.md) (test scenarios)

### By Topic

| Topic | File | Section |
|-------|------|---------|
| Resource types & properties | CORE.md | Resources |
| Building definitions | CORE.md | Buildings |
| Grid mechanics | CORE.md | Grid System |
| Skills system | CORE.md | Skill Progression |
| Item transport | SYSTEMS.md | Conveyor System |
| NPC trading | SYSTEMS.md | NPC Trading System |
| Offline mechanics | SYSTEMS.md | Offline Production |
| Grid expansion | SYSTEMS.md | Grid Expansion |
| Storage configuration | SYSTEMS.md | Storage Filtering |
| Home dashboard | UI.md | Hub Screen |
| World map | UI.md | Grid World Screen |
| Resource gathering | UI.md | Biom Gathering Screen |
| Inventory management | UI.md | Storage Management Screen |
| Production queue | UI.md | Crafting Queue Screen |
| NPC interactions | UI.md | NPC Trading Screens |

---

## 🔗 System Dependencies

```
CORE LAYER (Foundation)
├── Resources ▶ Used by everything
├── Buildings ▶ Used by production
├── Grid System ▶ Placement system
└── Skills ▶ Modify all mechanics

SYSTEM LAYER (Complex Logic)
├── Conveyor → Uses Buildings + Resources
├── NPC Trading → Uses Resources + Skills
├── Offline Production → Uses Buildings + Skills
├── Grid Expansion → Uses Grid + Buildings
└── Storage Filtering → Uses Resources + Buildings

UI LAYER (Player Interaction)
├── Hub Screen → Shows all systems' status
├── Grid World → Interacts with Buildings + Grid
├── Biom Gathering → Uses Resources + Mining
├── Storage Management → Uses Resources + Storage
├── Crafting Queue → Uses Buildings + Resources
└── NPC Trading → Uses NPC System + Resources
```

**Dependencies by Part:**
- Part 1 (Core): **Independent** ✓
- Part 2 (Systems): **Requires Part 1**
- Part 3 (UI): **Requires Parts 1 & 2**

---

## 📋 Key Specs at a Glance

### Resources (7 Total)

| Resource | Speed | Biom | Value |
|----------|-------|------|-------|
| Węgiel (Coal) | 1.25s | Koppalnia | 1g |
| Ruda Żelaza (Iron Ore) | 1.25s | Koppalnia | 1g |
| Drewno (Wood) | 1.88s | Las | 1.5g |
| Kamień (Stone) | 2.5s | Góry | 1g |
| Miedź (Copper) | 5.0s | Góry | 5g |
| Wata (Salt) | 1.88s | Jezioro | 2g |
| Sól (Brine) | 3.75s | Jezioro | 3g |
| Glina (Clay) | 3.13s | Jezioro | 1.5g |

**See:** [CORE.md - Resources](tech-spec-epic-02-CORE.md#resources)

### Buildings (6 Total)

| Building | Size | Cost | Function |
|----------|------|------|----------|
| Mining | 2×2 | FREE | +50% gather |
| Storage | 2×2 | 5D+10K | 200 items |
| Smelter | 2×3 | 15D+10K+5M | Auto-craft |
| Conveyor | 1×1 | 2D+1Z | Transport |
| Workshop | 2×2 | 20D+15K+5Z | Auto-craft |
| Farm | 3×3 | 25B+12Z+15D | Items→gold |

**See:** [CORE.md - Buildings](tech-spec-epic-02-CORE.md#buildings)

### Grid Progression

| Level | Size | Time | Trigger | Cost |
|-------|------|------|---------|------|
| Start | 20×20 | 0 min | Game start | - |
| Expand 1 | 30×30 | 35-40 min | 6 buildings OR full | 50 beton |
| Expand 2 | 40×40 | 70-80 min | 4 Smelters + 2 Workshops + Farm | 100 beton |

**See:** [SYSTEMS.md - Grid Expansion](tech-spec-epic-02-SYSTEMS.md#grid-expansion-system)

### Economy Timeline (120 Minutes)

| Phase | Time | Gold | Action |
|-------|------|------|--------|
| Early | 0-15 min | 30-50g | Manual gathering |
| Growth | 15-50 min | 150-300g | First automation |
| Boom | 50-120 min | 500-1000g | Full factory |

**See:** [SYSTEMS.md - Offline Production](tech-spec-epic-02-SYSTEMS.md#offline-production-system)

---

## ✅ Implementation Checklist

### STORY-02.1: Resources (2 SP)
- [ ] Read [CORE.md - Resources](tech-spec-epic-02-CORE.md#resources)
- [ ] Implement Resource entity
- [ ] Create 7 resource definitions
- [ ] Add unit tests

### STORY-02.2: Buildings (3 SP)
- [ ] Read [CORE.md - Buildings](tech-spec-epic-02-CORE.md#buildings)
- [ ] Implement Building entity
- [ ] Create 6 building definitions
- [ ] Test placement rules

### STORY-02.3: NPCs (5 SP)
- [ ] Read [SYSTEMS.md - NPC Trading](tech-spec-epic-02-SYSTEMS.md#npc-trading-system)
- [ ] Implement 3 NPC traders
- [ ] Create trading mechanics
- [ ] Test price fluctuation

### STORY-02.4: Grid & Expansion (10 SP)
- [ ] Read [CORE.md - Grid System](tech-spec-epic-02-CORE.md#grid-system)
- [ ] Read [SYSTEMS.md - Grid Expansion](tech-spec-epic-02-SYSTEMS.md#grid-expansion-system)
- [ ] Implement grid rendering
- [ ] Implement expansion logic
- [ ] Test animations

### STORY-02.5: Production & Offline (8 SP)
- [ ] Read [CORE.md - Skill Progression](tech-spec-epic-02-CORE.md#skill-progression)
- [ ] Read [SYSTEMS.md - Offline Production](tech-spec-epic-02-SYSTEMS.md#offline-production-system)
- [ ] Implement production cycles
- [ ] Implement offline calculation
- [ ] Test welcome notifications

### STORY-02.6: Storage Filtering (6 SP)
- [ ] Read [SYSTEMS.md - Storage Filtering](tech-spec-epic-02-SYSTEMS.md#storage-item-filtering-system)
- [ ] Implement global filters
- [ ] Implement per-port filters
- [ ] Test filtering logic

### STORY-02.7: Hub Screen (4 SP)
- [ ] Read [UI.md - Hub Screen](tech-spec-epic-02-UI.md#1-main-hub-screen-home-view-overview)
- [ ] Implement dashboard
- [ ] Implement stat cards
- [ ] Test updates

### STORY-02.7b: Biom Gathering (2 SP)
- [ ] Read [UI.md - Biom Gathering](tech-spec-epic-02-UI.md#3-biom-gathering-screen-zbieranie-surowcow)
- [ ] Implement gathering UI
- [ ] Test progress bars
- [ ] Implement biom switching

---

## 🎯 Critical Formulas

### Offline Production
```
itemsProcessed = Math.min(
  farm.inputBuffer.length,
  (timeOfflineSeconds / itemCycleTime) * 0.8
)

goldEarned = itemsProcessed * baseValue * (1.0 + tradingSkillBonus)
```

**See:** [SYSTEMS.md - Offline Production Calculation](tech-spec-epic-02-SYSTEMS.md#farm-offline-production-calculation)

### Grid Expansion Cost
```
Expansion 1: 50 beton = 50 * 56s = 2,800s crafting = 46+ minutes
Expansion 2: 100 beton = 100 * 56s = 5,600s crafting = 93+ minutes
```

**See:** [SYSTEMS.md - Grid Expansion Mechanics](tech-spec-epic-02-SYSTEMS.md#expansion-mechanics)

### Storage Filtering Logic
```
1. Global check: Is item type accepted?
   YES → Enter storage
   NO → Back up on conveyor

2. When leaving: Check each port's filter
   If matches white-list → Send
   If blocked by black-list → Try next port
   If no port accepts → Stay in storage
```

**See:** [SYSTEMS.md - Filtering Logic Flow](tech-spec-epic-02-SYSTEMS.md#filtering-logic-flow)

---

## 📱 Responsive Design Notes

All UI screens designed for:
- **Mobile first:** 375px (iPhone SE) minimum
- **Tablet compatible:** Up to 1024px
- **Performance:** 60 FPS animations
- **Accessibility:** 44px touch targets

See [UI.md - Mobile Optimization](tech-spec-epic-02-UI.md) for details per screen.

---

## 🔄 Document Navigation

### From CORE.md
- [Conveyor System Details](tech-spec-epic-02-SYSTEMS.md#conveyor-system-complete) (in SYSTEMS.md)
- [NPCs Details](tech-spec-epic-02-SYSTEMS.md#npc-trading-system) (in SYSTEMS.md)
- [UI Mockups](tech-spec-epic-02-UI.md) (in UI.md)

### From SYSTEMS.md
- [Resource Properties](tech-spec-epic-02-CORE.md#resources) (in CORE.md)
- [Building Specs](tech-spec-epic-02-CORE.md#buildings) (in CORE.md)
- [UI Implementation](tech-spec-epic-02-UI.md) (in UI.md)

### From UI.md
- [Resource Types](tech-spec-epic-02-CORE.md#resources) (in CORE.md)
- [Building Mechanics](tech-spec-epic-02-CORE.md#buildings) (in CORE.md)
- [NPC System](tech-spec-epic-02-SYSTEMS.md#npc-trading-system) (in SYSTEMS.md)

---

## 📊 Document Statistics

| Document | Lines | Words | Sections | Audience |
|----------|-------|-------|----------|----------|
| INDEX.md | ~250 | 1,500 | 10 | Everyone |
| CORE.md | ~600 | 4,000 | 8 | Developers |
| SYSTEMS.md | ~900 | 6,000 | 6 | Senior devs |
| UI.md | ~2,000 | 12,000 | 6 | UI/UX devs |
| **TOTAL** | **~3,750** | **~23,500** | **26+** | **All roles** |

---

## 🚀 Getting Started

**First time reading?**
1. Read this INDEX.md (10 min)
2. Read [CORE.md](tech-spec-epic-02-CORE.md) (20 min)
3. Skim [SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md) (10 min)
4. Jump to [UI.md](tech-spec-epic-02-UI.md) sections relevant to your work

**Looking for specific info?**
→ Use the topic map above to find your section

**Implementing a story?**
→ Use the implementation checklist above

**Need a formula?**
→ Check the Critical Formulas section above

---

## 📞 Questions or Clarifications?

Reference these quick answers:

**Q: Why 80% offline efficiency?**
A: Fair balance between passive income and active play. Not 100% (would reward inactivity), not 50% (would feel pointless).

**Q: When does grid expand?**
A: Two options: Build 6+ buildings, OR storage fills. Whichever happens first.

**Q: What resources are there?**
A: 7 total. See Resources table above or [CORE.md](tech-spec-epic-02-CORE.md#resources).

**Q: How do NPCs work?**
A: Three types: Kupiec (gold), Inżynier (barter), Nomada (special). See [SYSTEMS.md](tech-spec-epic-02-SYSTEMS.md#npc-trading-system).

**Q: What's the economic goal?**
A: 1000g in 120 minutes. Verified achievable via three phases.

---

## ✨ Last Updated

**Date:** 2025-12-03
**Version:** 3.0 (Split into 4 documents)
**Status:** ✅ Complete & Ready for Implementation

---

**Ready to start? →** [Read CORE.md](tech-spec-epic-02-CORE.md)
