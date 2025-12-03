# BMAD V6 Documentation Structure

<!-- AI-INDEX: documentation, structure, bmad, organization, guidelines -->

**Project:** Trade Factory Masters
**Documentation Version:** BMAD V6
**Last Updated:** 2025-12-02

---

## What is BMAD?

**BMAD** = **B**aseline **M**anagement **A**rchitecture **D**esign

It's an enterprise methodology for organizing project documentation that works well with AI-assisted development. Key principles:

1. **Phased documentation** - aligns with project phases
2. **Clear ownership** - each document has a purpose
3. **AI-optimized** - separate files for humans and AI
4. **Scalable** - works for projects of any size

---

## Directory Structure

```
project/
├── CLAUDE.md                          ← Entry point for AI
├── .claude/                           ← AI-optimized docs
│   ├── FILE-MAP.md                    ← Code index
│   ├── TABLES.md                      ← Data schema
│   ├── PATTERNS.md                    ← Code patterns
│   └── PROMPTS.md                     ← Task templates
│
└── docs/                              ← Human-readable docs
    ├── 00-START-HERE.md               ← First read (this file is guide)
    ├── BMAD-STRUCTURE.md              ← This document
    │
    ├── 1-BASELINE/                    ← Phase 1-2: Analysis & Planning
    │   ├── product/                   ← Product documentation
    │   │   ├── prd-v1.0.md            ← Product Requirements Document
    │   │   ├── product-brief.md       ← Vision & market
    │   │   └── market-research.md     ← Competitive analysis
    │   │
    │   └── architecture/              ← Technical documentation
    │       ├── system-architecture.md ← System design
    │       ├── database-schema.md     ← Data models (if detailed)
    │       └── tech-decisions.md      ← ADRs, why we chose what
    │
    ├── 2-MANAGEMENT/                  ← Phase 3-4: Planning & Execution
    │   ├── project-status.md          ← Current state, progress
    │   ├── MVP-TODO.md                ← Remaining work
    │   │
    │   └── epics/                     ← Epic & story files
    │       ├── epic-00-project-setup.md
    │       ├── epic-01-core-gameplay.md
    │       ├── epic-02-tier-1-economy.md
    │       └── ...epic-03-12...
    │
    ├── 3-ARCHITECTURE/                ← Deep technical details (optional)
    │   ├── state-management.md
    │   ├── game-engine-design.md
    │   └── performance-tuning.md
    │
    ├── 4-DEVELOPMENT/                 ← Phase 4: Implementation guides
    │   ├── SETUP.md                   ← Environment setup
    │   ├── DEVELOPMENT.md             ← Dev guidelines
    │   ├── WORKFLOW.md                ← Daily workflow
    │   └── TROUBLESHOOTING.md         ← Common issues
    │
    └── 5-ARCHIVE/                     ← Deprecated docs (don't delete!)
        ├── old-prd-2025-11-17.md
        ├── old-architecture.md
        └── ...other old versions...
```

---

## File Purpose & Content Guidelines

### .claude/ - AI-Optimized Documentation

These files are designed for AI to read first. **Keep them concise and structured.**

| File | Purpose | Format | Audience |
|------|---------|--------|----------|
| **FILE-MAP.md** | Index of all code files by category | Tables + short descriptions | AI reading code |
| **TABLES.md** | Database schema, data models | Tables + examples | AI writing data code |
| **PATTERNS.md** | Code patterns, conventions | Code examples + explanation | AI writing features |
| **PROMPTS.md** | Task templates and workflows | Markdown templates | AI starting new work |

**Key Rule:** These files should be readable in <5 minutes by AI.

---

### docs/1-BASELINE/ - Requirements & Architecture

**When:** Completed during Phase 1-2 (Analysis & Planning)
**Who Owns:** Product Manager, Architect
**Who Uses:** Developers (reference), AI (understanding context)

#### docs/1-BASELINE/product/

**prd-v1.0.md** - Product Requirements Document
- What the product does
- Who uses it
- Why it's valuable
- Feature list with acceptance criteria
- Out of scope items
- Success metrics

**product-brief.md** - Vision & Market
- Product vision
- Market gap / opportunity
- Competitive landscape
- Revenue model
- Key assumptions

**market-research.md** - Market Analysis
- Market size
- Target audience
- Competitor analysis
- Pricing analysis
- Regulatory considerations

#### docs/1-BASELINE/architecture/

**system-architecture.md** - Technical Design
- High-level architecture diagram
- Technology choices
- Data flow
- Performance targets
- Security model

**database-schema.md** (if detailed) - Data Models
- Entity definitions
- Relationships
- Constraints
- Firestore structure
- Migration strategy

**tech-decisions.md** - Architecture Decision Records (ADRs)
- Decision made
- Context/problem
- Options considered
- Decision + reasoning
- Consequences

---

### docs/2-MANAGEMENT/ - Status & Tracking

**When:** Created during Phase 3 (Planning) & updated during Phase 4 (Execution)
**Who Owns:** Project Manager / Scrum Master
**Who Uses:** Everyone (developers, managers, stakeholders)
**Update Frequency:** Weekly (or per sprint)

#### project-status.md

**Purpose:** Single source of truth for project status

**Content:**
- Current phase and sprint
- Metrics (% complete, story points, velocity)
- Module/epic progress breakdown
- Current blockers
- Next sprint priorities
- Recent changes
- Risk assessment

**Format:** Markdown with tables and progress indicators

**Update:** Weekly by PM/SM

#### MVP-TODO.md

**Purpose:** High-level remaining work

**Content:**
- Grouped by epic
- Story count and points per epic
- Status indicators
- Dependencies
- Estimated timeline

**Format:** Nested lists or tables

#### EPIC-1-ISSUES.md (Example)

**Purpose:** Bug tracking and issue resolution (one per epic if issues exist)

**Content:**
- List of critical bugs with details
- Severity and impact
- Fix instructions
- Timeline for fixes

#### epics/

**epic-NN-{name}.md** - Epic Definition & Stories

**Purpose:** Container for all stories in an epic

**Content:**
- Epic overview
- High-level goals
- Complete story list (each with AC, implementation notes)
- Epic status
- Retrospective (after completion)

**Format:** See "Epic & Story Format" below

---

### docs/4-DEVELOPMENT/ - Developer Guides

**When:** Created before development starts, updated as needed
**Who Owns:** Tech Lead / Lead Developer
**Who Uses:** Developers (daily reference)
**Update Frequency:** As needed

**SETUP.md** - Environment Setup
- Prerequisites
- Installation steps
- First-time setup checklist
- Verification steps

**DEVELOPMENT.md** - Development Guidelines
- Coding standards
- Git workflow (branching, commits)
- Code review process
- Testing requirements
- Documentation requirements

**WORKFLOW.md** - Daily Workflow (Optional)
- How to start a day's work
- How to pick a story
- How to run tests
- How to commit and push
- How to wrap up

**TROUBLESHOOTING.md** - Common Issues
- Build errors and solutions
- Test failures and debugging
- Firebase setup issues
- Performance problems
- Deployment issues

---

### docs/5-ARCHIVE/ - Deprecated Documentation

**Purpose:** Keep old versions for historical reference

**When to Archive:**
- Documentation is superseded by newer version
- Feature is deprecated
- Plan changed and doc no longer relevant

**Example:**
```
5-ARCHIVE/
├── prd-2025-11-17-v0.9.md         ← Old version
├── architecture-old.md             ← Replaced by new version
└── brainstorm-results.md           ← Session output, not live doc
```

**Important:** Never delete old docs! Archive them.

---

## Epic & Story Format (BMAD Compatible)

### Epic File Format

```markdown
# Epic {N}: {Name}

**Epic ID:** EPIC-0{N}
**Sprint(s):** Sprint {X}-{Y}
**Story Points:** {total}
**Status:** 🔄 In Progress | ⏳ Planned | ✅ Done
**Priority:** P0 (Critical) | P1 (High) | P2 (Nice-to-have)

## Overview
{1-3 paragraph description of epic}

## Business Value
{Why this epic matters}

## Acceptance Criteria (Epic Level)
- [ ] {Epic AC 1}
- [ ] {Epic AC 2}

## Dependencies
- {Epic X.Y if dependent on another epic}
- {External dependency if any}

## Stories

### Story {N}.1: {Name}
**Status:** ⏳ Planned | 🔄 In Progress | ✅ Done
**Story Points:** {SP}
**Technical Notes:** {Implementation hints}

As a {user type}
I want {action}
So that {benefit}

#### Acceptance Criteria
- [ ] {AC1}
- [ ] {AC2}

#### Files to Create/Modify
- lib/path/file.dart
- test/path/file_test.dart

### Story {N}.2: {Name}
...

## Technical Context
{Architectural decisions for this epic}

## Known Issues
{If any issues found during implementation}

## Retrospective (After Completion)
**Completed:** {date}
**Actual SP:** {how many delivered}
**Velocity Notes:** {was it faster/slower than expected, why}
**Learnings:** {what we learned}
**Deferred Items:** {what didn't make it}
```

---

## File Naming Conventions

| Content Type | Format | Example |
|--------------|--------|---------|
| Product doc | `{topic}-v{version}.md` | `prd-v1.0.md` |
| Architecture | `{topic}.md` | `system-architecture.md` |
| Epic | `epic-{NN}-{name}.md` | `epic-02-tier-1-economy.md` |
| Status | `{type}-status.md` | `project-status.md` |
| Guide | `{TOPIC}.md` (CAPS) | `SETUP.md`, `DEVELOPMENT.md` |
| Archive | Original name | `prd-2025-11-17.md` |

---

## Content Guidelines

### Keep It Concise

- **For humans:** 2-5 pages max per document
- **For AI:** Condensed tables, bullet points
- **Long docs:** Split into multiple files

### Link Between Documents

Use relative links:
```markdown
See [details](../1-BASELINE/product/prd-v1.0.md)
Read [patterns](./.claude/PATTERNS.md)
```

### Use Consistent Formatting

- Headings: # H1, ## H2, ### H3 (no more than H4)
- Lists: Use `-` for bullets, `1.` for numbered
- Tables: Use markdown tables, 4-column max for readability
- Code: Use triple backticks with language specified

### Add AI Index

Every doc should start with:
```markdown
<!-- AI-INDEX: keyword1, keyword2, keyword3 -->
```

**Example:**
```markdown
<!-- AI-INDEX: authentication, login, firebase, security -->
```

This helps AI find relevant docs quickly.

### Always Include

- Title (H1)
- AI-INDEX comment (if doc is referenced by code)
- Last Updated date (footer)
- Links to related docs

---

## Update Strategy

### During Development

- **project-status.md:** Update after each sprint (weekly)
- **Epic files:** Update story status as work progresses
- **FILE-MAP.md:** Update when new files created
- **PATTERNS.md:** Update when new patterns established

### After Each Epic

1. Update epic file with retrospective
2. Update project-status.md with metrics
3. Archive any deprecated docs
4. Review all docs for accuracy

### When Making Major Changes

1. Don't delete old docs - archive them
2. Create new version if significant change
3. Update cross-references in other docs
4. Update this BMAD-STRUCTURE.md if structure changed

---

## Common Mistakes to Avoid

❌ **DON'T:**
- Keep docs in scattered locations
- Use outdated versions (always use latest)
- Delete old docs (archive instead)
- Add too much detail (keep it scannable)
- Forget to update docs during development
- Use vague status indicators (use icons: ✅ 🔄 ⏳ ❌)

✅ **DO:**
- Follow the structure above
- Update docs regularly (weekly)
- Archive old versions
- Use clear headings and tables
- Cross-link between documents
- Include concrete examples
- Update "Last Updated" date

---

## Tools & Templates

### AI-Friendly Search

For AI to find docs quickly:
1. Use AI-INDEX comments
2. Maintain FILE-MAP.md current
3. Keep related docs in same folder
4. Use consistent naming

### Human-Friendly Navigation

For humans to find docs:
1. Use clear folder names
2. Maintain README in each folder (optional)
3. Link from START-HERE
4. Keep folder depth < 3 levels

---

## Checklist: Setting Up Documentation

### Initial Setup

- [ ] Create folder structure (as shown above)
- [ ] Create 00-START-HERE.md
- [ ] Create BMAD-STRUCTURE.md (this file)
- [ ] Create .claude/ folder with 4 files
- [ ] Create CLAUDE.md in root
- [ ] Create 1-BASELINE/ with product and architecture

### During Development

- [ ] Create 2-MANAGEMENT/ with status files
- [ ] Add epic files as epics are defined
- [ ] Create 4-DEVELOPMENT/ guides
- [ ] Update project-status.md weekly
- [ ] Add issues files if bugs found

### After Each Milestone

- [ ] Update project-status.md with metrics
- [ ] Archive old docs to 5-ARCHIVE/
- [ ] Review all links (fix any broken)
- [ ] Update CLAUDE.md if needed

---

## FAQ

**Q: Should all documentation be in docs/?**
A: Yes, except CLAUDE.md (in root) and .claude/ (in root). Everything else goes in docs/.

**Q: How often should I update documents?**
A: Weekly for status docs, as-needed for others. Update immediately if info changes.

**Q: Can I delete old documents?**
A: No! Archive them in 5-ARCHIVE/. They're useful for history.

**Q: What if I need a document type not listed here?**
A: Add it! Just make sure it fits in a logical folder and follows the guidelines.

**Q: How detailed should architecture documents be?**
A: Include enough detail for a developer to understand implementation. Too much detail → keep in code comments.

---

## Resources

- **BMAD Method:** Enterprise methodology for documentation
- **This Project:** FantasyFactio uses BMAD V6
- **For Examples:** See docs/ folder in this project
- **For AI:** Read CLAUDE.md for AI-optimized guidelines

---

**Document Owner:** Claude (BMAD Documentation Agent)
**Last Updated:** 2025-12-02
**Version:** BMAD V6 - Release 1.0
