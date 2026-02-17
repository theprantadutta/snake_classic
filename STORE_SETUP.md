# Snake Classic - Store Setup Guide

Complete guide for setting up in-app purchases on Google Play Store and Apple App Store.

## Package / Bundle IDs

| Platform | Identifier |
|----------|-----------|
| Android (Google Play) | `com.pranta.snakeclassic` |
| iOS (App Store) | `com.pranta.snakeclassic` |

**Product ID Prefix:** All product IDs use the `com.pranta.snakeclassic.` prefix.

---

## All Products

Snake Classic has **44 active store products** across 7 categories.

### Subscriptions (Auto-Renewable) — 2 products

| Product ID | Name | Price | Billing |
|-----------|------|-------|---------|
| `com.pranta.snakeclassic.pro_monthly` | Pro Monthly | $4.99/mo | Monthly auto-renew |
| `com.pranta.snakeclassic.pro_yearly` | Pro Yearly | $49.99/yr | Yearly auto-renew |

### Battle Pass — Coming Soon

> **Do not create in store yet.** Battle Pass will be enabled in a future release.

| Product ID | Name | Price | Status |
|-----------|------|-------|--------|
| `com.pranta.snakeclassic.battle_pass_season` | Battle Pass Season | $9.99 | **Coming Soon** |

### Premium Themes (Non-Consumable) — 7 products

| Product ID | Name | Price |
|-----------|------|-------|
| `com.pranta.snakeclassic.crystal_theme` | Crystal Theme | $1.99 |
| `com.pranta.snakeclassic.cyberpunk_theme` | Cyberpunk Theme | $1.99 |
| `com.pranta.snakeclassic.space_theme` | Space Theme | $1.99 |
| `com.pranta.snakeclassic.ocean_theme` | Ocean Theme | $1.99 |
| `com.pranta.snakeclassic.desert_theme` | Desert Theme | $1.99 |
| `com.pranta.snakeclassic.forest_theme` | Forest Theme | $1.99 |
| `com.pranta.snakeclassic.premium_themes_bundle` | All Themes Bundle | $7.99 |

> **Note:** Pro subscribers get access to all premium themes as part of their subscription.

### Snake Coins (Consumable) — 4 products

| Product ID | Name | Coins | Bonus | Total | Price |
|-----------|------|-------|-------|-------|-------|
| `com.pranta.snakeclassic.coin_pack_small` | Starter Pack | 100 | — | 100 | $0.99 |
| `com.pranta.snakeclassic.coin_pack_medium` | Value Pack | 500 | +50 | 550 | $4.99 |
| `com.pranta.snakeclassic.coin_pack_large` | Premium Pack | 1,200 | +200 | 1,400 | $9.99 |
| `com.pranta.snakeclassic.coin_pack_mega` | Ultimate Pack | 2,500 | +500 | 3,000 | $19.99 |

### Snake Skins (Non-Consumable) — 11 products

Skin IDs use the `skin_` category prefix.

| Product ID | Name | Price |
|-----------|------|-------|
| `com.pranta.snakeclassic.skin_golden` | Golden Snake | $1.99 |
| `com.pranta.snakeclassic.skin_fire` | Fire Snake | $1.99 |
| `com.pranta.snakeclassic.skin_ice` | Ice Snake | $1.99 |
| `com.pranta.snakeclassic.skin_electric` | Electric Snake | $1.99 |
| `com.pranta.snakeclassic.skin_rainbow` | Rainbow Snake | $2.99 |
| `com.pranta.snakeclassic.skin_neon` | Neon Snake | $2.99 |
| `com.pranta.snakeclassic.skin_shadow` | Shadow Snake | $2.99 |
| `com.pranta.snakeclassic.skin_galaxy` | Galaxy Snake | $3.99 |
| `com.pranta.snakeclassic.skin_crystal` | Crystal Snake | $3.99 |
| `com.pranta.snakeclassic.skin_cosmic` | Cosmic Snake | $3.99 |
| `com.pranta.snakeclassic.skin_dragon` | Dragon Snake | $4.99 |

### Trail Effects (Non-Consumable) — 11 products

| Product ID | Name | Price |
|-----------|------|-------|
| `com.pranta.snakeclassic.trail_particle` | Particle Trail | $0.99 |
| `com.pranta.snakeclassic.trail_glow` | Glow Trail | $0.99 |
| `com.pranta.snakeclassic.trail_rainbow` | Rainbow Trail | $1.99 |
| `com.pranta.snakeclassic.trail_neon` | Neon Trail | $1.99 |
| `com.pranta.snakeclassic.trail_shadow` | Shadow Trail | $1.99 |
| `com.pranta.snakeclassic.trail_fire` | Fire Trail | $2.99 |
| `com.pranta.snakeclassic.trail_electric` | Electric Trail | $2.99 |
| `com.pranta.snakeclassic.trail_star` | Star Trail | $2.99 |
| `com.pranta.snakeclassic.trail_cosmic` | Cosmic Trail | $3.99 |
| `com.pranta.snakeclassic.trail_crystal` | Crystal Trail | $3.99 |
| `com.pranta.snakeclassic.trail_dragon` | Dragon Trail | $3.99 |

### Cosmetic Bundles (Non-Consumable) — 4 products

| Product ID | Name | Contents | Original | Price | Savings |
|-----------|------|----------|----------|-------|---------|
| `com.pranta.snakeclassic.starter_pack` | Starter Pack | Golden + Fire skins, Particle + Glow trails | $5.96 | $3.99 | 33% |
| `com.pranta.snakeclassic.elemental_pack` | Elemental Pack | Fire + Ice + Electric skins, Fire + Electric trails | $11.94 | $7.99 | 33% |
| `com.pranta.snakeclassic.cosmic_collection` | Cosmic Collection | Galaxy + Cosmic + Crystal skins, Cosmic + Star + Crystal trails | $23.94 | $14.99 | 37% |
| `com.pranta.snakeclassic.ultimate_collection` | Ultimate Collection | All 11 skins + All 11 trails | $71.89 | $29.99 | 58% |

### Tournament Entries (Consumable) — 5 products

| Product ID | Name | Price |
|-----------|------|-------|
| `com.pranta.snakeclassic.tournament_bronze` | Bronze Tournament Entry | $0.99 |
| `com.pranta.snakeclassic.tournament_silver` | Silver Tournament Entry | $1.99 |
| `com.pranta.snakeclassic.tournament_gold` | Gold Tournament Entry | $4.99 |
| `com.pranta.snakeclassic.championship_entry` | Championship Entry | $9.99 |
| `com.pranta.snakeclassic.tournament_vip_entry` | VIP Tournament Entry | $14.99 |

### Removed Products

The following products have been removed from IAP (power-ups are now coin-purchased only):

| Old Product ID | Name | Reason |
|---------------|------|--------|
| ~~`mega_powerups_pack`~~ | Mega Power Pack | Coin-purchased only |
| ~~`exclusive_powerups_pack`~~ | Exclusive Power Pack | Coin-purchased only |
| ~~`premium_powerups_bundle`~~ | Premium Powerups Bundle | Coin-purchased only |

---

## Product Count Summary

| Category | Count |
|----------|-------|
| Subscriptions | 2 |
| Themes | 7 |
| Coins | 4 |
| Skins | 11 |
| Trails | 11 |
| Bundles | 4 |
| Tournaments | 5 |
| **Total active store products** | **44** |

---

## Feature Comparison: Free vs Pro

| Feature | Free | Pro ($4.99/mo or $49.99/yr) |
|---------|------|-----|
| Classic gameplay | Yes | Yes |
| Basic themes (Classic, Retro, Matrix, Neon, Sunset, Midnight, Pastel) | Yes | Yes |
| Premium themes (Crystal, Cyberpunk, Space, Ocean, Desert, Forest) | Purchase individually | All included |
| Snake skins | Purchase individually | Purchase individually |
| Trail effects | Purchase individually | Purchase individually |
| Premium board sizes | No | Yes |
| Coin earning multiplier | 1x | 2x |
| Ad-free experience | No | Yes |
| Battle Pass premium track | Coming Soon | Coming Soon |

---

## Google Play Console Setup

### 1. Create Subscription Products

Go to **Google Play Console > Your App > Monetize > Products > Subscriptions**.

#### Pro Monthly
- **Product ID:** `com.pranta.snakeclassic.pro_monthly`
- **Name:** Snake Classic Pro (Monthly)
- **Description:** Unlock all premium themes, ad-free gameplay, 2x coin earning, and premium board sizes.
- **Default price:** $4.99
- **Billing period:** Monthly
- **Grace period:** 7 days
- **Account hold:** 30 days
- **Free trial:** 3 days (optional)
- **Resubscribe:** Allow

#### Pro Yearly
- **Product ID:** `com.pranta.snakeclassic.pro_yearly`
- **Name:** Snake Classic Pro (Yearly)
- **Description:** Everything in Pro Monthly — save 17% with yearly billing.
- **Default price:** $49.99
- **Billing period:** Yearly
- **Grace period:** 14 days
- **Account hold:** 30 days
- **Free trial:** 7 days (optional)
- **Resubscribe:** Allow

### 2. Create In-App Products (One-Time)

Go to **Google Play Console > Your App > Monetize > Products > In-app products**.

Create each product from the tables above. For each:
- Set the **Product ID** exactly as listed (cannot be changed later)
- Set **Product type** to "Managed product" (non-consumable) or "Consumable" as noted
- Set the price and localized name/description

**Consumable products** (coins + tournament entries):
`com.pranta.snakeclassic.coin_pack_small`, `com.pranta.snakeclassic.coin_pack_medium`, `com.pranta.snakeclassic.coin_pack_large`, `com.pranta.snakeclassic.coin_pack_mega`,
`com.pranta.snakeclassic.tournament_bronze`, `com.pranta.snakeclassic.tournament_silver`, `com.pranta.snakeclassic.tournament_gold`, `com.pranta.snakeclassic.championship_entry`, `com.pranta.snakeclassic.tournament_vip_entry`

**Non-consumable products** (everything else):
All themes, skins, trails, and bundles.

### 3. Grace Period Settings

For subscriptions, configure grace periods in **Google Play Console > Monetize > Subscriptions > [Product] > Grace period**:

| Setting | Pro Monthly | Pro Yearly |
|---------|------------|------------|
| Grace period | 7 days | 14 days |
| Account hold | 30 days | 30 days |

### 4. Service Account Setup

1. Go to **Google Cloud Console > IAM & Admin > Service Accounts**
2. Create a new service account:
   - Name: `snakeclassic-play-verify`
   - Role: none (we'll add API access in Play Console)
3. Create a JSON key and download it
4. In **Google Play Console > Setup > API access**:
   - Link your Google Cloud project
   - Grant the service account access with **Financial data** permissions
5. Place the JSON key at `snake-classic-backend/google-play-service-account.json`

---

## RTDN (Real-Time Developer Notifications) Setup

### 1. Create Pub/Sub Topic

In **Google Cloud Console > Pub/Sub > Topics**:

- **Topic name:** `snakeclassic-play-rtdn`
- Full topic path: `projects/{your-project}/topics/snakeclassic-play-rtdn`
- Grant `google-play-developer-notifications@system.gserviceaccount.com` the **Pub/Sub Publisher** role on this topic

### 2. Create Push Subscription

In **Google Cloud Console > Pub/Sub > Subscriptions**:

- **Subscription name:** `snakeclassic-rtdn-push`
- **Topic:** `snakeclassic-play-rtdn`
- **Delivery type:** Push
- **Push endpoint:** `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/google-play?token=YOUR_VERIFICATION_TOKEN`
- **Acknowledgment deadline:** 60 seconds
- **Message retention:** 7 days
- **Retry policy:** Exponential backoff (min 10s, max 600s)

### 3. Link in Google Play Console

1. Go to **Google Play Console > Monetize > Monetization setup**
2. Under **Real-time developer notifications**, set the topic:
   ```
   projects/{your-project}/topics/snakeclassic-play-rtdn
   ```
3. Click **Save changes**
4. Click **Send test notification** to verify

### 4. Test RTDN

```bash
# Check if webhook is receiving notifications
curl -X POST "https://snakeclassic.pranta.dev/api/v1/purchases/webhook/google-play?token=YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message":{"data":"eyJ0ZXN0IjoiMSJ9"}}'
```

---

## iOS App Store Connect Setup

### 1. Create Subscription Group

In **App Store Connect > Your App > In-App Purchases > Manage**:

1. Create a subscription group: **Snake Classic Pro**
2. Add subscriptions to the group:

#### Pro Monthly
- **Product ID:** `com.pranta.snakeclassic.pro_monthly`
- **Reference Name:** Pro Monthly
- **Subscription Duration:** 1 Month
- **Price:** $4.99 (Tier 5)
- **Subscription Group:** Snake Classic Pro
- **Level:** 1 (highest)

#### Pro Yearly
- **Product ID:** `com.pranta.snakeclassic.pro_yearly`
- **Reference Name:** Pro Yearly
- **Subscription Duration:** 1 Year
- **Price:** $49.99 (Tier 30)
- **Subscription Group:** Snake Classic Pro
- **Level:** 1 (same level — user chooses billing frequency)

### 2. Create In-App Purchase Products

For each non-consumable and consumable product listed above:

1. Go to **In-App Purchases > Create**
2. Select type: **Consumable** or **Non-Consumable**
3. Set **Product ID** exactly as listed
4. Set pricing tier, display name, and description
5. Add a screenshot for review

### 3. App Store Server Notifications V2

1. In **App Store Connect > Your App > App Information**
2. Under **App Store Server Notifications**:
   - **Production URL:** `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/app-store`
   - **Sandbox URL:** `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/app-store` (use same or separate sandbox endpoint)
   - **Version:** Version 2

### 4. App Store Connect API Key

1. Go to **App Store Connect > Users and Access > Integrations > App Store Connect API**
2. Generate a new key with **Admin** or **Finance** role
3. Download the `.p8` private key file
4. Note the **Key ID** and **Issuer ID**

---

## Backend Configuration

### Environment Variables

Add to your backend `.env` file:

```env
# Google Play
GOOGLE_PLAY_PACKAGE_NAME=com.pranta.snakeclassic
GOOGLE_PLAY_SERVICE_ACCOUNT_PATH=./google-play-service-account.json
GOOGLE_PLAY_PUBSUB_VERIFICATION_TOKEN=your_random_secure_token

# Apple App Store
APPLE_BUNDLE_ID=com.pranta.snakeclassic
APPLE_KEY_ID=your_key_id
APPLE_ISSUER_ID=your_issuer_id
APPLE_PRIVATE_KEY=./AuthKey_XXXXXX.p8

# General
NOTIFICATION_BACKEND_URL=https://snakeclassic.pranta.dev
```

---

## ID Architecture

**Two namespaces exist:**

| Namespace | Format | Used By |
|-----------|--------|---------|
| Store IDs | `com.pranta.snakeclassic.{id}` | Google Play, App Store, `PurchaseService` |
| Internal IDs | bare `{id}` | SharedPreferences, database, `PremiumCubit` state |

The `ProductIds` class in `purchase_service.dart` provides `stripPrefix()` and `withPrefix()` helpers to convert between the two namespaces. The backend strips the prefix on incoming requests and stores bare IDs in the database for backward compatibility.

---

## API Integration

### Verify Purchase

```
POST /api/v1/purchases/verify
Content-Type: application/json

{
  "platform": "android" | "ios",
  "receipt_data": "<server_verification_data>",
  "product_id": "com.pranta.snakeclassic.pro_monthly",
  "transaction_id": "<transaction_id>",
  "user_id": "<user_id>",
  "purchase_token": "<google_play_purchase_token>",
  "device_info": {
    "source": "google_play" | "app_store",
    "local_verification_data": "<local_data>"
  }
}
```

**Response:**
```json
{
  "valid": true,
  "premium_content_unlocked": ["premium_themes", "ad_free", "2x_coins"]
}
```

### Check Subscription Status

```
GET /api/v1/subscription/status?user_id=<user_id>
```

### Subscription Event History

```
GET /api/v1/subscription/history?user_id=<user_id>
```

### Sync Premium Status

```
POST /api/v1/purchases/sync
Content-Type: application/json

{
  "user_id": "<user_id>"
}
```

---

## Webhook Endpoints

| Platform | Endpoint |
|----------|----------|
| Google Play RTDN | `POST /api/v1/purchases/webhook/google-play?token=<verification_token>` |
| App Store Server Notifications | `POST /api/v1/purchases/webhook/app-store` |

---

## Testing Guide

### Google Play Testing

1. **License testers:** Add test accounts in **Google Play Console > Setup > License testing**
2. **Internal testing track:** Upload a build to the internal track for real purchase testing
3. **Test subscriptions:** Use license tester accounts — subscriptions renew quickly:
   - Monthly -> renews every 5 minutes
   - Yearly -> renews every 30 minutes
4. **Test RTDN:** Monitor webhook endpoint logs for notification delivery
5. **Cancel/refund:** Test through Google Play subscription settings

### iOS Testing

1. **Sandbox accounts:** Create sandbox Apple IDs in **App Store Connect > Users and Access > Sandbox Testers**
2. **StoreKit Testing in Xcode:** Use StoreKit Configuration files for local testing
3. **Sandbox subscriptions:** Auto-renew at accelerated rates:
   - Monthly -> renews every 5 minutes
   - Yearly -> renews every 1 hour
4. **Server notifications:** Test sandbox notifications arrive at your sandbox URL

### Testing Checklist

- [ ] All 44 products appear in the store
- [ ] Consumables (coins, tournament entries) can be purchased multiple times
- [ ] Non-consumables (skins, trails, themes) show as purchased after buying
- [ ] Pro subscription unlocks premium themes + ad-free + 2x coins
- [ ] Cosmetic bundles unlock all included items
- [ ] RTDN/Server Notifications arrive at webhook endpoints
- [ ] Purchase restore works on fresh install
- [ ] Grace period keeps access when payment fails
- [ ] Subscription cancellation removes access after expiry
- [ ] Battle Pass nav shows "Coming Soon" snackbar
- [ ] Existing user data (SharedPreferences with bare IDs) still loads correctly

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|---------|
| Products not loading | Ensure all product IDs match exactly with `com.pranta.snakeclassic.` prefix. Check `ProductIds.allProductIds` in `purchase_service.dart`. |
| RTDN not received | Verify Pub/Sub topic permissions, push endpoint URL, and verification token. |
| iOS purchase fails | Check sandbox account is signed in under Settings > App Store. |
| "Item already owned" on Android | Call `restorePurchases()` or consume the purchase if it's consumable. |
| Subscription not recognized | Check backend verification endpoint is returning `valid: true`. |
| Webhook 401/403 | Verify the `token` query parameter matches `GOOGLE_PLAY_PUBSUB_VERIFICATION_TOKEN`. |

### Debugging

- **Backend health:** `GET /health/status`
- **Backend logs:** Check server logs for purchase verification errors
- **Flutter logs:** `PurchaseService` logs all operations via `AppLogger`

---

## Flutter App File Reference

| File | Purpose |
|------|---------|
| `lib/services/purchase_service.dart` | Product IDs (with prefix), purchase flow, store integration |
| `lib/services/backend_service.dart` | Backend API calls for verification and sync |
| `lib/presentation/bloc/premium/premium_cubit.dart` | Premium state management, purchase handling (strips prefix) |
| `lib/presentation/bloc/premium/premium_state.dart` | Premium tiers, owned content tracking |
| `lib/presentation/bloc/premium/battle_pass_cubit.dart` | Battle Pass state and tier progression |
| `lib/models/premium_cosmetics.dart` | Snake skins, trail effects, cosmetic bundles (internal IDs) |
| `lib/models/snake_coins.dart` | Coin packs, pricing, coin economy (internal IDs) |
| `lib/models/premium_power_up.dart` | Power-ups (coin-purchased only, not IAP) |
| `lib/models/tournament.dart` | Tournament model with entry system |
| `lib/screens/theme_selector_screen.dart` | Theme purchase UI |
| `lib/screens/cosmetics_screen.dart` | Cosmetics store UI (maps to store IDs for purchases) |
| `lib/screens/battle_pass_screen.dart` | Battle Pass display (Coming Soon banner) |
