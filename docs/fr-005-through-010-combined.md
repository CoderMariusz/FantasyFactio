**Status:** ✅ FR-004 Specification Complete
**Next:** FR-005 Mobile-First UX

---

### FR-005: Mobile-First UX (HIGH - P1)

**Description:** Mobile-First UX ensures TFM feels native on touchscreens with large tap targets (44×44px minimum), haptic feedback, smooth animations (60 FPS), and one-handed gameplay. This differentiates TFM from desktop ports that feel clunky on mobile.

**Priority:** P1 (High - Core to mobile viability)
**Dependencies:** FR-001, FR-003
**Estimated Complexity:** Medium

---

#### Key Requirements

- **Tap targets:** 44×44px minimum (Build Mode)
- **Gestures:** Swipe, pinch, double-tap, long-press
- **Haptics:** Light (collect), Medium (upgrade), None (fail)
- **60 FPS:** Snapdragon 660 target
- **<50ms tap response:** Visual + haptic
- **One-handed:** 80% thumb-reachable (right-hand mode)

---

**Status:** ✅ FR-005 Specification Complete
**Next:** FR-006 Progression System

---

### FR-006: Progression System (HIGH - P1)

**Description:** The Progression System defines clear unlock gates between Tier 1 (manual) and Tier 2 (automation), creating the rewarding "aha moment" when conveyors unlock. Players must complete specific goals to progress, maintaining engagement and preventing premature advancement.

**Priority:** P1 (High - Defines retention curve)
**Dependencies:** FR-001, FR-002, FR-003
**Estimated Complexity:** Medium

---

#### Tier 1 → Tier 2 Unlock Requirements

**Requirements to Unlock Tier 2:**
1. All 5 building types placed (Lumbermill, Mine, Farm, Smelter, Workshop)
2. All buildings upgraded to Level 5 (max Tier 1)
3. Accumulated 1,000 gold
4. Produced 100 Tools (demonstrates supply chain mastery)
5. Played for minimum 4 hours (prevents rush-through)

**Why These Requirements:**
- **All building types:** Forces exploration of full Tier 1 economy
- **Level 5 all buildings:** Demonstrates commitment, teaches upgrade value
- **1,000 gold:** Ensures economic understanding (profit through production)
- **100 Tools:** Proves multi-step supply chain mastery
- **4 hour minimum:** Target 5h average, prevents exploits

**Unlock Celebration:**
- Full-screen animation (fireworks, confetti, 3 seconds)
- "TIER 2 UNLOCKED! Conveyors Available!"
- +500 gold bonus
- Conveyors appear in Build Menu
- Tutorial prompt: "Connect buildings to automate!"

---

**Status:** ✅ FR-006 Specification Complete
**Next:** FR-007 Discovery-Based Tutorial

---

### FR-007: Discovery-Based Tutorial (MEDIUM - P2)

**Description:** Discovery-based tutorial teaches through gameplay events and contextual tooltips (NO long text tutorials). Players learn by doing, with gentle nudges at key moments. This "show, don't tell" approach respects player intelligence and feels less intrusive than traditional tutorials.

**Priority:** P2 (Medium - Important for onboarding, but can iterate post-launch)
**Dependencies:** FR-001, FR-002
**Estimated Complexity:** Medium

---

#### Tutorial Approach

**First 5 Minutes (Silent Onboarding):**
1. **Start:** Player has 1 Lumbermill pre-placed
2. **Pulse animation:** Lumbermill pulses (indicating "tap me")
3. **First tap:** Player taps → collects Wood → "+5 Wood" appears → haptic feedback
4. **Arrow appears:** Points to NPC Market button (bottom-center)
5. **First sale:** Player opens market → sells Wood → "+25 gold" → "Profit!"
6. **Arrow to upgrade:** Points to Lumbermill → player upgrades → "+20% production"

**No Text Walls:** Zero popup dialogs with paragraphs. Only:
- **Floating arrows** (pointing to next action)
- **Brief tooltips** (<10 words, e.g., "Tap to collect")
- **Celebration text** ("+20% production!")
- **Event notifications** (contextual learning)

**Learning Through Events (Tier 1):**
- **Dragon Attack Event (Hour 2):** "Wood supply disrupted! Prices spiked!" → teaches economics
- **Storage Full (Hour 3):** "Lumbermill full! Upgrade storage?" → teaches storage value
- **First Supply Chain (Hour 4):** Tooltip appears when Smelter placed: "Needs Wood + Ore → Makes Bars"

**Tier 2 Tutorial (Conveyor Placement):**
1. Tier 2 unlocks → celebration
2. Tutorial: "Tap conveyor button" (arrow)
3. "Tap Lumbermill" (arrow)
4. "Tap Smelter" (arrow)
5. AI shows path → "Tap Confirm"
6. Conveyor builds → Wood flows automatically
7. "Automation unlocked! Build more conveyors!" → done

---

**Status:** ✅ FR-007 Specification Complete
**Next:** FR-008 Ethical F2P Monetization

---

### FR-008: Ethical F2P Monetization ($10 Cap) (HIGH - P1)

**Description:** Ethical F2P monetization with **$10 total spending cap** differentiates TFM from predatory mobile games. All content unlockable for $10 or free through grinding. Ads are optional (rewarded video only). No loot boxes, no FOMO mechanics, no pay-to-win. Builds trust and regulatory compliance (EU 2025 laws).

**Priority:** P1 (High - Core business model, differentiator)
**Dependencies:** FR-004 (Offline ads), FR-009 (IAP backend)
**Estimated Complexity:** Low-Medium

---

#### Monetization Strategy

**Premium Unlock: $9.99 One-Time Purchase**
- **Unlocks:** Tier 3 + Tier 4 content (post-MVP)
- **Includes:** All future content updates (no season passes)
- **Value:** 30+ hours additional gameplay
- **Alternative:** Unlock Tier 3/4 by grinding (100 hours total)
- **Why $9.99:** Mobile premium pricing, fair value proposition

**Ads (Optional, Rewarded Only):**
- **Offline Boost:** Watch ad → 2× offline production (see FR-004)
- **Speed Boost:** Watch ad → 2× production speed for 10 minutes
- **Ad Frequency Cap:** Maximum 6 ads/day (prevents spam)
- **No forced ads:** NEVER interrupt gameplay with ads
- **Ethical:** Ad failure doesn't punish player (reward given anyway)

**No Predatory Mechanics:**
- ❌ No loot boxes / gacha
- ❌ No limited-time FOMO events
- ❌ No energy/stamina system
- ❌ No pay-to-win multiplayer advantages
- ❌ No subscription tiers
- ✅ Fixed $10 cap clearly communicated in store
- ✅ All IAPs visible upfront (transparency)

**Revenue Model:**
- **Year 1 Conservative (10k downloads, 35% D7):**
  - IAP: $8k (2% conversion × 10k × $10 × 40% App Store cut = $8k net)
  - Ads: $18k (60% ad watch rate, $20 eCPM, 6 ads/day average)
  - **Total: $26k Year 1**

**EU Regulatory Compliance:**
- Transparent pricing (no hidden costs)
- No loot box mechanics (2025 EU regulations)
- Age-appropriate (PEGI 3 / ESRB E for Everyone)
- Parental controls (in-app purchase restrictions work correctly)

---

**Status:** ✅ FR-008 Specification Complete
**Next:** FR-009 Firebase Backend

---

### FR-009: Firebase Backend (HIGH - P1)

**Description:** Firebase provides authentication, cloud saves, leaderboards, and analytics infrastructure. Chosen for low cost ($3-45/month at scale), zero server management, and instant scalability. Players can switch devices seamlessly with cloud saves.

**Priority:** P1 (High - Critical infrastructure)
**Dependencies:** None (foundational service)
**Estimated Complexity:** Medium

---

#### Firebase Services

**Firebase Authentication:**
- Anonymous auth (no forced signup)
- Optional Google Sign-In (cloud save persistence)
- Optional Apple Sign-In (iOS requirement)
- Guest → Google upgrade flow (preserve progress)

**Cloud Firestore (Game State Sync):**
```
/users/{userId}/
  - profile: {displayName, createdAt, tier, totalPlayTime}
  - gameState: {gold, inventory, buildings, conveyors}
  - progression: {tier1Complete, tier2Unlocked, achievementsUnlocked}
  - lastSeen: timestamp (for offline production calculation)
```

**Firebase Analytics:**
- Automatic event tracking (app_open, session_start, etc.)
- Custom events (see FR-010)
- Audience segmentation (Tier 1 vs Tier 2 players)
- Funnel analysis (tutorial → Tier 1 → Tier 2 → retention)

**Cloud Functions (Optional):**
- Leaderboard calculation (top factories by efficiency)
- Daily rewards (cron job, +100 gold/day for returning players)
- Event triggers (Dragon Attack events every 6 hours)

**Firebase Crashlytics:**
- Automatic crash reporting
- Crash-free rate monitoring (target: >99%)
- Device/OS distribution analytics

**Estimated Costs:**
- **1k MAU:** Free tier sufficient
- **10k MAU:** ~$3/month (Firestore reads/writes)
- **100k MAU:** ~$45/month (still extremely low)
- **No server management:** Zero DevOps costs

---

**Status:** ✅ FR-009 Specification Complete
**Next:** FR-010 Analytics & Metrics Tracking

---

### FR-010: Analytics & Metrics Tracking (CRITICAL - P0)

**Description:** Analytics tracking measures critical success metrics (D7 retention, session length, Tier 2 unlock rate, crashes) to validate product-market fit. Without analytics, we fly blind. This is **non-negotiable** for data-driven iteration.

**Priority:** P0 (Blocker - Cannot launch without analytics)
**Dependencies:** FR-009 (Firebase Analytics)
**Estimated Complexity:** Low

---

#### Critical Metrics (MVP Launch)

**Retention Metrics:**
- **D1 Retention:** Target 45%+
- **D7 Retention:** Target 30-35% (CRITICAL - make-or-break metric)
- **D30 Retention:** Target 20%+
- Firebase event: `app_open` (automatic)

**Progression Metrics:**
- **Tier 2 Unlock Rate:** Target 60%+ of D7 retained users
- **Time to Tier 2:** Target 5 hours average
- Firebase event: `tier2_unlocked` with `time_to_unlock_minutes`

**Performance Metrics:**
- **Average FPS:** Target 60 FPS sustained
- **Crash Rate:** Target <1%
- **Load Time:** Target <3s cold start
- Firebase event: `performance_measured` with `avg_fps`, `crash_count`

**Economic Metrics:**
- **First Purchase:** How many days until first IAP?
- **Ad Watch Rate:** Target 60%+ (offline boost)
- **LTV:** Track lifetime value per cohort
- Firebase events: `purchase`, `ad_watched`

**Session Metrics:**
- **Session Length:** Average session duration
- **Sessions per Day:** How often players return
- **Daily Playtime:** Total minutes played per day
- Firebase event: `session_end` with `duration_minutes`

**Custom Events:**
```dart
// Key gameplay events
FirebaseAnalytics.logEvent('building_placed', {
  'building_type': 'lumbermill',
  'tier': 1,
});

FirebaseAnalytics.logEvent('building_upgraded', {
  'building_type': 'lumbermill',
  'level': 3,
});

FirebaseAnalytics.logEvent('conveyor_created', {
  'length': 12,
  'resource': 'wood',
});

FirebaseAnalytics.logEvent('market_sell', {
  'resource': 'wood',
  'amount': 50,
  'gold_earned': 250,
});

FirebaseAnalytics.logEvent('tier2_unlocked', {
  'time_to_unlock_minutes': 300, // 5 hours
});
```

**Dashboard Priorities:**
- **Week 1:** Focus on crashes, D1 retention, load times (stability)
- **Week 2-4:** Focus on D7 retention, Tier 2 unlock rate (engagement)
- **Month 2+:** Focus on LTV, ad revenue, IAP conversion (monetization)

---

**Status:** ✅ FR-010 Specification Complete

---

## PRD Completion Status

✅ **All 10 Functional Requirements Complete**

1. ✅ FR-001: Core Gameplay Loop (CRITICAL - P0)
2. ✅ FR-002: Tier 1 Economy System (HIGH - P1)
3. ✅ FR-003: Tier 2 Automation System (CRITICAL - P0)
4. ✅ FR-004: Offline Production System (HIGH - P1)
5. ✅ FR-005: Mobile-First UX (HIGH - P1)
6. ✅ FR-006: Progression System (HIGH - P1)
7. ✅ FR-007: Discovery-Based Tutorial (MEDIUM - P2)
8. ✅ FR-008: Ethical F2P Monetization (HIGH - P1)
9. ✅ FR-009: Firebase Backend (HIGH - P1)
10. ✅ FR-010: Analytics & Metrics Tracking (CRITICAL - P0)

**Next Steps:** Validate PRD → Create Epics & Stories → Begin Implementation
