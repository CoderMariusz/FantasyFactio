# Epic 8: Ethical F2P Monetization - Detailed Stories

<!-- AI-INDEX: epic, stories, acceptance-criteria, monetization, iap, ads -->

**Epic:** EPIC-08 - Ethical F2P Monetization
**Total Stories:** 7
**Total SP:** 23
**Sprint:** 8 (shared with EPIC-05)
**Status:** 📋 Ready for Implementation
**Tech-Spec:** [epic-08-tech-spec.md](epic-08-tech-spec.md)

**Prerequisites:**
- ✅ EPIC-00 (Firebase configured)
- ✅ EPIC-01 (Gold system exists)
- ✅ EPIC-02 (Economy foundations)
- ⚠️ EPIC-04 (Offline Production - for ad boost placement)

**Design Philosophy:** "Profitable without being predatory" - $10 lifetime cap, no loot boxes, no FOMO.

---

## Story Overview

| Story ID | Title | SP | Priority | Implementation Status |
|----------|-------|-----|----------|----------------------|
| STORY-08.1 | IAP Product Catalog & Domain | 2 | P0 | 📋 Ready |
| STORY-08.2 | Purchase Manager & Cap Enforcement | 4 | P0 | 📋 Ready |
| STORY-08.3 | Platform IAP Integration | 5 | P0 | 📋 Ready |
| STORY-08.4 | Receipt Validation & Cloud Functions | 4 | P0 | 📋 Ready |
| STORY-08.5 | Rewarded Video Ads | 3 | P1 | 📋 Ready |
| STORY-08.6 | Shop UI | 3 | P0 | 📋 Ready |
| STORY-08.7 | Analytics & Integration Testing | 2 | P1 | 📋 Ready |

---

## STORY-08.1: IAP Product Catalog & Domain (2 SP)

### Objective
Define all 5 IAP products with properties, purchase state model, and domain entities.

### User Story
As a developer, I need clearly defined IAP products and purchase state model so the monetization system has a solid foundation.

### Description
This story creates the domain layer for monetization: product definitions, purchase state tracking, and result types. All prices, gold amounts, and rules are defined here.

### Acceptance Criteria

#### AC1: IAPProduct Enum
```dart
✅ 5 products defined:
   - Starter Pack: $1.99, 1000 gold
   - Builder Pack: $2.99, 1750 gold
   - Factory Pack: $4.99, 3500 gold, isBestValue: true
   - Master Pack: $9.99, 8000 gold
   - Remove Ads: $0.99, 0 gold, isPermanent: true

✅ Each product has:
   - id: String (platform ID)
   - displayName: String
   - price: double
   - goldAmount: int
   - description: String
```

#### AC2: PurchaseState Model
```dart
✅ PurchaseState class:
   - totalSpent: double (lifetime, e.g., 6.50)
   - purchasedProducts: List<String> (product IDs)
   - adsRemoved: bool

✅ Methods:
   - canPurchase(product): bool
   - remainingBudget: double (10.0 - totalSpent)
   - capReached: bool
   - recordPurchase(product): PurchaseState
```

#### AC3: $10 Lifetime Cap Constant
```
✅ Static constant:
   static const double lifetimeCap = 10.0;

✅ Cap logic:
   - canPurchase returns false if (totalSpent + price) > 10.0
   - Cap applies to ALL products including Remove Ads
```

#### AC4: PurchaseResult Types
```dart
✅ Sealed class hierarchy:
   - PurchaseSuccess (product, transactionId, date)
   - PurchaseFailure (error, message)

✅ PurchaseError enum:
   - capReached
   - userCancelled
   - networkError
   - invalidReceipt
   - alreadyPurchased
   - platformError
```

#### AC5: Unit Tests Pass
```
✅ Test: All 5 products defined correctly
✅ Test: canPurchase true when under cap
✅ Test: canPurchase false when would exceed cap
✅ Test: recordPurchase updates totalSpent
✅ Test: remainingBudget calculates correctly
✅ Test: capReached true at $10.00
```

### Implementation Notes

**Files to Create:**
- `lib/domain/entities/iap_product.dart` - Product enum
- `lib/domain/entities/purchase_state.dart` - State model
- `lib/domain/entities/purchase_result.dart` - Result types
- `test/domain/entities/iap_product_test.dart` - Tests

**Gold per Dollar Calculation:**
```
Starter: 1000g / $1.99 = 502g/$
Builder: 1750g / $2.99 = 585g/$
Factory: 3500g / $4.99 = 701g/$ ← Best Value
Master:  8000g / $9.99 = 801g/$ ← Best overall
```

**Dependencies:**
- None (pure domain layer)

**Blocks:**
- STORY-08.2 (PurchaseManager uses these)

---

## STORY-08.2: Purchase Manager & Cap Enforcement (4 SP)

### Objective
Implement PurchaseManager that enforces $10 lifetime cap and orchestrates purchase flow.

### User Story
As a player, I want the game to prevent me from spending more than $10 so I'm protected from overspending.

### Description
PurchaseManager is the central orchestrator. It checks the cap, initiates platform purchases, validates receipts, grants rewards, and updates state.

### Acceptance Criteria

#### AC1: Cap Enforcement
```dart
✅ Before any purchase:
   - Check if (totalSpent + product.price) <= 10.0
   - If false: Return PurchaseFailure(capReached)
   - Log analytics: iap_purchase_blocked

✅ Edge cases:
   - Exactly $10.00 total: Allow last purchase
   - $9.99 + $0.02: Block (would be $10.01)
```

#### AC2: Purchase Flow Orchestration
```
✅ purchaseProduct() flow:
   1. Check lifetime cap
   2. Log iap_purchase_initiated
   3. Call platform IAP (Google/Apple)
   4. Validate receipt server-side
   5. Grant gold to player
   6. Update purchase state (Firestore)
   7. Log iap_purchase_completed
   8. Return PurchaseSuccess
```

#### AC3: Error Handling
```
✅ Handle all error cases:
   - Cap exceeded: Show cap message
   - User cancelled: Silent (expected)
   - Network error: Retry option
   - Invalid receipt: Fraud alert, no gold
   - Already purchased: Show message

✅ Graceful degradation:
   - Network issues: Retry with backoff
   - Platform errors: Clear error message
```

#### AC4: State Persistence
```
✅ Firestore integration:
   - Save to /users/{uid}/purchases
   - Fields: totalSpent, purchasedProducts, adsRemoved
   - Sync across devices

✅ Optimistic updates:
   - UI updates immediately
   - Background sync to Firestore
```

#### AC5: Unit Tests Pass
```
✅ Test: Cap blocks purchase correctly
✅ Test: Successful purchase updates state
✅ Test: Failed receipt validation returns error
✅ Test: State persists to Firestore
✅ Test: Analytics events logged
```

### Implementation Notes

**Files to Create:**
- `lib/domain/usecases/purchase_product_usecase.dart` - Use case
- `lib/domain/repositories/purchase_repository.dart` - Interface
- `lib/data/repositories/purchase_repository_impl.dart` - Implementation
- `test/domain/usecases/purchase_product_usecase_test.dart` - Tests

**Rate Limiting:**
```dart
// Max 10 purchase attempts per hour
static const maxAttemptsPerHour = 10;
```

**Dependencies:**
- STORY-08.1 (Domain entities)
- STORY-08.3 (Platform IAP)
- STORY-08.4 (Receipt validation)

**Blocks:**
- STORY-08.6 (Shop UI uses this)

---

## STORY-08.3: Platform IAP Integration (5 SP)

### Objective
Integrate Google Play Billing (Android) and Apple StoreKit (iOS) for real purchases.

### User Story
As a player, I want to make purchases through my device's app store so my payment is secure and familiar.

### Description
Platform integration uses the `in_app_purchase` Flutter package to abstract Google Play and Apple StoreKit. This handles product fetching, purchase flows, and pending transactions.

### Acceptance Criteria

#### AC1: Package Setup
```yaml
✅ pubspec.yaml:
   dependencies:
     in_app_purchase: ^3.1.11

✅ Platform configuration:
   - Android: Play Console products configured
   - iOS: App Store Connect products configured
   - Product IDs match domain definitions
```

#### AC2: Product Fetching
```dart
✅ IAPManager.getAvailableProducts():
   - Fetch from platform store
   - Return real prices (localized)
   - Handle unavailable products

✅ Product availability:
   - Check connection status
   - Handle store not available
```

#### AC3: Purchase Flow - Android
```
✅ Google Play Billing:
   - Dialog appears with product details
   - Payment method selection
   - Fingerprint/Face authentication
   - Transaction ID returned

✅ Error handling:
   - User cancelled: Normal flow
   - Payment failed: Show message
   - Pending: Handle on next launch
```

#### AC4: Purchase Flow - iOS
```
✅ Apple StoreKit:
   - Payment sheet appears
   - Face ID / Touch ID
   - Receipt returned

✅ Error handling:
   - User cancelled: Normal flow
   - Payment failed: Show message
   - Deferred (family sharing): Handle later
```

#### AC5: Pending Transactions
```
✅ Handle app restart during purchase:
   - Listen for pending transactions
   - Complete incomplete purchases
   - Don't double-charge

✅ purchaseStream:
   - Stream<PurchaseResult> for updates
   - Process on app launch
```

#### AC6: Unit Tests Pass
```
✅ Test: Products fetched correctly (mock)
✅ Test: Purchase initiates platform dialog
✅ Test: Success returns transaction ID
✅ Test: Cancellation handled gracefully
✅ Test: Pending transactions resumed
```

### Implementation Notes

**Files to Create:**
- `lib/data/services/iap_manager.dart` - Manager interface
- `lib/data/services/iap_manager_impl.dart` - Implementation
- `test/data/services/iap_manager_test.dart` - Tests

**Platform Detection:**
```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // Google Play Billing
} else if (Platform.isIOS) {
  // Apple StoreKit
}
```

**Dependencies:**
- in_app_purchase package
- Platform store configuration

**Blocks:**
- STORY-08.2 (PurchaseManager calls this)

---

## STORY-08.4: Receipt Validation & Cloud Functions (4 SP)

### Objective
Implement server-side receipt validation via Firebase Cloud Functions.

### User Story
As a developer, I need server-side validation to prevent fraud and ensure all purchases are legitimate.

### Description
Receipt validation MUST happen server-side. Cloud Functions verify receipts with Google Play API and Apple App Store API, then log transactions to Firestore.

### Acceptance Criteria

#### AC1: Cloud Function Setup
```javascript
✅ functions/src/validateReceipt.js:
   - HTTPS Callable function
   - Requires authentication
   - Parameters: platform, receiptData, productId

✅ Dependencies:
   - googleapis (Google Play API)
   - axios (Apple API)
   - firebase-admin (Firestore)
```

#### AC2: Google Play Validation
```
✅ Android receipt validation:
   - Call androidpublisher.purchases.products.get()
   - Check purchaseState === 0 (purchased)
   - Return isValid: true/false

✅ Service account:
   - Credentials stored in Cloud Functions config
   - Proper IAM permissions
```

#### AC3: Apple App Store Validation
```
✅ iOS receipt validation:
   - POST to https://buy.itunes.apple.com/verifyReceipt
   - Include shared secret
   - Check status === 0

✅ Sandbox testing:
   - Use sandbox URL for development
   - Switch to production for release
```

#### AC4: Transaction Logging
```
✅ Log to Firestore:
   - /users/{uid}/purchases/transactions
   - Fields: productId, platform, transactionId, validated, date

✅ Audit trail:
   - All attempts logged (valid and invalid)
   - Fraud detection data
```

#### AC5: Security
```
✅ Security measures:
   - Authenticated users only
   - Rate limiting: 10 attempts/hour
   - Duplicate receipt detection
   - Receipt data encrypted

✅ Firestore Security Rules:
   - Users can READ purchases
   - Only Cloud Functions can WRITE
```

#### AC6: Unit Tests Pass
```
✅ Test: Valid Android receipt returns true
✅ Test: Invalid receipt returns false
✅ Test: Transaction logged to Firestore
✅ Test: Duplicate receipt rejected
✅ Test: Rate limiting works
```

### Implementation Notes

**Files to Create:**
- `functions/src/validateReceipt.js` - Cloud Function
- `functions/src/index.js` - Export function
- `lib/data/services/receipt_validator.dart` - Client caller
- `test/data/services/receipt_validator_test.dart` - Tests

**Function Call from Flutter:**
```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('validateReceipt')
    .call({
      'platform': 'android',
      'receiptData': receiptToken,
      'productId': 'factory_pack',
    });
```

**Dependencies:**
- Firebase Cloud Functions
- Google Play Developer API credentials
- Apple shared secret

**Blocks:**
- STORY-08.2 (PurchaseManager calls validation)

---

## STORY-08.5: Rewarded Video Ads (3 SP)

### Objective
Integrate Google AdMob rewarded video ads with ethical principles.

### User Story
As a player, I want to optionally watch ads to earn bonuses so I can progress faster without paying.

### Description
Rewarded ads are optional, never forced. Two placements: offline production boost (2×) and speed boost. Daily cap of 6 ads. Ad failures still grant rewards (ethical principle).

### Acceptance Criteria

#### AC1: AdMob Integration
```dart
✅ google_mobile_ads package:
   - Initialize MobileAds.instance
   - Load rewarded video ads
   - Preload next ad after showing

✅ Ad unit configuration:
   - Test ad units for development
   - Production units for release
```

#### AC2: Ad Placements
```dart
✅ AdPlacement enum:
   - offlineBoost: 2× offline production
   - speedBoost: 2× speed for 10 minutes

✅ Each placement:
   - id, displayName, rewardType
   - rewardMultiplier (2.0)
   - rewardDuration (if applicable)
```

#### AC3: Daily Ad Cap
```
✅ Max 6 ads per day:
   - Track adsWatchedToday
   - Reset at midnight (local time)
   - If cap reached: Grant reward anyway!

✅ Persistence:
   - Save to Firestore /users/{uid}/adStats
   - Fields: totalAdsWatched, adsWatchedToday, lastAdDate
```

#### AC4: Ethical Fallbacks
```
✅ Ad not loaded:
   - Show message: "Ad not ready"
   - Grant reward anyway
   - Log: ad_not_available

✅ Ad failed to show:
   - Grant reward anyway
   - Log: ad_show_failed

✅ Remove Ads purchased:
   - Skip ads entirely
   - Grant rewards automatically
```

#### AC5: AdManager Implementation
```dart
✅ AdManager class:
   - initialize(): Load first ad
   - showRewardedAd(placement): Show and grant reward
   - preloadAd(): Load next ad
   - checkDailyCap(): Enforce 6/day

✅ AdWatchResult:
   - AdWatchSuccess (placement, watchedAt)
   - AdWatchFailure (error)
```

#### AC6: Unit Tests Pass
```
✅ Test: Ad loads successfully (mock)
✅ Test: Daily cap enforced at 6
✅ Test: Daily count resets at midnight
✅ Test: Ad failure grants reward
✅ Test: Remove Ads skips ad
```

### Implementation Notes

**Files to Create:**
- `lib/data/services/ad_manager.dart` - Manager
- `lib/domain/entities/ad_placement.dart` - Placements
- `lib/domain/entities/ad_watch_result.dart` - Results
- `test/data/services/ad_manager_test.dart` - Tests

**Ad Loading:**
```dart
RewardedAd.load(
  adUnitId: 'ca-app-pub-xxx/yyy',
  request: AdRequest(),
  rewardedAdLoadCallback: RewardedAdLoadCallback(
    onAdLoaded: (ad) => _rewardedAd = ad,
    onAdFailedToLoad: (error) => _handleLoadError(error),
  ),
);
```

**Dependencies:**
- google_mobile_ads package
- AdMob account configured

**Blocks:**
- EPIC-04 Welcome Back modal uses offline boost

---

## STORY-08.6: Shop UI (3 SP)

### Objective
Implement Shop screen with IAP product cards, progress bar, and purchase flow.

### User Story
As a player, I want a clear shop interface showing all purchase options and my spending progress so I can make informed decisions.

### Description
Shop UI displays 5 product cards, a $10 progress bar, and handles the purchase confirmation flow. Clear visual states for enabled/disabled products.

### Acceptance Criteria

#### AC1: Shop Screen Layout
```
✅ Screen structure:
   - Header: "Shop" title
   - Progress bar: "$X.XX / $10.00 spent"
   - Product cards: 5 cards in scrollable list
   - Footer: "Restore Purchases" button

✅ Navigation:
   - Accessible from Settings
   - Back button returns to previous screen
```

#### AC2: Product Cards
```
✅ Each card shows:
   - Product icon
   - Name (e.g., "Factory Pack")
   - Gold amount (e.g., "+3,500 gold")
   - Price (e.g., "$4.99")
   - "Buy" button
   - Description text

✅ Special badges:
   - "Best Value" on Factory Pack
   - "Purchased" checkmark if bought
```

#### AC3: Progress Bar
```
✅ Visual progress:
   - Shows current spending / $10.00
   - Green fill up to current amount
   - Text: "$6.50 / $10.00"

✅ Cap reached state:
   - Bar is full (green)
   - Text: "$10.00 / $10.00 - Thank you!"
   - Celebratory icon (trophy)
```

#### AC4: Disabled States
```
✅ Product disabled when:
   - Would exceed $10 cap
   - Already purchased (Remove Ads)

✅ Disabled visual:
   - Gray overlay
   - Text: "Would exceed cap"
   - Button disabled
```

#### AC5: Purchase Confirmation
```
✅ Confirmation dialog:
   - Product name and price
   - Gold amount
   - "Cancel" and "Confirm" buttons
   - Warning if close to cap

✅ After purchase:
   - Success animation (sparkles)
   - Gold counter increment
   - Progress bar updates
   - Haptic feedback
```

#### AC6: Unit Tests Pass
```
✅ Test: 5 product cards render
✅ Test: Progress bar shows correct amount
✅ Test: Disabled products grayed out
✅ Test: Confirmation dialog appears
✅ Test: Success animation plays
```

### Implementation Notes

**Files to Create:**
- `lib/presentation/screens/shop_screen.dart` - Main screen
- `lib/presentation/widgets/product_card.dart` - Product card
- `lib/presentation/widgets/spending_progress.dart` - Progress bar
- `lib/presentation/widgets/purchase_dialog.dart` - Confirmation
- `lib/presentation/providers/shop_provider.dart` - Riverpod
- `test/presentation/screens/shop_screen_test.dart` - Tests

**Layout Structure:**
```dart
Scaffold(
  appBar: AppBar(title: Text('Shop')),
  body: Column(
    children: [
      SpendingProgressBar(totalSpent: state.totalSpent),
      Expanded(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(product: products[i]),
        ),
      ),
      RestorePurchasesButton(),
    ],
  ),
)
```

**Dependencies:**
- STORY-08.1 (Product definitions)
- STORY-08.2 (PurchaseManager)

**Blocks:**
- Nothing (final UI layer)

---

## STORY-08.7: Analytics & Integration Testing (2 SP)

### Objective
Implement monetization analytics and validate complete purchase/ad flows.

### User Story
As a developer, I need analytics and testing to ensure monetization works correctly and I can track revenue.

### Description
This story adds Firebase Analytics events for all monetization actions and creates integration tests for critical flows.

### Acceptance Criteria

#### AC1: Purchase Analytics Events
```dart
✅ Events logged:
   - iap_purchase_initiated: When "Buy" tapped
   - iap_purchase_completed: After successful purchase
   - iap_purchase_blocked: Cap prevented purchase
   - iap_purchases_restored: After restore

✅ Parameters:
   - product_id, price, gold_amount
   - transaction_id (on success)
   - total_spent, reason (on block)
```

#### AC2: Ad Analytics Events
```dart
✅ Events logged:
   - ad_offered: When ad button shown
   - ad_watched: After completion
   - ad_failed: On error (with reason)
   - ad_skipped: User closed early

✅ Parameters:
   - placement, reward_type
   - reward_multiplier
   - error (if failed)
```

#### AC3: Revenue Dashboard
```
✅ Firebase Analytics shows:
   - Conversion rate (paying users / total)
   - ARPPU (revenue / paying users)
   - Ad adoption rate
   - Lifetime cap hit rate

✅ Funnel:
   - Shop opened → Product viewed → Purchase completed
```

#### AC4: Integration Tests
```
✅ Full purchase flow:
   - Open shop → Select product → Confirm → Verify gold

✅ Cap enforcement:
   - Spend $9.49 → Try $9.99 → Verify blocked

✅ Ad flow:
   - Show ad → Watch → Verify reward

✅ Restore flow:
   - Create purchases → New device → Restore
```

#### AC5: Performance Validation
```
✅ Response times:
   - Purchase initiation: <200ms
   - Receipt validation: <500ms
   - Shop screen load: <200ms

✅ Reliability:
   - 99%+ success rate for valid purchases
   - 0% double-charging
```

#### AC6: Tests Pass
```
✅ Test: Analytics events fire correctly
✅ Test: Full purchase flow E2E
✅ Test: Cap enforcement E2E
✅ Test: Ad flow E2E
✅ Test: Performance benchmarks pass
```

### Implementation Notes

**Files to Create:**
- `lib/data/services/analytics_service.dart` - Analytics wrapper
- `integration_test/purchase_flow_test.dart` - Purchase E2E
- `integration_test/ad_flow_test.dart` - Ad E2E
- `test/data/services/analytics_service_test.dart` - Unit tests

**Analytics Implementation:**
```dart
class AnalyticsService {
  static void logPurchaseCompleted({
    required String productId,
    required double price,
    required int goldAmount,
    required String transactionId,
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: 'iap_purchase_completed',
      parameters: {
        'product_id': productId,
        'price': price,
        'gold_amount': goldAmount,
        'transaction_id': transactionId,
      },
    );
  }
}
```

**Dependencies:**
- All STORY-08.x complete
- Firebase Analytics

**Blocks:**
- Epic sign-off

---

## Story Summary Table

| Story | SP | Focus | Dependencies |
|-------|----|----|------|
| **STORY-08.1** | 2 | IAP Products & Domain | None |
| **STORY-08.2** | 4 | Purchase Manager & Cap | 08.1 |
| **STORY-08.3** | 5 | Platform Integration | 08.1 |
| **STORY-08.4** | 4 | Cloud Functions | 08.3 |
| **STORY-08.5** | 3 | Rewarded Ads | None |
| **STORY-08.6** | 3 | Shop UI | 08.1, 08.2 |
| **STORY-08.7** | 2 | Analytics & Testing | 08.1-08.6 |
| **TOTAL** | **23 SP** | Ethical F2P Monetization | - |

---

## Implementation Order

**Recommended Sprint 8:**

**Week 1:** Backend & Core
1. STORY-08.1: IAP Products & Domain (2 SP)
2. STORY-08.3: Platform Integration (5 SP)
3. STORY-08.4: Cloud Functions (4 SP)
4. STORY-08.5: Rewarded Ads (3 SP)

**Week 2:** Frontend & Polish
5. STORY-08.2: Purchase Manager & Cap (4 SP)
6. STORY-08.6: Shop UI (3 SP)
7. STORY-08.7: Analytics & Testing (2 SP)

---

## Success Metrics

**After EPIC-08 Complete:**
- ✅ 5 IAP products purchasable
- ✅ $10 lifetime cap enforced
- ✅ Google Play + Apple StoreKit working
- ✅ Server-side receipt validation
- ✅ Rewarded ads with 6/day cap
- ✅ Shop UI polished
- ✅ Analytics tracking revenue

**Business Metrics Targets:**
- Conversion rate: 2%+
- ARPPU: $10 (most hit cap)
- Ad adoption: 60%+
- Year 1 revenue: $20-30k (at 10k downloads)

**Ethical Compliance:**
- ✅ No loot boxes
- ✅ No FOMO mechanics
- ✅ No pay-to-win
- ✅ Transparent pricing
- ✅ EU regulations compliant
- ✅ COPPA compliant

**When EPIC-08 Complete:**
- Overall Progress: ~57% (193/289 SP)
- Monetization ready for launch
- Revenue tracking in place
- Ethical differentiator established

---

**Document Status:** 📋 Ready for Development
**Last Updated:** 2025-12-03
**Version:** 1.0
**Next Review:** After STORY-08.1 complete
