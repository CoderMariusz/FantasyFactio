# Trade Factory Masters - Product Requirements Document

**Author:** Mariusz (CoderMariusz)
**Date:** 2025-11-17
**Version:** 1.0
**Status:** In Progress
**Product Brief:** docs/product-brief-trade-factory-masters-2025-11-17.md

---

## Executive Summary

**Trade Factory Masters** is a mobile factory automation game that fills a critical market gap: **desktop-quality automation for Factorio fans on mobile devices**. This PRD transforms the strategic vision (captured in Product Brief) into detailed, implementable requirements.

### Vision Alignment

3.5M+ Factorio players want a mobile version - but Factorio has no official mobile port planned. Mobile "factory builders" like Builderment (1.5M downloads) are too casual, simplifying mechanics for mass appeal. Trade Factory Masters proves that **mobile can handle mid-core complexity** by delivering Factorio-inspired depth optimized for touch controls and flexible session lengths (30s to 60min).

**Market Opportunity:** $135B mobile gaming industry + $400M SAM (factory automation + educational mobile games) with ZERO desktop-quality competitors on mobile.

### What Makes This Special

**"Factorio in 1 Tap"** - Progressive complexity unlock transforms automation into achievement:

1. **Conveyors are REWARDS, not starting features** - Players manually tap resources (Tier 1), creating desire for automation. Conveyors unlock at Tier 2 as achievement, triggering the "aha moment" that hooks players.

2. **Economic education through gameplay** - Supply/demand learned via events (dragon attacks drop wood supply → prices spike), not tutorials. Parents approve (68% prioritize educational value), players learn economics naturally.

3. **Ethical F2P ($10 complete game)** - Industry standard is $50-200 for "complete" F2P experience. TFM caps at $10 total, building trust and regulatory compliance (EU 2025 loot box laws favor transparency).

4. **Smart AI-assisted automation** - Player places START/END points, AI suggests optimal conveyor path (A* pathfinding), player confirms. Not tedious manual placement like desktop games.

5. **Offline production with O(1) calculation** - 1 week offline = 1ms calculation (not simulating every second). Respects player time, battery-friendly, differentiates from web idle games.

6. **Cross-platform ready** - Flutter/Flame native support: Mobile MVP → Desktop port in 3-4 weeks (85% code reuse validated in Technical Research).

---

## Project Classification

**Technical Type:** Mobile Game (Flutter/Flame)
**Domain:** Gaming - Factory Automation + Economics Education
**Complexity:** High (Mid-core game mechanics, mobile performance optimization, cross-platform)
**Target Platform:** Mobile-first (Android primary, iOS secondary), Desktop expansion (Month 6-7)
**Development Approach:** Solo indie, Enterprise BMAD Method (greenfield)

### Project Context

**Research Foundation:**
- Domain Research: 510 lines (mobile gaming industry 2025, ethical F2P movement, factory automation gap)
- Market Research: 677 lines (competitive analysis, revenue validation, Builderment competitor profile)
- Technical Research: 1,143 lines (Flutter/Flame 60 FPS validated, Firebase costs, Riverpod state management)
- Brainstorming: 6 technique sessions (Core Gameplay, Technical Challenges, MVP Scope, Retention, Monetization, Multiplayer)

**Key Validation:**
- ✅ Tech stack validated (60 FPS on Snapdragon 660 budget Android)
- ✅ Market gap confirmed (no desktop-quality automation on mobile)
- ✅ Firebase costs validated ($3/month for 10k users, $45/month for 100k)
- ✅ Revenue model validated ($20-30k Year 1 conservative, requires 35-40% D7 retention)

### Domain Context: Mobile Gaming (Mid-Core Segment)

**Industry Landscape (2025):**
- Mobile gaming market: $135B (growing 6.5% CAGR)
- Mid-core segment rising: 10 titles in top 200 grossing (vs 5 in 2023)
- Average D7 retention: 20% (mid-core), 40%+ (top performers)
- Industry LTV: $4-6 average, $10+ achievable with 40% D7 retention
- CPI (Cost Per Install): $2.03 mid-core vs $0.98 casual

**Regulatory Environment:**
- EU loot box regulations (2025) favor ethical F2P
- Brazil transparency laws favor upfront pricing
- COPPA compliance required (kids play mobile games: 73% US children <12 own device)

**Technical Constraints:**
- Budget device target: 60% of users on low-end Android (India, Africa markets)
- Performance expectation: 60 FPS standard, <3s load time, <1% crash rate
- Session length distribution: 40% short (30s-2min), 40% medium (5-10min), 20% long (30-60min)

**Monetization Standards:**
- Conversion rate: 2% industry standard (mid-core)
- ARPPU: $10-30 typical, $5-10 for ethical F2P
- Ad eCPM: $10-25 (US/EU markets)
- Rewarded video adoption: 60-80% of DAU willing to watch ads for rewards

---

## Success Criteria

### Critical Success Metrics (MVP Launch - First 30 Days)

**User Acquisition:**
- ✅ **10,000 organic downloads** (Reddit r/factorio + r/AndroidGaming + YouTube ASO)
  - **Measurement:** Google Play Console + App Store Connect download counts
  - **Target Breakdown:** 60% Android (6k), 40% iOS (4k)

**Retention (Make-or-Break Metric):**
- ✅ **D1 Retention: 45%+** (standard mid-core)
  - **Measurement:** Firebase Analytics cohort analysis
  - **Benchmark:** Industry mid-core average is 45%

- ✅ **D7 Retention: 30-35%** (minimum viable, target 35-40%)
  - **Measurement:** Firebase Analytics 7-day cohort retention
  - **Benchmark:** 20% industry average, 40% top 10% performers
  - **Critical:** <30% D7 = core loop problem, DO NOT scale marketing

- ✅ **D30 Retention: 20%+**
  - **Measurement:** Firebase Analytics 30-day cohort
  - **Benchmark:** 10% industry average

**Performance:**
- ✅ **60 FPS on budget Android** (Snapdragon 660 benchmark device)
  - **Measurement:** Flame performance overlay, real device testing
  - **Acceptance:** 60 FPS sustained with 50 conveyors + 10 buildings + 20 moving resources
  - **Failure Condition:** <45 FPS = performance optimization required before launch

**Stability:**
- ✅ **Crash rate: <1%** (industry standard)
  - **Measurement:** Firebase Crashlytics
  - **Acceptance:** <1% crash-free sessions

- ✅ **Load time: <3 seconds** (cold start)
  - **Measurement:** Firebase Performance Monitoring
  - **Benchmark:** 53% of users abandon if >3s load time

**Player Progression:**
- ✅ **Tier 2 unlock rate: 60%+** (players reaching automation "aha moment")
  - **Measurement:** Firebase Analytics custom event tracking
  - **Critical:** Tier 2 = conveyor unlock = automation value demonstrated
  - **Failure:** <50% = Tier 1 too boring OR too hard, onboarding broken

**Ratings:**
- ✅ **4.0+ star rating** (App Store + Google Play average)
  - **Measurement:** Store dashboards
  - **Target:** 4.2+ optimal, 4.0+ acceptable, <3.8 = critical issues

### Business Metrics

**Revenue Targets (Conservative - 10k downloads, 35% D7):**
- **Year 1 Total: $20-30k** (realistic range)
  - Ad revenue: $18k/year (60% ad watch rate, $20 eCPM, US/EU focus)
  - IAP revenue: $8k/year (2% conversion, $10 ARPPU)
- **LTV Target:** $2-3 (if D7=35%), $10+ (if D7=40%)
- **Break-Even:** 5,000 downloads with 30% D7 = ~$10k revenue (covers $500-1k costs)

**Conversion Metrics:**
- **Conversion Rate: 2%+** (industry standard)
  - **Measurement:** Firebase Analytics purchase events / DAU
  - **Failure:** <1% = pricing issue, value proposition unclear

- **Ad Watch Rate: 60%+** (rewarded video engagement)
  - **Measurement:** Ad impressions / DAU
  - **Target:** 80%+ optimal (2x offline production incentive)

**Cost Metrics:**
- **Firebase Costs: <$50/month** (even at 100k MAU)
  - **Measurement:** Firebase Console billing
  - **Alert:** Set billing alert at $20/month threshold

- **CAC (Cost of Acquisition): $0** (organic only in MVP)
  - Optional: Google Ads test ($100-500 budget post-launch if metrics hit)

### Growth Indicators (Month 2-6)

- **Download Growth: 10-20%/month** (organic word-of-mouth + ASO optimization)
- **D7 Retention Improvement: +5%** (from onboarding iteration based on analytics)
- **Featured Placement:** Google Play or App Store editorial (aspirational accelerator)
- **Community Formation:** Discord server, Reddit presence, YouTube coverage

### Long-Term Success (Year 1)

- **100k downloads** (viral/featured scenario)
- **D7 Retention: 40%+** (top tier, drives $200k+ revenue)
- **Desktop Port Launched** (Month 6-7, cross-platform cloud saves)
- **Active Community:** Discord 1k+ members, r/TradeFactoryMasters subreddit

---

## Product Scope

### MVP - Minimum Viable Product (Tier 1-2 ONLY, 0-7 hours gameplay)

**Ruthless Scope Decision:** Tier 1-2 only (reduces development by 60% vs full Tier 1-4). Prove core loop works FIRST, monetize Tier 3-4 as paid DLC ($2.99) post-launch.

**Core MVP Features (10 Must-Haves):**

1. **3-Step Core Gameplay Loop** (CRITICAL)
2. **Tier 1 Economy System** (0-5h content)
3. **Tier 2 Automation System** (5-7h, conveyor unlock)
4. **Offline Production System** (O(1) calculation)
5. **Mobile-First UX** (one-handed, 60 FPS)
6. **Progression System** (Tier 1 → Tier 2 unlocks)
7. **Discovery-Based Tutorial** (no text, learn by events)
8. **Ethical F2P Monetization** ($10 cap, ads optional)
9. **Firebase Backend** (auth, cloud saves, leaderboards)
10. **Analytics & Metrics Tracking** (D7, session length, crashes)

### Growth Features (Post-MVP Updates)

**Update 1.1 (Month 2) - Polish & Balance:**
- Performance optimizations (based on analytics)
- Balance tweaks (building costs, prices, progression pacing)
- Bug fixes, crash resolution
- QoL improvements (UI feedback, tooltips, settings)

**Update 1.2 (Month 3) - Social Features:**
- Leaderboards expansion (regional, friend-based)
- Basic guilds (join, chat, shared goals)
- Friend codes (invite system)
- Blueprint sharing (export/import factory layouts)

**Update 1.3 (Month 4) - Tier 3 DLC:**
- **Paid DLC: $2.99** unlocks Tier 3 content (15-30h gameplay)
- 8 new buildings, 3 new resources
- Manual optimization mechanics
- Full dynamic economy

### Vision Features (Year 2+)

**Update 2.0 (Month 6) - Desktop Port:**
- Windows/Mac/Linux version (Flutter native cross-platform)
- Cross-platform cloud saves (play on mobile, continue on desktop)
- Mouse + keyboard controls optimized
- Same codebase (85% code reuse)
- Premium pricing option: $9.99 desktop standalone

**Update 2.1 (Month 7) - Competitive Features:**
- Ranked seasons (monthly leaderboards, reset every 30 days)
- Guild competitions (team efficiency challenges)
- Spectator mode (watch top factories in real-time)
- Rewards (cosmetics, titles, badges)

**Year 2+ Vision:**
- **Tier 4 Endgame:** Player market, advanced automation, guild projects
- **Modding Support:** Custom buildings via JSON config files
- **Cross-Platform Multiplayer:** Shared factories (mobile + desktop players together)
- **Educational Partnerships:** Schools, economics courses integration
- **Localization:** 10+ languages (EU: German/French/Spanish, Asia: Chinese/Japanese/Korean)

---

## Functional Requirements

