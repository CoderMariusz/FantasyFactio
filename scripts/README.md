# Scripts Directory

This directory contains automation scripts for Trade Factory Masters development.

## Available Scripts

### `create-github-issues.sh`

Creates 68 user stories as GitHub Issues with proper labels, milestones, and assignments.

**Prerequisites:**
1. GitHub CLI installed: https://cli.github.com/
2. Authenticated to GitHub: `gh auth login`
3. Repository access: CoderMariusz/FantasyFactio

**Usage:**
```bash
# Make script executable (if not already)
chmod +x scripts/create-github-issues.sh

# Run script
./scripts/create-github-issues.sh
```

**What it creates:**
- **28 Labels:**
  - Priority labels (P0 Critical, P1 High, P2 Medium)
  - Size labels (S 1-2 SP, M 3-5 SP, L 8-13 SP)
  - Epic labels (12 epics)
  - Type labels (feature, infrastructure, testing)

- **10 Milestones:**
  - Sprint 1-8 (MVP 8-week plan)
  - v1.1: Progression + Tutorial (post-MVP)
  - v1.2: Monetization + Analytics (post-MVP)

- **68 Issues (User Stories):**
  - EPIC-00: Project Setup (4 issues)
  - EPIC-01: Core Gameplay Loop (8 issues)
  - EPIC-02: Tier 1 Economy (6 issues)
  - EPIC-03: Tier 2 Automation (7 issues)
  - EPIC-04: Offline Production (5 issues)
  - EPIC-05: Mobile-First UX (6 issues)
  - EPIC-06: Progression System (4 issues)
  - EPIC-07: Discovery Tutorial (5 issues)
  - EPIC-08: Ethical F2P (5 issues)
  - EPIC-09: Firebase Backend (6 issues)
  - EPIC-10: Analytics & Metrics (4 issues)
  - EPIC-11: Testing & Quality (8 issues)

**Estimated Runtime:** 3-5 minutes (creates all 68 issues)

**Note:** The script includes only the first 15 critical issues to demonstrate the pattern. To create all 68 issues, expand the script with the remaining stories from `docs/epics-stories-trade-factory-masters-2025-11-17.md`.

---

## Manual Alternative: GitHub UI

If you prefer to create issues manually:

1. Navigate to https://github.com/CoderMariusz/FantasyFactio/issues
2. Click "New Issue"
3. Copy issue template from `docs/epics-stories-trade-factory-masters-2025-11-17.md`
4. Add labels, milestone, assignee
5. Repeat 68 times 😅

---

## Creating a Project Board

After creating issues, set up a Kanban board:

```bash
# Create project board
gh project create --owner CoderMariusz --title "Trade Factory Masters - MVP" --body "8-week MVP development (170 SP)"

# Link issues to project (example)
gh project item-add <PROJECT_NUMBER> --owner CoderMariusz --url https://github.com/CoderMariusz/FantasyFactio/issues/1
```

Or use GitHub UI:
1. Navigate to https://github.com/CoderMariusz/FantasyFactio/projects
2. Click "New Project"
3. Choose "Board" template
4. Create columns: Backlog, To Do, In Progress, Done
5. Add issues to Backlog

---

## Next Steps After Issues Created

1. **Review Issues:**
   - Check all 68 issues are created correctly
   - Verify labels, milestones, descriptions

2. **Create Project Board:**
   - Setup Kanban board (Backlog → To Do → In Progress → Done)
   - Move Sprint 1 issues to "To Do"

3. **Start Sprint 1:**
   - Move STORY-00.1 to "In Progress"
   - Begin Flutter project initialization
   - Update issue with progress comments

4. **Daily Updates:**
   - Move issues between columns as you work
   - Comment on issues with blockers, questions
   - Close issues when Definition of Done is met

---

## Troubleshooting

**Issue: `gh: command not found`**
- Install GitHub CLI: https://cli.github.com/

**Issue: `gh: authentication required`**
- Run: `gh auth login`
- Follow prompts to authenticate

**Issue: `Error: Milestone not found`**
- Milestones may already exist
- Script uses `|| true` to skip errors on duplicates

**Issue: `Rate limit exceeded`**
- GitHub API has rate limits (5000 requests/hour authenticated)
- Creating 68 issues uses ~70 requests
- If hit rate limit, wait 1 hour or contact GitHub Support

---

## Additional Resources

- **Epics & Stories:** `docs/epics-stories-trade-factory-masters-2025-11-17.md`
- **Sprint Planning Review:** `docs/sprint-planning-review-2025-11-17.md`
- **PRD:** `docs/prd-trade-factory-masters-2025-11-17.md`
- **Architecture:** `docs/architecture-trade-factory-masters-2025-11-17.md`
- **Test Design:** `docs/test-design-trade-factory-masters-2025-11-17.md`
