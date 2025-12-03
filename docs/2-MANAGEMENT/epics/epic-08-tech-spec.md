# Epic 8: Ethical F2P Monetization - Technical Specification

<!-- AI-INDEX: epic, tech-spec, monetization, iap, ads, ethical-f2p -->

**Epic:** EPIC-08 - Ethical F2P Monetization
**Total SP:** 23
**Duration:** 1-2 weeks (Sprint 8, shared with EPIC-05)
**Status:** 📋 Ready for Implementation
**Date:** 2025-12-03
**Priority:** P1 (High)

---

## Overview

EPIC-08 implementuje etyczny system monetyzacji Free-to-Play z jasno określonym limitem $10 lifetime cap, opcjonalnymi rewarded video ads, oraz transparentnym pricingiem. Epic ten realizuje kluczową zasadę projektową Trade Factory Masters: **"profitable without being predatory"** - gra może generować przychody bez wykorzystywania psychologicznych manipulacji graczy.

System monetyzacji został zaprojektowany aby:
- **Chronić graczy**: $10 lifetime cap zapobiega nadmiernym wydatkom
- **Być transparentnym**: Wszystkie ceny widoczne z góry, brak ukrytych kosztów
- **Szanować czas graczy**: Reklamy są opcjonalne, nigdy nie wymuszane
- **Zapewnić wartość**: Każda transakcja oferuje fair value proposition
- **Być etycznym**: Brak loot boxes, FOMO events, pay-to-win mechanics

Kluczowe cele finansowe:
- **2%+ conversion rate** (industry standard dla mid-core mobile)
- **$10 ARPPU** (Average Revenue Per Paying User)
- **60%+ ad adoption rate** (rewarded video engagement)
- **$20-30k Year 1 revenue** (przy 10k downloads, 35% D7 retention)

System jest zgodny z EU regulations (brak loot boxes), COPPA compliance (child-safe), oraz reprezentuje differentiator dla TFM na rynku mobile games często krytykowanych za predatory monetization.

## Objectives and Scope

### In Scope

**In-App Purchase (IAP) System:**
- ✅ 5 IAP products z różnymi price points
  - Starter Pack: $1.99 (1000 gold)
  - Builder Pack: $2.99 (1750 gold)
  - Factory Pack: $4.99 (3500 gold)
  - Master Pack: $9.99 (8000 gold)
  - Remove Ads: $0.99 (permanent ad removal)
- ✅ $10.00 lifetime spending cap (hard limit)
- ✅ Google Play Billing Library 5.0 integration (Android)
- ✅ Apple StoreKit 2 integration (iOS)
- ✅ Purchase restoration across devices
- ✅ Receipt validation via Cloud Functions (fraud prevention)

**Rewarded Video Ads:**
- ✅ Google AdMob integration (30-second rewarded videos)
- ✅ Ad placements:
  - Welcome Back modal (2× offline production boost)
  - Speed Boost (2× production speed for 10 minutes)
- ✅ Ad frequency cap: Max 6 ads/day (prevents ad fatigue)
- ✅ Ethical fallback: Ad failure → reward granted anyway
- ✅ Optional only: Never forced, always skippable

**Shop UI:**
- ✅ Dedicated Shop screen with 5 IAP product cards
- ✅ Progress bar: "$X.XX / $10.00 spent"
- ✅ "Best Value" badge on Factory Pack ($4.99)
- ✅ Disabled state when $10 cap reached
- ✅ Purchase confirmation dialog
- ✅ Success/error feedback animations

**Analytics & Tracking:**
- ✅ Firebase Analytics integration
- ✅ Custom events: `iap_purchase_initiated`, `iap_purchase_completed`, `ad_watched`
- ✅ Revenue tracking: Conversion rate, ARPPU, ad adoption
- ✅ Funnel analysis: Shop opened → Purchase completed
- ✅ Cohort analysis: Paying vs non-paying users

**Security & Compliance:**
- ✅ Server-side receipt validation (Cloud Functions)
- ✅ Fraud detection (duplicate receipt prevention)
- ✅ Transaction logging in Firestore
- ✅ EU regulatory compliance (no loot boxes)
- ✅ COPPA compliance (child-safe monetization)
- ✅ Age-appropriate (PEGI 3 / ESRB E for Everyone)

### Out of Scope

- ❌ Subscription tiers - nie planowane
- ❌ Season passes - przeciwne do ethical F2P principles
- ❌ Loot boxes / gacha mechanics - zabronione przez EU regulations
- ❌ Limited-time FOMO events - predatory mechanic
- ❌ Energy/stamina system - frustrujące dla graczy
- ❌ Pay-to-win multiplayer - brak PvP w TFM
- ❌ Dynamic pricing - ceny są stałe, transparentne
- ❌ Multiple currencies - tylko gold, prosty system

## System Architecture Alignment

EPIC-08 integruje się z Clean Architecture oraz zewnętrznymi payment platforms:

**Domain Layer (Business Logic):**
- `IAPProduct` enum - definicje 5 produktów IAP
- `PurchaseManager` - zarządza lifetime cap, purchase state
- `AdManager` - zarządza rewarded video ads
- `ValidatePurchaseUseCase` - walidacja zakupów

**Data Layer (Persistence & External APIs):**
- Firestore schema: `/users/{userId}/purchases` (totalSpent, products purchased)
- Google Play Billing Library 5.0 (Android purchases)
- Apple StoreKit 2 (iOS purchases)
- Cloud Functions: `validateReceipt` (server-side verification)

**Presentation Layer (UI):**
- `ShopScreen` - główny ekran Shop z IAP cards
- `PurchaseConfirmationDialog` - modal potwierdzenia zakupu
- `AdRewardModal` - wyświetla rewarded video ad offer
- Riverpod providers: `PurchaseProvider`, `AdProvider`

**External Integrations:**
- **Google Play Billing**: Komunikacja z Google Play Store
- **Apple StoreKit**: Komunikacja z Apple App Store
- **Google AdMob**: Rewarded video ad serving
- **Firebase Analytics**: Revenue tracking, conversion funnels
- **Cloud Functions**: Receipt validation, fraud prevention

**Security Architecture:**
- Receipt validation ZAWSZE po stronie serwera (Cloud Functions)
- Firestore Security Rules: prevent direct purchase manipulation
- Transaction logging dla audit trail
- Rate limiting: max 10 purchase attempts per hour (fraud prevention)

## Detailed Design

### Services and Modules

| Moduł | Odpowiedzialność | Input | Output | Owner |
|-------|------------------|-------|--------|-------|
| **IAPManager** | Zarządza in-app purchases | Product ID, platform | Purchase result | Data |
| **PurchaseManager** | Enforces $10 lifetime cap | Total spent, new price | Can purchase? | Domain |
| **ReceiptValidator** | Server-side validation | Receipt data, platform | Valid/Invalid | Cloud Functions |
| **AdManager** | Rewarded video ads | Ad placement | Ad watched result | Data |
| **ShopProvider** | Shop UI state management | IAP products | ShopState | Presentation |
| **AnalyticsService** | Monetization tracking | Event name, parameters | void | Data |
| **GooglePlayService** | Android IAP implementation | Product ID | Purchase result | Data (Platform) |
| **AppStoreService** | iOS IAP implementation | Product ID | Purchase result | Data (Platform) |
| **PurchaseRestoration** | Restore past purchases | User ID | Restored purchases | Data |

### Data Models and Contracts

**IAPProduct Enum (Domain):**
```dart
enum IAPProduct {
  starterPack(
    id: 'starter_pack',
    displayName: 'Starter Pack',
    price: 1.99,
    goldAmount: 1000,
    description: 'Perfect for getting started',
  ),
  builderPack(
    id: 'builder_pack',
    displayName: 'Builder Pack',
    price: 2.99,
    goldAmount: 1750,
    description: 'More resources to build faster',
  ),
  factoryPack(
    id: 'factory_pack',
    displayName: 'Factory Pack',
    price: 4.99,
    goldAmount: 3500,
    description: 'Best value! Build your empire',
    isBestValue: true,
  ),
  masterPack(
    id: 'master_pack',
    displayName: 'Master Pack',
    price: 9.99,
    goldAmount: 8000,
    description: 'Ultimate boost for factory masters',
  ),
  removeAds(
    id: 'remove_ads',
    displayName: 'Remove Ads',
    price: 0.99,
    goldAmount: 0,
    description: 'Permanent ad removal',
    isPermanent: true,
  );

  final String id;
  final String displayName;
  final double price;
  final int goldAmount;
  final String description;
  final bool isBestValue;
  final bool isPermanent;

  const IAPProduct({
    required this.id,
    required this.displayName,
    required this.price,
    required this.goldAmount,
    required this.description,
    this.isBestValue = false,
    this.isPermanent = false,
  });
}
```

**PurchaseState (Domain):**
```dart
class PurchaseState {
  final double totalSpent;              // Lifetime spending (e.g., 6.50)
  final List<String> purchasedProducts; // Product IDs purchased
  final bool adsRemoved;                // Remove Ads purchased?

  static const double lifetimeCap = 10.0;

  bool canPurchase(IAPProduct product) {
    // Check if would exceed lifetime cap
    return (totalSpent + product.price) <= lifetimeCap;
  }

  double get remainingBudget => lifetimeCap - totalSpent;

  bool get capReached => totalSpent >= lifetimeCap;

  PurchaseState recordPurchase(IAPProduct product) {
    return PurchaseState(
      totalSpent: totalSpent + product.price,
      purchasedProducts: [...purchasedProducts, product.id],
      adsRemoved: adsRemoved || product == IAPProduct.removeAds,
    );
  }
}
```

**PurchaseResult (Domain):**
```dart
sealed class PurchaseResult {
  const PurchaseResult();
}

class PurchaseSuccess extends PurchaseResult {
  final IAPProduct product;
  final String transactionId;
  final DateTime purchaseDate;

  const PurchaseSuccess({
    required this.product,
    required this.transactionId,
    required this.purchaseDate,
  });
}

class PurchaseFailure extends PurchaseResult {
  final PurchaseError error;
  final String? message;

  const PurchaseFailure({required this.error, this.message});
}

enum PurchaseError {
  capReached,           // $10 limit exceeded
  userCancelled,        // User tapped "Cancel" in platform dialog
  networkError,         // No internet connection
  invalidReceipt,       // Receipt validation failed (fraud attempt)
  alreadyPurchased,     // Product already owned (Remove Ads)
  platformError,        // Google Play / App Store error
}
```

**AdPlacement Enum:**
```dart
enum AdPlacement {
  offlineBoost(
    id: 'offline_boost',
    displayName: 'Offline Production Boost',
    rewardType: '2× offline production',
    rewardMultiplier: 2.0,
  ),
  speedBoost(
    id: 'speed_boost',
    displayName: 'Speed Boost',
    rewardType: '2× production speed for 10 min',
    rewardMultiplier: 2.0,
    rewardDuration: Duration(minutes: 10),
  );

  final String id;
  final String displayName;
  final String rewardType;
  final double rewardMultiplier;
  final Duration? rewardDuration;

  const AdPlacement({
    required this.id,
    required this.displayName,
    required this.rewardType,
    required this.rewardMultiplier,
    this.rewardDuration,
  });
}
```

**AdWatchResult:**
```dart
sealed class AdWatchResult {
  const AdWatchResult();
}

class AdWatchSuccess extends AdWatchResult {
  final AdPlacement placement;
  final DateTime watchedAt;

  const AdWatchSuccess({required this.placement, required this.watchedAt});
}

class AdWatchFailure extends AdWatchResult {
  final AdError error;

  const AdWatchFailure({required this.error});
}

enum AdError {
  notLoaded,          // Ad not ready (network issue)
  dailyCapReached,    // Max 6 ads/day reached
  userClosed,         // User closed ad before completion
  adRemovalPurchased, // User bought Remove Ads
}
```

**Firestore Schema - Purchases Collection:**
```dart
// /users/{userId}/purchases
@JsonSerializable()
class PurchaseModel {
  final double totalSpent;                  // e.g., 6.50
  final List<String> purchasedProducts;     // ['starter_pack', 'factory_pack']
  final bool adsRemoved;                    // Remove Ads purchased?
  final Map<String, PurchaseTransaction> transactions; // Audit trail

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastPurchaseDate;
}

@JsonSerializable()
class PurchaseTransaction {
  final String productId;
  final double price;
  final String transactionId;      // Google/Apple transaction ID
  final String platform;           // 'android' | 'ios'
  final String receiptData;        // Encrypted receipt
  final bool validated;            // Server-side validation passed?

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime purchaseDate;
}
```

**Firestore Schema - Ad Stats Collection:**
```dart
// /users/{userId}/adStats
@JsonSerializable()
class AdStatsModel {
  final int totalAdsWatched;               // Lifetime ad count
  final int adsWatchedToday;               // Today's count (resets daily)

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastAdDate;               // For daily reset logic

  final Map<String, int> adsByPlacement;   // {'offline_boost': 10, 'speed_boost': 5}
}
```

### APIs and Interfaces

**IAPManager Interface (Data Layer):**
```dart
abstract class IAPManager {
  /// Initialize platform billing (Google Play / App Store)
  Future<void> initialize();

  /// Fetch available products from platform store
  Future<List<IAPProduct>> getAvailableProducts();

  /// Purchase a product (triggers platform payment flow)
  Future<PurchaseResult> purchase(IAPProduct product);

  /// Restore past purchases (for device migration)
  Future<List<IAPProduct>> restorePurchases();

  /// Listen for pending transactions (app was closed during purchase)
  Stream<PurchaseResult> get purchaseStream;
}
```

**PurchaseManager (Domain):**
```dart
class PurchaseManager {
  final IAPManager _iapManager;
  final ReceiptValidator _validator;
  final AnalyticsService _analytics;

  Future<PurchaseResult> purchaseProduct(
    PurchaseState currentState,
    IAPProduct product,
  ) async {
    // 1. Check lifetime cap
    if (!currentState.canPurchase(product)) {
      _analytics.logEvent('iap_purchase_blocked', {
        'reason': 'cap_reached',
        'product_id': product.id,
        'total_spent': currentState.totalSpent,
      });
      return PurchaseFailure(error: PurchaseError.capReached);
    }

    // 2. Log purchase initiation
    _analytics.logEvent('iap_purchase_initiated', {
      'product_id': product.id,
      'price': product.price,
      'gold_amount': product.goldAmount,
    });

    // 3. Trigger platform purchase flow
    final result = await _iapManager.purchase(product);

    // 4. Validate receipt server-side
    if (result is PurchaseSuccess) {
      final validated = await _validator.validateReceipt(
        receiptData: result.transactionId,
        platform: Platform.isAndroid ? 'android' : 'ios',
        productId: product.id,
      );

      if (!validated) {
        _analytics.logEvent('iap_purchase_fraud_detected', {
          'product_id': product.id,
          'transaction_id': result.transactionId,
        });
        return PurchaseFailure(error: PurchaseError.invalidReceipt);
      }

      // 5. Grant gold reward
      await _grantGold(product.goldAmount);

      // 6. Update purchase state (Firestore)
      await _updatePurchaseState(currentState.recordPurchase(product));

      // 7. Log successful purchase
      _analytics.logEvent('iap_purchase_completed', {
        'product_id': product.id,
        'price': product.price,
        'gold_amount': product.goldAmount,
        'transaction_id': result.transactionId,
        'total_spent': currentState.totalSpent + product.price,
      });

      return result;
    }

    return result; // PurchaseFailure
  }

  Future<void> restorePurchases() async {
    final restored = await _iapManager.restorePurchases();

    double totalSpent = 0.0;
    final purchasedProducts = <String>[];

    for (final product in restored) {
      totalSpent += product.price;
      purchasedProducts.add(product.id);
    }

    await _updatePurchaseState(PurchaseState(
      totalSpent: totalSpent,
      purchasedProducts: purchasedProducts,
      adsRemoved: purchasedProducts.contains(IAPProduct.removeAds.id),
    ));

    _analytics.logEvent('iap_purchases_restored', {
      'products_count': restored.length,
      'total_spent': totalSpent,
    });
  }
}
```

**AdManager (Data Layer):**
```dart
class AdManager {
  RewardedAd? _rewardedAd;
  AdStatsModel _stats = AdStatsModel(/* ... */);

  static const int maxAdsPerDay = 6;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _preloadAd();
    _loadAdStats(); // Load from Firestore
  }

  Future<AdWatchResult> showRewardedAd(AdPlacement placement) async {
    // 1. Check if Remove Ads purchased
    final purchaseState = await _getPurchaseState();
    if (purchaseState.adsRemoved) {
      return AdWatchFailure(error: AdError.adRemovalPurchased);
    }

    // 2. Check daily ad cap
    _resetDailyCountIfNeeded();
    if (_stats.adsWatchedToday >= maxAdsPerDay) {
      _showMessage('Daily ad limit reached. Reward granted anyway!');
      return AdWatchSuccess(placement: placement, watchedAt: DateTime.now());
    }

    // 3. Check if ad loaded
    if (_rewardedAd == null) {
      _showMessage('Ad not ready. Reward granted anyway!');
      return AdWatchSuccess(placement: placement, watchedAt: DateTime.now());
    }

    // 4. Show ad
    final completer = Completer<AdWatchResult>();

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _stats = _stats.copyWith(
          totalAdsWatched: _stats.totalAdsWatched + 1,
          adsWatchedToday: _stats.adsWatchedToday + 1,
          lastAdDate: DateTime.now(),
        );
        _saveAdStats(); // Persist to Firestore
        _preloadAd();   // Load next ad

        _analytics.logEvent('ad_watched', {
          'placement': placement.id,
          'reward_type': placement.rewardType,
          'reward_multiplier': placement.rewardMultiplier,
        });

        completer.complete(AdWatchSuccess(
          placement: placement,
          watchedAt: DateTime.now(),
        ));
      },
      onAdDismissedFullScreenContent: (ad) {
        if (!completer.isCompleted) {
          completer.complete(AdWatchFailure(error: AdError.userClosed));
        }
      },
    );

    return completer.future;
  }

  void _resetDailyCountIfNeeded() {
    final now = DateTime.now();
    final lastAd = _stats.lastAdDate;

    // Reset if different day
    if (now.day != lastAd.day || now.month != lastAd.month || now.year != lastAd.year) {
      _stats = _stats.copyWith(adsWatchedToday: 0);
    }
  }
}
```

**Cloud Function: Receipt Validation:**
```javascript
// functions/src/validateReceipt.js
const functions = require('firebase-functions');
const { google } = require('googleapis');
const axios = require('axios');

exports.validateReceipt = functions.https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { platform, receiptData, productId } = data;

  try {
    if (platform === 'android') {
      // Google Play Developer API validation
      const androidPublisher = google.androidpublisher('v3');

      const result = await androidPublisher.purchases.products.get({
        packageName: 'com.fantasyfactio.tfm',
        productId: productId,
        token: receiptData,
        auth: getGoogleAuthClient(), // Service account credentials
      });

      // Check purchase state (0 = purchased, 1 = cancelled)
      const isValid = result.data.purchaseState === 0;

      if (isValid) {
        // Log transaction to Firestore
        await logPurchaseTransaction(context.auth.uid, {
          productId,
          platform: 'android',
          transactionId: receiptData,
          validated: true,
          purchaseDate: new Date(parseInt(result.data.purchaseTimeMillis)),
        });
      }

      return { isValid, purchaseData: result.data };

    } else if (platform === 'ios') {
      // Apple App Store receipt validation
      const response = await axios.post(
        'https://buy.itunes.apple.com/verifyReceipt', // Production
        {
          'receipt-data': receiptData,
          'password': functions.config().apple.shared_secret,
        }
      );

      const isValid = response.data.status === 0;

      if (isValid) {
        const receipt = response.data.receipt.in_app[0];

        await logPurchaseTransaction(context.auth.uid, {
          productId,
          platform: 'ios',
          transactionId: receipt.transaction_id,
          validated: true,
          purchaseDate: new Date(parseInt(receipt.purchase_date_ms)),
        });
      }

      return { isValid, receiptData: response.data };

    } else {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid platform');
    }

  } catch (error) {
    console.error('Receipt validation error:', error);
    throw new functions.https.HttpsError('internal', 'Receipt validation failed');
  }
});

async function logPurchaseTransaction(userId, transaction) {
  const admin = require('firebase-admin');
  const db = admin.firestore();

  await db
    .collection('users')
    .doc(userId)
    .collection('purchases')
    .doc('transactions')
    .set({
      [transaction.transactionId]: transaction,
    }, { merge: true });
}
```

**ShopProvider (Riverpod):**
```dart
@riverpod
class Shop extends _$Shop {
  @override
  Future<ShopState> build() async {
    final purchaseState = await _loadPurchaseState();
    final products = IAPProduct.values;

    return ShopState(
      products: products,
      purchaseState: purchaseState,
    );
  }

  Future<void> purchaseProduct(IAPProduct product) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final purchaseManager = ref.read(purchaseManagerProvider);

      final result = await purchaseManager.purchaseProduct(
        currentState.purchaseState,
        product,
      );

      if (result is PurchaseSuccess) {
        // Update UI with new purchase state
        final newPurchaseState = currentState.purchaseState.recordPurchase(product);

        // Show success feedback
        _showSuccessDialog(product);

        return currentState.copyWith(purchaseState: newPurchaseState);
      } else {
        // Handle error
        _showErrorDialog((result as PurchaseFailure).error);
        return currentState;
      }
    });
  }

  Future<void> restorePurchases() async {
    final purchaseManager = ref.read(purchaseManagerProvider);
    await purchaseManager.restorePurchases();

    // Reload state
    state = AsyncValue.data(await build());
  }
}

class ShopState {
  final List<IAPProduct> products;
  final PurchaseState purchaseState;

  ShopState({required this.products, required this.purchaseState});

  ShopState copyWith({
    List<IAPProduct>? products,
    PurchaseState? purchaseState,
  }) {
    return ShopState(
      products: products ?? this.products,
      purchaseState: purchaseState ?? this.purchaseState,
    );
  }
}
```

### Workflows and Sequencing

**Sequence: Player Purchases IAP Product**
```
1. User opens Shop screen (taps "Shop" in Settings)
   ↓
2. ShopScreen displays 5 IAP product cards
   ↓
3. Progress bar shows: "$6.50 / $10.00 spent"
   ↓
4. User taps "Buy" button on Factory Pack ($4.99)
   ↓
5. PurchaseConfirmationDialog appears
   - Shows: Product name, gold amount, price
   - Buttons: "Cancel" | "Confirm Purchase"
   ↓
6. User taps "Confirm Purchase"
   ↓
7. ShopProvider.purchaseProduct(factoryPack) called
   ↓
8. PurchaseManager checks lifetime cap:
   - Current: $6.50, New: $4.99, Total: $11.49
   - Exceeds $10.00 cap → BLOCKED
   ↓
9. Error dialog appears: "Purchase would exceed $10 cap"
   - Suggests buying smaller pack (e.g., Builder Pack $2.99)
   ↓
10. User selects Builder Pack ($2.99) instead
    ↓
11. Cap check passes: $6.50 + $2.99 = $9.49 < $10.00 ✓
    ↓
12. Analytics: logEvent('iap_purchase_initiated', {product_id, price})
    ↓
13. Platform billing triggered:
    - Android: Google Play Billing dialog appears
    - iOS: Apple StoreKit payment sheet appears
    ↓
14. User confirms purchase via platform (Face ID / Fingerprint)
    ↓
15. Platform processes payment → returns transaction ID
    ↓
16. Cloud Function: validateReceipt(receiptData, platform, productId)
    ↓
17. Google Play API / App Store API validates receipt → isValid = true
    ↓
18. Cloud Function logs transaction to Firestore
    ↓
19. PurchaseManager grants 1750 gold to player
    ↓
20. Firestore: totalSpent updated to $9.49
    ↓
21. UI updates:
    - Progress bar: "$9.49 / $10.00 spent"
    - Gold counter animates: +1750 gold
    - Success dialog: "Purchase successful! +1750 gold"
    ↓
22. Haptic feedback (medium impact)
    ↓
23. Celebration animation (sparkles around gold counter)
    ↓
24. Analytics: logEvent('iap_purchase_completed', {product_id, price, revenue})
    ↓
25. Background: Sync to Firestore (don't wait)
```

**Sequence: Player Watches Rewarded Ad (Offline Boost)**
```
1. Player returns after 3 hours offline
   ↓
2. Welcome Back modal appears with offline production summary
   - Wood: +180, Ore: +150, Gold: +450
   ↓
3. Modal shows ad offer:
   - "Watch ad for 2× offline production?"
   - Buttons: "No Thanks" | "Watch Ad (30s)"
   ↓
4. User taps "Watch Ad (30s)" button
   ↓
5. AdManager.showRewardedAd(AdPlacement.offlineBoost) called
   ↓
6. Check Remove Ads status:
   - If purchased → skip ad, grant reward anyway
   - If not purchased → continue
   ↓
7. Check daily ad cap:
   - adsWatchedToday = 5 < 6 max → OK
   - If 6+ → grant reward anyway (ethical fallback)
   ↓
8. Check if ad loaded:
   - If not loaded → grant reward anyway
   - If loaded → show ad
   ↓
9. Google AdMob rewarded video plays (30 seconds)
   ↓
10. Player watches ad to completion
    ↓
11. AdMob callback: onUserEarnedReward() triggered
    ↓
12. AdStats updated:
    - totalAdsWatched: 45 → 46
    - adsWatchedToday: 5 → 6
    - lastAdDate: now
    ↓
13. Apply 2× boost to offline production:
    - Wood: 180 → 360
    - Ore: 150 → 300
    - Gold: 450 → 900
    ↓
14. Resources added to inventory
    ↓
15. UI updates:
    - Wood counter animates: +360
    - Ore counter animates: +300
    - Gold counter animates: +900
    - Floating text: "2× Offline Boost!"
    ↓
16. Success animation (green flash, sparkles)
    ↓
17. Haptic feedback (light impact)
    ↓
18. Analytics: logEvent('ad_watched', {placement, reward_type, reward_multiplier})
    ↓
19. AdManager preloads next ad (background)
    ↓
20. Welcome Back modal dismisses
    ↓
21. Background: Sync adStats to Firestore
```

**Sequence: Player Reaches $10 Cap**
```
1. Player has spent $9.49 total
   ↓
2. Opens Shop screen
   ↓
3. Progress bar shows: "$9.49 / $10.00 spent"
   ↓
4. Only products ≤ $0.51 are enabled (none available)
   ↓
5. All IAP product cards show disabled state:
   - Gray overlay
   - Text: "Would exceed $10 cap"
   - Button: "View Only" (disabled)
   ↓
6. Info banner appears at top:
   - "You've reached the $10 spending cap! Thank you for supporting ethical F2P."
   - Icon: 🎉 Trophy
   ↓
7. Player attempts to tap "Buy" on Master Pack ($9.99)
   ↓
8. Dialog appears:
   - Title: "$10 Cap Reached"
   - Message: "This game caps at $10 total spending to prevent predatory monetization. Thank you for your support!"
   - Button: "OK"
   ↓
9. Analytics: logEvent('iap_cap_reached_attempted', {product_id, current_spent})
   ↓
10. Player taps "OK" → returns to Shop screen
```

**Sequence: Purchase Restoration (New Device)**
```
1. Player installs TFM on new device
   ↓
2. Signs in with Google/Apple account (same as old device)
   ↓
3. Settings screen has "Restore Purchases" button
   ↓
4. Player taps "Restore Purchases"
   ↓
5. Loading dialog appears: "Restoring purchases..."
   ↓
6. PurchaseManager.restorePurchases() called
   ↓
7. Platform API queried:
   - Android: queryPurchases() via Google Play Billing
   - iOS: restoreCompletedTransactions() via StoreKit
   ↓
8. Platform returns list of past purchases:
   - Starter Pack ($1.99) - 2024-01-15
   - Factory Pack ($4.99) - 2024-02-20
   - Builder Pack ($2.99) - 2024-03-10
   ↓
9. Calculate totalSpent: $1.99 + $4.99 + $2.99 = $9.97
   ↓
10. Update Firestore:
    - totalSpent: $9.97
    - purchasedProducts: ['starter_pack', 'factory_pack', 'builder_pack']
    ↓
11. Success dialog appears:
    - "Purchases restored!"
    - "Total spent: $9.97 / $10.00"
    - "3 products restored"
    ↓
12. Analytics: logEvent('iap_purchases_restored', {products_count, total_spent})
    ↓
13. Player can continue playing with restored state
```

## Non-Functional Requirements

### Performance

**IAP Transaction Times:**
- Purchase initiation: <200ms (open platform dialog)
- Receipt validation: <500ms (Cloud Function response)
- Gold grant: <50ms (optimistic update)
- Total purchase flow: <5 seconds (user perspective)

**Ad Loading & Display:**
- Ad preload: <3 seconds (background, non-blocking)
- Ad display: <500ms from tap to video start
- Ad completion callback: <100ms
- Reward grant: <50ms (optimistic update)

**Shop UI Performance:**
- Shop screen load: <200ms
- IAP product cards render: <100ms
- Purchase confirmation dialog: <100ms
- Progress bar animation: Smooth 60 FPS

**Firebase Costs (at 10k MAU):**
- Analytics events: Free (unlimited)
- Firestore reads: ~20 per session × 10k = 200k reads/month = $0.012
- Firestore writes: ~5 per session × 10k = 50k writes/month = $0.009
- Cloud Functions: ~100 purchase validations/month = $0.000 (free tier)
- **Total:** ~$3/month at 10k MAU

### Security

**Receipt Validation:**
- ALWAYS validate server-side (Cloud Functions)
- NEVER trust client-side purchase verification
- Google Play API / App Store API as source of truth
- Prevent duplicate receipt submission (transaction ID tracking)

**Fraud Prevention:**
- Rate limiting: Max 10 purchase attempts per hour per user
- Anomaly detection: Flag users with >$10 spent (should be impossible)
- Transaction logging: Audit trail in Firestore
- Receipt data encrypted in storage

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/purchases/{document=**} {
      // Users can READ their own purchases
      allow read: if request.auth != null && request.auth.uid == userId;

      // Users CANNOT WRITE purchases (only Cloud Functions can)
      allow write: if false;
    }

    match /users/{userId}/adStats/{document=**} {
      allow read: if request.auth != null && request.auth.uid == userId;

      // Users can UPDATE ad stats (increment counter)
      allow write: if request.auth != null &&
                      request.auth.uid == userId &&
                      // Prevent manipulation: adsWatchedToday can only increase by 1
                      request.resource.data.adsWatchedToday <= resource.data.adsWatchedToday + 1;
    }
  }
}
```

**Platform Security:**
- Google Play Billing: Uses service account credentials (private key)
- Apple App Store: Uses shared secret (stored in Cloud Functions config)
- Both: Receipt data encrypted in transit (HTTPS)

### Reliability/Availability

**Purchase Reliability:**
- Pending transaction handling: Resume incomplete purchases on app restart
- Network failure: Retry with exponential backoff (3 attempts)
- Platform timeout: Show helpful error message, allow retry
- Rollback: If receipt validation fails, refund via platform (automatic)

**Ad Reliability:**
- Ad load failure: Grant reward anyway (ethical principle)
- Ad display failure: Grant reward anyway
- Daily cap reached: Grant reward anyway (max 6 ads/day)
- Remove Ads purchased: Skip ads entirely, grant rewards

**Error Handling:**
- User cancelled purchase → no error dialog (expected behavior)
- Network error → "Check your connection and try again"
- Platform error → "Purchase failed. Contact support if charged."
- Receipt validation failed → "Purchase verification failed. Refund processing."

**Data Consistency:**
- Optimistic updates dla UI (natychmiastowa reakcja)
- Background sync do Firestore (reliable)
- Conflict resolution: Server state is source of truth
- Purchase state syncs across devices via Firestore

### Observability

**Logging:**
- Debug: IAP product fetched, ad preloaded
- Info: Purchase initiated, ad watched
- Warning: Purchase blocked (cap reached), ad failed to load
- Error: Receipt validation failed, platform error

**Metrics (Firebase Analytics):**

**Purchase Events:**
```dart
FirebaseAnalytics.logEvent('iap_purchase_initiated', {
  'product_id': 'factory_pack',
  'price': 4.99,
  'gold_amount': 3500,
});

FirebaseAnalytics.logEvent('iap_purchase_completed', {
  'product_id': 'factory_pack',
  'price': 4.99,
  'gold_amount': 3500,
  'transaction_id': 'GPA.1234.5678',
  'total_spent': 9.49,
});

FirebaseAnalytics.logEvent('iap_purchase_blocked', {
  'reason': 'cap_reached',
  'product_id': 'master_pack',
  'total_spent': 9.49,
});
```

**Ad Events:**
```dart
FirebaseAnalytics.logEvent('ad_watched', {
  'placement': 'offline_boost',
  'reward_type': '2× offline production',
  'reward_multiplier': 2.0,
});

FirebaseAnalytics.logEvent('ad_failed', {
  'placement': 'speed_boost',
  'error': 'not_loaded',
  'reward_granted_anyway': true,
});
```

**Key Metrics to Monitor:**
- **Conversion Rate**: % of users who make ANY purchase
  - Formula: Paying users / Total users
  - Target: 2%+
- **ARPPU (Average Revenue Per Paying User)**: Total revenue / Paying users
  - Target: $10
- **Ad Adoption Rate**: % of users who watch ads
  - Formula: Users who watched ≥1 ad / Total users
  - Target: 60%+
- **Lifetime Cap Hit Rate**: % of paying users who reach $10 cap
  - Target: 80%+ (indicates fair value proposition)
- **Revenue Breakdown**: IAP revenue vs Ad revenue
  - Target: 30% IAP, 70% Ad (conservative)

**Dashboard Priorities:**
- Week 1-4: Focus on stability (crashes, errors)
- Month 2+: Focus on monetization (conversion, ARPPU, ad adoption)
- Funnel analysis: Shop opened → Product tapped → Purchase completed
- Cohort analysis: D0 payers vs D7 payers vs D30 payers

## Dependencies and Integrations

### Internal Dependencies

**Required Before EPIC-08:**
- ✅ EPIC-00: Project Setup (Firebase configured)
- ✅ EPIC-01: Core Gameplay Loop (gold system exists)
- ✅ EPIC-02: Tier 1 Economy (NPC Market, resource trading)
- ⚠️ EPIC-04: Offline Production (ad boost placement) - partial dependency
- ⚠️ EPIC-09: Firebase Backend (Firestore schema, Cloud Functions) - critical

**Blocks:**
- ❌ No other epics directly blocked by EPIC-08
- Monetization is parallel feature, doesn't block core gameplay

### External Dependencies

**Flutter Packages:**
```yaml
dependencies:
  # IAP Platform Integration
  in_app_purchase: ^3.1.11        # Official Flutter plugin (Google + Apple)

  # Ads
  google_mobile_ads: ^4.0.0       # Google AdMob rewarded videos

  # Firebase (for analytics, purchase tracking)
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  cloud_functions: ^4.5.0         # Call validateReceipt

  # Platform Detection
  platform: ^3.1.0                # Detect Android vs iOS

dev_dependencies:
  # Testing IAP flows
  mocktail: ^1.0.0                # Mock platform APIs
```

**Platform SDKs:**
- **Android:** Google Play Billing Library 5.0
  - Handles purchase flows, receipt generation
  - Integrated via `in_app_purchase` package
- **iOS:** Apple StoreKit 2
  - Handles purchase flows, receipt generation
  - Integrated via `in_app_purchase` package

**Google Services:**
- **Google Play Developer API**: Receipt validation (server-side)
  - Requires service account credentials
  - Called from Cloud Functions
- **Google AdMob**: Rewarded video ad serving
  - Requires AdMob App ID (from Firebase console)
  - SDK: google_mobile_ads

**Apple Services:**
- **App Store Connect API**: Receipt validation (server-side)
  - Requires shared secret (from App Store Connect)
  - Called from Cloud Functions via HTTPS

**Firebase Services:**
- Firebase Analytics (event tracking - free, unlimited)
- Cloud Firestore (purchase state, ad stats storage)
- Cloud Functions (receipt validation, fraud prevention)

**Cloud Functions Dependencies:**
```json
// functions/package.json
{
  "dependencies": {
    "firebase-functions": "^4.5.0",
    "firebase-admin": "^11.11.0",
    "googleapis": "^128.0.0",       // Google Play API
    "axios": "^1.6.0"               // Apple receipt validation
  }
}
```

### Integration Points

**in_app_purchase Package:**
- Abstracts platform differences (Google Play vs App Store)
- Provides unified API: `purchaseProduct()`, `restorePurchases()`
- Handles pending transactions (app closed during purchase)

**Google AdMob Integration:**
- `google_mobile_ads` package
- Rewarded video loading: `RewardedAd.load()`
- Ad display: `rewardedAd.show(onUserEarnedReward: ...)`
- Preloading: Load next ad after showing current one

**Firebase Analytics Integration:**
- Automatic events: `app_open`, `session_start`, `first_open`
- Custom monetization events: `iap_purchase_completed`, `ad_watched`
- Revenue tracking: Automatically calculates LTV per cohort
- Funnels: Shop opened → Product viewed → Purchase completed

**Cloud Functions Integration:**
- Client calls: `FirebaseFunctions.instance.httpsCall('validateReceipt')`
- Server validates: Google Play API / App Store API
- Server updates: Firestore `/users/{uid}/purchases`
- Returns: `{ isValid: bool, purchaseData: {...} }`

## Acceptance Criteria (Authoritative)

### AC-1: IAP Product Catalog
- [ ] 5 IAP products defined: Starter ($1.99), Builder ($2.99), Factory ($4.99), Master ($9.99), Remove Ads ($0.99)
- [ ] Each product shows: Name, gold amount, price, description
- [ ] Factory Pack has "Best Value" badge
- [ ] Products fetch from Google Play / App Store (real prices, not hardcoded)

### AC-2: $10 Lifetime Cap Enforcement
- [ ] PurchaseManager blocks purchases that would exceed $10.00
- [ ] Progress bar shows "$X.XX / $10.00 spent"
- [ ] All IAP buttons disabled when cap reached
- [ ] Info banner appears: "You've reached the $10 cap! Thank you."
- [ ] Cap persists across devices (Firestore sync)

### AC-3: Purchase Flow - Android & iOS
- [ ] Android: Google Play Billing dialog appears on purchase
- [ ] iOS: Apple StoreKit payment sheet appears on purchase
- [ ] Purchase completes successfully → gold granted
- [ ] Receipt validation via Cloud Function (server-side)
- [ ] Failed validation → refund processed, no gold granted
- [ ] Purchase state syncs to Firestore

### AC-4: Purchase Restoration
- [ ] "Restore Purchases" button in Settings
- [ ] Queries platform for past purchases (Google Play / App Store)
- [ ] Restores totalSpent, purchasedProducts list
- [ ] Shows success message: "X products restored, $Y.YY spent"
- [ ] Works across devices (same account)

### AC-5: Rewarded Video Ads
- [ ] Google AdMob rewarded videos load correctly
- [ ] Ad placements: Welcome Back modal (offline boost), Speed Boost
- [ ] Ad frequency cap: Max 6 ads/day (enforced)
- [ ] Ad failure → reward granted anyway (ethical principle)
- [ ] Remove Ads purchased → ads disabled, rewards granted automatically

### AC-6: Shop UI
- [ ] Shop screen displays 5 IAP product cards
- [ ] Each card shows: Icon, name, gold amount, price, "Buy" button
- [ ] Progress bar at top: "$X.XX / $10.00 spent"
- [ ] Purchase confirmation dialog appears on "Buy" tap
- [ ] Disabled state when product would exceed cap
- [ ] Success animation on purchase (sparkles, haptic feedback)

### AC-7: Analytics Tracking
- [ ] `iap_purchase_initiated` logged on "Buy" tap
- [ ] `iap_purchase_completed` logged on successful purchase
- [ ] `ad_watched` logged on rewarded video completion
- [ ] Firebase Analytics shows conversion rate, ARPPU, ad adoption
- [ ] Revenue data visible in Firebase console

### AC-8: Security & Fraud Prevention
- [ ] Receipt validation ALWAYS server-side (Cloud Functions)
- [ ] Invalid receipts rejected (no gold granted)
- [ ] Firestore Security Rules prevent direct purchase manipulation
- [ ] Rate limiting: Max 10 purchase attempts per hour
- [ ] Transaction logging for audit trail

## Traceability Mapping

| AC | Spec Section | Components/APIs | Test Idea |
|----|--------------|-----------------|-----------|
| AC-1 | IAP Product Catalog | IAPProduct enum, in_app_purchase | Unit test: Verify all 5 products defined with correct prices |
| AC-2 | $10 Lifetime Cap | PurchaseManager.canPurchase() | Integration test: Attempt $9.49 + $9.99 → blocked |
| AC-3 | Purchase Flow | GooglePlayService, AppStoreService, Cloud Functions | E2E test: Complete purchase on Android sandbox |
| AC-4 | Purchase Restoration | IAPManager.restorePurchases() | Integration test: Restore 3 past purchases → verify totalSpent |
| AC-5 | Rewarded Ads | AdManager, google_mobile_ads | Integration test: Watch ad → verify 2× boost applied |
| AC-6 | Shop UI | ShopScreen, ShopProvider | Widget test: Tap "Buy" → purchase confirmation dialog appears |
| AC-7 | Analytics | AnalyticsService, Firebase Analytics | Integration test: Purchase product → verify event logged |
| AC-8 | Security | ReceiptValidator, Firestore Rules | Unit test: Invalid receipt → purchase rejected |

## Risks, Assumptions, Open Questions

### Risks

**RISK-1: Platform API Changes (Google Play / App Store)**
- Google Play Billing i Apple StoreKit mogą zmieniać API
- **Mitigation:** Use official `in_app_purchase` package (maintained by Flutter team)
- **Severity:** Medium
- **Probability:** Low (APIs are stable)

**RISK-2: Receipt Validation Complexity**
- Server-side validation via Google/Apple APIs jest złożona
- **Mitigation:** Use Cloud Functions z googleapis package (well-tested)
- **Severity:** High
- **Probability:** Medium

**RISK-3: Low Conversion Rate (<2%)**
- Gracze mogą nie być skłonni płacić w ethical F2P model
- **Mitigation:** A/B test different price points, value propositions
- **Severity:** High (revenue impact)
- **Probability:** Medium

**RISK-4: Ad Revenue Lower Than Expected**
- eCPM może być niższy niż $20 target (emerging markets)
- **Mitigation:** Geo-target US/EU markets initially, optimize ad placements
- **Severity:** Medium (revenue impact)
- **Probability:** Medium

**RISK-5: Fraud Attempts (Fake Receipts)**
- Hackers mogą próbować submit fake receipts
- **Mitigation:** Server-side validation ALWAYS, transaction logging, rate limiting
- **Severity:** High (financial impact)
- **Probability:** Low (with proper security)

### Assumptions

**ASSUMPTION-1:** 2% conversion rate jest achievable z ethical F2P model
- Validated with: Industry benchmarks (mid-core mobile games: 1-5%)

**ASSUMPTION-2:** $10 lifetime cap jest fair value proposition
- Validated with: Player feedback, ethical game design principles

**ASSUMPTION-3:** 60%+ ad adoption rate dla offline boost (2×)
- Validated with: Industry data (rewarded video engagement: 40-80%)

**ASSUMPTION-4:** Google AdMob eCPM: $10-25 (US/EU markets)
- Validated with: AdMob benchmarks, competing games data

**ASSUMPTION-5:** Cloud Functions są wystarczająco fast dla receipt validation (<500ms)
- Validated with: Firebase Performance benchmarks

### Open Questions

**Q1:** Czy Remove Ads ($0.99) powinno liczyć się do $10 lifetime cap?
- **Recommendation:** TAK, wszystkie zakupy liczą się do cap (ethical consistency)
- **Decision:** Zatwierdzone

**Q2:** Czy ad frequency cap (6 ads/day) jest optymalny?
- **Recommendation:** Rozpocznij z 6/day, A/B test 4 vs 6 vs 8 w Month 2
- **Decision:** Start z 6, testuj później

**Q3:** Czy oferować refund jeśli gracz nie jest zadowolony?
- **Recommendation:** TAK, honor all refund requests (ethical principle)
- **Decision:** Zatwierdzone, dodaj "Request Refund" w Settings

**Q4:** Czy "Best Value" badge na Factory Pack ($4.99) jest fair?
- **Recommendation:** TAK, oferuje 70% więcej gold per dollar niż Starter Pack
- **Decision:** Zatwierdzone (Math: Factory $4.99/3500g = $0.0014/g vs Starter $1.99/1000g = $0.00199/g)

## Test Strategy Summary

### Test Pyramid

```
         ┌───────────────┐
        /  E2E Tests (5%) \
       /     - 8 tests     \
      ┌─────────────────────┐
     /  Integration (15%)   \
    /    - 20 tests          \
   ┌───────────────────────────┐
  /   Unit Tests (80%)         \
 /     - 80+ tests              \
└─────────────────────────────────┘
```

### Unit Tests (80+ tests)

**PurchaseManager Tests:**
- `purchase_manager_test.dart`: Lifetime cap enforcement (15 tests)
  - canPurchase() returns true if under cap
  - canPurchase() returns false if would exceed cap
  - recordPurchase() updates totalSpent correctly
  - Edge case: Exactly $10.00 → allowed
  - Edge case: $9.99 + $0.02 → blocked

**IAPProduct Tests:**
- `iap_product_test.dart`: Product definitions (10 tests)
  - All 5 products defined
  - Prices correct ($1.99, $2.99, $4.99, $9.99, $0.99)
  - Gold amounts correct (1000, 1750, 3500, 8000, 0)
  - Factory Pack has isBestValue = true

**AdManager Tests:**
- `ad_manager_test.dart`: Daily ad cap (15 tests)
  - adsWatchedToday increments on ad watch
  - Daily cap (6 ads) enforced
  - Daily count resets at midnight
  - Ad failure → reward granted anyway

**Receipt Validation Tests:**
- `receipt_validator_test.dart`: Mock server validation (20 tests)
  - Valid receipt → returns true
  - Invalid receipt → returns false
  - Network error → retry with backoff
  - Duplicate receipt → rejected

**Analytics Tests:**
- `analytics_service_test.dart`: Event logging (10 tests)
  - iap_purchase_completed logs correct parameters
  - ad_watched logs placement, reward_type
  - Verify Firebase Analytics mock called

### Integration Tests (20 tests)

**Purchase Flow Tests:**
- `purchase_flow_test.dart`: End-to-end purchase (Android sandbox)
  - Select product → platform dialog → purchase → gold granted
  - Verify totalSpent updated in Firestore
  - Verify receipt logged in transactions collection

**Purchase Restoration Tests:**
- `purchase_restoration_test.dart`: Cross-device sync
  - Create purchases on Device A
  - Sign in on Device B → restore → verify state

**Ad Flow Tests:**
- `ad_flow_test.dart`: Rewarded video integration
  - Load ad → show ad → watch to completion → reward granted
  - Verify adsWatchedToday incremented
  - Verify analytics event logged

**Cloud Functions Tests:**
- `cloud_functions_test.dart`: Receipt validation
  - Call validateReceipt with mock receipt → verify response
  - Invalid receipt → returns isValid = false

### E2E Tests (8 tests)

**Complete Purchase Journey:**
- `e2e_purchase_test.dart`:
  1. Open Shop screen
  2. Tap "Buy" on Factory Pack ($4.99)
  3. Confirm purchase in dialog
  4. Complete Google Play Billing flow (sandbox)
  5. Verify gold added (+3500)
  6. Verify progress bar updated ($4.99 / $10.00)
  7. Verify analytics event logged

**Complete Ad Journey:**
- `e2e_ad_test.dart`:
  1. Player goes offline for 3 hours
  2. Returns → Welcome Back modal appears
  3. Tap "Watch Ad (30s)"
  4. AdMob rewarded video plays
  5. Watch to completion
  6. Verify 2× boost applied
  7. Verify analytics event logged

**Lifetime Cap Journey:**
- `e2e_lifetime_cap_test.dart`:
  1. Purchase products totaling $9.49
  2. Attempt to purchase Master Pack ($9.99)
  3. Verify blocked (would exceed $10)
  4. Verify error dialog appears
  5. Purchase Builder Pack ($2.99) instead
  6. Verify blocked ($9.49 + $2.99 = $12.48 > $10)

### Performance Tests

**Purchase Response Time:**
```dart
test('Purchase completes in <5 seconds (user perspective)', () async {
  final stopwatch = Stopwatch()..start();

  // Initiate purchase (mock platform dialog completes instantly)
  await purchaseManager.purchaseProduct(state, IAPProduct.factoryPack);

  stopwatch.stop();
  expect(stopwatch.elapsedSeconds, lessThan(5));
});
```

**Receipt Validation Latency:**
```dart
test('Receipt validation completes in <500ms', () async {
  final stopwatch = Stopwatch()..start();

  final result = await cloudFunctions.httpsCall('validateReceipt', {
    'platform': 'android',
    'receiptData': 'mock_receipt_token',
    'productId': 'factory_pack',
  });

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
});
```

### Manual Testing Checklist

**Platform Testing:**
- [ ] Test on Android physical device (Google Play sandbox)
- [ ] Test on iOS physical device (App Store sandbox)
- [ ] Verify purchases appear in Google Play Console / App Store Connect
- [ ] Test refund flow (request refund via platform)

**Ad Testing:**
- [ ] AdMob test ads load correctly
- [ ] Test on real device (not emulator - ads don't load in emulator)
- [ ] Verify eCPM tracking in AdMob console
- [ ] Test ad frequency cap (watch 6 ads, verify 7th blocked)

**Cross-Device Testing:**
- [ ] Purchase on Device A → sign in on Device B → restore → verify
- [ ] totalSpent syncs correctly via Firestore
- [ ] purchasedProducts list syncs correctly

**Security Testing:**
- [ ] Attempt to manipulate Firestore directly → verify blocked by Security Rules
- [ ] Submit fake receipt to Cloud Function → verify rejected
- [ ] Attempt >10 purchases per hour → verify rate limited

### Test Coverage Target

- **Unit Tests:** 90%+ coverage (business logic)
- **Integration Tests:** 80%+ coverage (critical paths)
- **E2E Tests:** Critical flows only (purchase, ad, cap)
- **Overall:** 85%+ coverage

---

**Status:** Ready for Implementation
**Next Steps:**
1. Configure Google Play Console & App Store Connect (IAP products)
2. Setup Cloud Functions with service account credentials
3. Implement PurchaseManager with $10 cap enforcement
4. Integrate `in_app_purchase` package
5. Implement Shop UI
6. Deploy Cloud Function for receipt validation
7. Test in sandbox environments (both platforms)
8. Load SM agent and run `create-story` to begin implementing the first story under EPIC-08.
