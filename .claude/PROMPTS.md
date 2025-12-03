# PROMPTS - Ready-to-Use Task Prompts

<!-- AI-INDEX: prompts, workflow, tasks, templates, guidelines -->

Last Updated: 2025-12-02

---

## Using These Prompts

These are **starting templates** for common tasks. Customize with specifics:

- Replace `{PLACEHOLDER}` with actual values
- Add context from epic files
- Include file:line references when discussing bugs
- Reference PATTERNS.md for code style

---

## 1. Fix Critical Bug

Use this when starting work on a known bug.

```
Task: Fix Bug - {BUG_NAME}

Status: The bug is documented in docs/2-MANAGEMENT/EPIC-1-ISSUES.md - Bug #{NUMBER}

Bug Description:
- Location: {FILE}:{LINE}
- Issue: {WHAT'S WRONG}
- Impact: {WHY IT MATTERS}
- Expected behavior: {WHAT SHOULD HAPPEN}

Requirements:
1. Read the bug documentation
2. Read the affected code file
3. Fix the bug
4. Add/update unit tests
5. Verify the fix doesn't break other tests
6. Commit with message: "fix: {description}"

After completing:
- Update CLAUDE.md Known Issues section (remove if fixed)
- Update FILE-MAP.md status
- Update docs/2-MANAGEMENT/project-status.md
```

**Examples:**

```
Task: Fix Bug #1 - Integration Test Compilation Error

Location: integration_test/core_gameplay_loop_test.dart

Details:
- The test uses wrong parameter name 'buildingId' instead of 'building'
- UpgradeBuilding.execute() expects Building object, not String
- Integration test won't compile

Requirements:
1. Open integration_test/core_gameplay_loop_test.dart
2. Find all lines with "buildingId:" (expect ~4 instances)
3. Change to "building: {buildingName}"
4. Run: flutter test integration_test/
5. Verify test compiles and runs
6. Commit with: "fix: correct integration test parameters"
```

---

## 2. Implement New Feature (Story)

Use when implementing a story from the epic backlog.

```
Task: Implement Story - {EPIC}.{STORY_NUMBER}: {STORY_NAME}

Sprint: {SPRINT_NUMBER}
Story Points: {SP}
Priority: {P0/P1/P2}

Story Description:
As a {USER_TYPE}
I want {ACTION}
So that {BENEFIT}

Acceptance Criteria:
- [ ] {AC1}
- [ ] {AC2}
- [ ] {AC3}

Technical Notes:
{FROM EPIC FILE}

Dependencies:
- {STORY_X.Y} (if any)

Requirements:
1. Read full story in docs/2-MANAGEMENT/epics/epic-{N}.md
2. Review PATTERNS.md for relevant patterns
3. Create files following FILE-MAP.md organization
4. Write unit tests as you code
5. Ensure all tests pass
6. Update FILE-MAP.md with new files
7. Update epic story status: ✅ Done
8. Update project-status.md progress

Architecture:
- Domain logic: lib/domain/{core|entities|usecases}/
- Game code: lib/game/components/ or lib/game/camera/
- Tests: test/ or integration_test/
- Follow patterns from PATTERNS.md
```

**Example:**

```
Task: Implement Story - EPIC-02.1: Building Definitions

Story Points: 8
Sprint: Sprint 2

Story:
As a Player
I want to know what resources each building produces and costs
So that I can plan my factory efficiently

Acceptance Criteria:
- [ ] Create BuildingConfig class with production/upgrade data
- [ ] Load configs from JSON file
- [ ] Farm produces 1 wood per second
- [ ] Mine produces 1 iron per second
- [ ] Upgrade cost formula works (100 * level^2)
- [ ] All configs tested

Technical Implementation:
- Create lib/domain/entities/building_config.dart
- Create building_configs.json data file
- Implement config loader in data layer
- Add unit tests for configs
- Integration test: verify loaded configs match expected values

Dependencies:
- STORY-01.2: Resource entity (DONE)
```

---

## 3. Continue Work on Project

Use when resuming work or checking status.

```
Task: Continue Development on FantasyFactio

First Steps:
1. Read CLAUDE.md (current status)
2. Read docs/2-MANAGEMENT/project-status.md (progress)
3. Read docs/2-MANAGEMENT/MVP-TODO.md (what's left)
4. Review latest epic in docs/2-MANAGEMENT/epics/

Current Context:
- Phase: {EPIC_PHASE}
- Completed: {STORIES_DONE}
- In Progress: {CURRENT_WORK}
- Next: {UPCOMING}

Your Task:
1. Summarize project status
2. List 3 next prioritized tasks
3. Identify any blockers
4. Suggest next action (with detailed steps)

Focus Areas:
- Epic 1 bug fixes (Critical)
- Epic 2 planning/implementation (High Priority)
- Documentation updates (Medium Priority)
```

---

## 4. Create Documentation

Use when writing or updating project documentation.

```
Task: Update Documentation - {TOPIC}

Type: {Bug Report / Architecture / Feature / Progress}
Target Audience: {Developer / Team Lead / Product Manager}

Content Requirements:
1. {WHAT TO INCLUDE}
2. {WHAT TO INCLUDE}
3. {FORMAT/STRUCTURE}

Location: docs/{PATH}/{filename}.md

Template Structure:
- Title
- Quick Summary (1-3 sentences)
- Context (if needed)
- Content (main body)
- Examples (if applicable)
- References (links to related docs)
- Last Updated

After writing:
1. Proof-read for clarity
2. Add AI-INDEX comment at top
3. Check for broken internal links
4. Update CLAUDE.md if relevant
```

**Example:**

```
Task: Create Epic 1 Issues Document

Type: Bug Report
Location: docs/2-MANAGEMENT/EPIC-1-ISSUES.md

Content:
- Title: Epic 1 - Identified Issues & Fixes
- Overview: List of bugs found during Epic 1 code review
- Critical Issues (with detailed fixes)
  - Bug #1: Integration Test Compilation
  - Bug #2: Resource Inventory Logic
  - Bug #3: Type Cast Syntax
- Medium Issues (nice-to-fix)
- Testing Strategy (how to verify fixes)
- Commit History (once fixed)

Format: Markdown, use tables for organization
```

---

## 5. Code Review

Use when reviewing implementation or helping debug.

```
Task: Code Review - {FILE_PATH}

Purpose: {Review for correctness / Test coverage / Performance}

Files to Review:
- {lib/path/file1.dart}
- {lib/path/file2.dart}

Checklist:
- [ ] Follows patterns from PATTERNS.md
- [ ] Properly handles errors (Result type)
- [ ] Tests exist and cover edge cases
- [ ] No hardcoded values (use constants)
- [ ] Immutability enforced (entities)
- [ ] Naming follows conventions
- [ ] No performance issues
- [ ] Comments where logic isn't obvious

For Each File:
1. Summarize what the code does
2. List any issues found (with severity)
3. Suggest improvements (if appropriate)
4. Check against PATTERNS.md
5. Verify tests exist

Output Format:
## {Filename}
**Status:** {✅ Looks good / ⚠️ Needs fixes / ❌ Blocked}
**Summary:** {What it does}
**Issues:** {List any problems}
**Suggestions:** {Improvements}
```

---

## 6. Run Tests & Verify

Use when testing implementation.

```
Task: Run Tests & Verify Implementation

Test Type: {Unit / Integration / All}
Scope: {Specific file / Specific feature / All tests}

Commands:
1. Unit tests:
   flutter test test/

2. Integration tests:
   flutter test integration_test/

3. Code analysis:
   flutter analyze

4. Specific test file:
   flutter test test/domain/entities/building_test.dart

After Running:
1. Report which tests pass/fail
2. If failures: provide error messages
3. Identify patterns in failures
4. Suggest fixes for failing tests
5. Verify coverage for modified files

Success Criteria:
- All tests pass ✅
- No warnings from analysis ✅
- Coverage > 80% for touched code ✅
```

---

## 7. Refactor Code

Use when improving existing code without changing behavior.

```
Task: Refactor - {WHAT TO IMPROVE}

Scope: {Specific function / Entire class / Multiple files}
Goal: {Improve readability / Remove duplication / Extract constants}

Before Changes:
1. Read and understand current implementation
2. Identify what needs improvement
3. Check if existing tests cover this code
4. Plan refactoring steps

Refactoring Steps:
1. {Step 1 - what to change}
2. {Step 2 - verify still works}
3. {Step 3 - test}

After Refactoring:
- [ ] All tests still pass
- [ ] No functional changes
- [ ] Code is clearer/more maintainable
- [ ] Commit message explains why

Commit Format:
refactor: {description of improvement}
```

**Example:**

```
Task: Refactor - Extract Magic Numbers to Constants

Goal: Improve maintainability by removing hardcoded values

Files to Update:
- lib/main.dart (grid config, camera config)
- lib/game/components/building_component.dart (offsets, radius)

Steps:
1. Create lib/config/game_config.dart
2. Define constants: GRID_WIDTH, GRID_HEIGHT, MIN_ZOOM, MAX_ZOOM, etc.
3. Update lib/main.dart to import and use constants
4. Update lib/game/components/building_component.dart
5. Run: flutter test
6. Commit: refactor: extract game config constants
```

---

## 8. Database/Schema Changes

Use when modifying data models or storage.

```
Task: Update Data Model - {MODEL_NAME}

Type: {Add field / Remove field / Modify structure}
Scope: {Domain entity / Firestore schema / Hive storage}

Current State:
- Current model in: {FILE_PATH}
- Related schema in: .claude/TABLES.md

Changes:
1. {What to add/change}
2. {Affects}
3. {Migration needed}

Implementation Checklist:
- [ ] Update domain entity (lib/domain/entities/)
- [ ] Add/update copyWith() if fields changed
- [ ] Update == and hashCode
- [ ] Update TABLES.md schema doc
- [ ] Create/update tests
- [ ] Update any dependent code
- [ ] Plan Firestore migration (if needed)
- [ ] Plan Hive migration (if needed)

Testing:
- [ ] Unit tests for new/changed fields
- [ ] Serialization/deserialization tests
- [ ] Backward compatibility tests (if migrating)

Commit:
feat: add {field} to {Model} entity
or
refactor: update {Model} schema
```

---

## 9. Performance Investigation

Use when investigating performance issues.

```
Task: Performance Investigation - {ISSUE}

Symptom: {What's slow / What's using too much memory / What's crashing}
Impact: {How it affects gameplay / Users}

Investigation Steps:
1. Identify the bottleneck
   - Is it CPU? (profiling needed)
   - Is it memory? (heap analysis)
   - Is it rendering? (frame drops)
   - Is it storage? (Hive/Firestore)

2. Measure current performance
   - FPS: {measure in game}
   - Memory: {check device monitor}
   - Load time: {measure with diagnostics}

3. Profile affected code
   - Add performance markers
   - Measure specific operations
   - Identify slowest parts

4. Propose optimizations
   - Code changes
   - Architecture changes
   - Algorithm improvements

5. Implement & test
   - Apply optimization
   - Re-measure performance
   - Verify no regression elsewhere

Report Format:
- Current: {metric X}
- Target: {metric Y}
- Optimization: {what was changed}
- Result: {new metric}
- Impact: {how much better}
```

---

## Template Variables Reference

| Variable | Replace With | Example |
|----------|--------------|---------|
| `{BUG_NAME}` | Short bug title | Integration Test Parameter Mismatch |
| `{FILE}` | File path | lib/domain/entities/player_economy.dart |
| `{LINE}` | Line number | 52-56 |
| `{EPIC}` | Epic number | EPIC-02 |
| `{STORY_NUMBER}` | Story number | 2.1 |
| `{SP}` | Story points | 8 |
| `{SPRINT_NUMBER}` | Sprint number | Sprint 2 |
| `{USER_TYPE}` | Type of user | Player / Game Master |
| `{ACTION}` | What user does | collect resources from buildings |
| `{BENEFIT}` | Why it matters | progress in the game |
| `{AC}` | Acceptance criteria | building on grid works correctly |

---

## Workflow Tips

### Before Starting Any Task

1. Read the relevant prompt template above
2. Customize with specific context
3. Read referenced documentation
4. Check for dependencies

### During Implementation

1. Refer back to prompt for requirements
2. Use PATTERNS.md for code examples
3. Keep tests passing throughout
4. Update FILE-MAP.md as you go

### After Completing

1. Update status in epic file
2. Update project-status.md
3. Commit with good message
4. Note any blockers for next task

---

## Common Workflow Chains

### Fix Critical Bug → Move to Next Epic

```
1. Fix Bug (use Prompt #1)
2. Update docs (use Prompt #4)
3. Run Tests (use Prompt #6)
4. Plan Epic 2 (use Prompt #2)
```

### Implement Full Epic (Multiple Stories)

```
For Each Story:
  1. Use Prompt #2 (Implement Feature)
  2. Use Prompt #6 (Run Tests)
  3. Use Prompt #3 (Continue Work - check status)
```

### Performance Improvements

```
1. Use Prompt #9 (Performance Investigation)
2. Use Prompt #7 (Refactor Code)
3. Use Prompt #6 (Run Tests & Verify)
```

---

## Last Updated

- Date: 2025-12-02
- Total Prompts: 9
- Added: Documentation, Code Review, Performance Prompts
