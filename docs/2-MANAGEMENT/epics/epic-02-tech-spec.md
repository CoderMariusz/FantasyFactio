# Epic 2: Tier 1 Economy - Technical Specification

**Epic:** EPIC-02 - Tier 1 Economy
**Total SP:** 26
**Duration:** 2-3 weeks (Sprints 2-3)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03

---

## Overview

EPIC-02 implementuje **podstawową ekonomię gry (Tier 1)** obejmującą system zasobów, budynków, NPC handlarzy i siatki świata. Jest to fundament na którym budowane są kolejne systemy automatyzacji (EPIC-03) i offline production (EPIC-04).

**Business Value:**
- Core gameplay loop dla early game
- 7 zasobów, 6 budynków, 3 NPC
- Cel: 1000 gold w 120 minut

---

## Documentation Structure

Szczegółowa specyfikacja techniczna Epic 2 jest podzielona na **4 dokumenty** w `sprint-artifacts/`:

### Part 1: Core Mechanics
📄 **[tech-spec-epic-02-CORE.md](../../sprint-artifacts/tech-spec-epic-02-CORE.md)**
- Resources (7 types, all properties)
- Buildings (6 buildings, full specs)
- Grid System (20×20 start)
- Skill Progression
- Demolition System

**Size:** ~600 lines | **Read time:** 15-20 minutes

### Part 2: Game Systems
📄 **[tech-spec-epic-02-SYSTEMS.md](../../sprint-artifacts/tech-spec-epic-02-SYSTEMS.md)**
- NPC Trading System (3 NPCs)
- Grid Expansion (20→30→40)
- Storage Filtering (basic)

**Note:** Conveyor System → [epic-03-tech-spec.md](epic-03-tech-spec.md)
**Note:** Offline Production → [epic-04-tech-spec.md](epic-04-tech-spec.md)

**Size:** ~400 lines | **Read time:** 15 minutes

### Part 3: User Interface
📄 **[tech-spec-epic-02-UI.md](../../sprint-artifacts/tech-spec-epic-02-UI.md)**
- Hub Screen (dashboard)
- Grid World Screen (map & placement)
- Biom Gathering Screen (resource collection)
- Storage Management Screen (inventory)
- Crafting Queue Screen (production)
- NPC Trading Screens (commerce)

**Size:** ~1,500-2,000 lines | **Read time:** 40-50 minutes

### Part 4: Index & Navigation
📄 **[tech-spec-epic-02-INDEX.md](../../sprint-artifacts/tech-spec-epic-02-INDEX.md)**
- Document structure
- Quick reference tables
- Cross-references
- Dependencies
- Implementation checklist

**Size:** ~200 lines | **Read time:** 5-10 minutes

---

## Scope Boundaries

### IN SCOPE (Epic 2)

| Component | Details |
|-----------|---------|
| **Resources** | 8 types: Węgiel, Ruda Żelaza, Drewno, Kamień, Miedź, Wata, Sól, Glina |
| **Buildings** | 6 types: Mining, Storage, Smelter, Conveyor (def only), Workshop, Farm |
| **NPCs** | 3 traders: Kupiec, Inżynier, Nomada |
| **Grid** | 20×20 start, expand to 30×30, 40×40 |
| **Skills** | Basic progression: Mining, Smelting, Trading |
| **Production** | Online production cycles, manual transport |

### OUT OF SCOPE (Other Epics)

| Component | Epic | Details |
|-----------|------|---------|
| **Conveyor Transport** | EPIC-03 | A* pathfinding, filtering, splitters |
| **Offline Production** | EPIC-04 | 80% efficiency, welcome back modal |
| **Extended Skills** | EPIC-06 | Skill trees, achievements |
| **Monetization** | EPIC-08 | $10 cap, rewarded video |

---

## Key Specs at a Glance

### Resources (8 Total)

| Resource | Speed | Biom | Value |
|----------|-------|------|-------|
| Węgiel (Coal) | 1.25s | Koppalnia | 1g |
| Ruda Żelaza (Iron Ore) | 1.25s | Koppalnia | 1g |
| Drewno (Wood) | 1.88s | Las | 1.5g |
| Kamień (Stone) | 2.5s | Góry | 1g |
| Miedź (Copper) | 5.0s | Góry | 5g |
| Wata (Cotton) | 1.88s | Jezioro | 2g |
| Sól (Salt) | 3.75s | Jezioro | 3g |
| Glina (Clay) | 3.13s | Jezioro | 1.5g |

### Buildings (6 Total)

| Building | Size | Cost | Function |
|----------|------|------|----------|
| Mining | 2×2 | FREE | +50% gather |
| Storage | 2×2 | 5D+10K | 200 items |
| Smelter | 2×3 | 15D+10K+5M | Auto-craft |
| Conveyor | 1×1 | 2D+1Z | Placement only* |
| Workshop | 2×2 | 20D+15K+5Z | Auto-craft |
| Farm | 3×3 | 25B+12Z+15D | Items→gold |

*Conveyor transport mechanics → EPIC-03

---

## Dependencies

**Depends On:**
- ✅ EPIC-01 (Core Gameplay Loop)

**Blocks:**
- → EPIC-03 (Automation - needs buildings & resources)
- → EPIC-04 (Offline - needs farm & production)
- → EPIC-05 (Mobile UX - needs UI foundations)

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [epic-02-stories.md](epic-02-stories.md) | User stories & acceptance criteria |
| [epic-03-tech-spec.md](epic-03-tech-spec.md) | Conveyor automation system |
| [epic-04-tech-spec.md](epic-04-tech-spec.md) | Offline production system |
| [epic-05-tech-spec.md](epic-05-tech-spec.md) | Mobile-first UX |
| [epic-08-tech-spec.md](epic-08-tech-spec.md) | Ethical F2P monetization |

---

## Getting Started

**For Implementation:**
1. Read this index (5 min)
2. Read [CORE.md](../../sprint-artifacts/tech-spec-epic-02-CORE.md) for resources & buildings
3. Read [SYSTEMS.md](../../sprint-artifacts/tech-spec-epic-02-SYSTEMS.md) for NPC & grid
4. Reference [UI.md](../../sprint-artifacts/tech-spec-epic-02-UI.md) for screens
5. Follow stories in [epic-02-stories.md](epic-02-stories.md)

**For Review:**
1. Check [INDEX.md](../../sprint-artifacts/tech-spec-epic-02-INDEX.md) for quick reference

---

**Status:** 📋 Ready for Implementation
**Last Updated:** 2025-12-03
**Version:** 2.0 (Reorganized - systems moved to respective epics)
