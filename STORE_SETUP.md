# Snake Classic - Store Setup Guide

Complete guide for setting up in-app purchases on Google Play Store and Apple App Store.

## Package / Bundle IDs

| Platform | Identifier |
|----------|-----------|
| Android (Google Play) | `com.pranta.snakeclassic` |
| iOS (App Store) | `com.pranta.snakeclassic` |

---

## All Products

Snake Classic has **59 purchasable products** across 8 categories.

### Subscriptions (Auto-Renewable)

| Product ID | Name | Price | Billing |
|-----------|------|-------|---------|
| `snake_classic_pro_monthly` | Pro Monthly | $4.99/mo | Monthly auto-renew |
| `snake_classic_pro_yearly` | Pro Yearly | $49.99/yr | Yearly auto-renew |
| `battle_pass_season` | Battle Pass Season | $9.99 | Seasonal (non-renewing) |

### Premium Themes (Non-Consumable)

| Product ID | Name | Price |
|-----------|------|-------|
| `crystal_theme` | Crystal Theme | $1.99 |
| `cyberpunk_theme` | Cyberpunk Theme | $1.99 |
| `space_theme` | Space Theme | $1.99 |
| `ocean_theme` | Ocean Theme | $1.99 |
| `desert_theme` | Desert Theme | $1.99 |
| `forest_theme` | Forest Theme | $1.99 |
| `premium_themes_bundle` | All Themes Bundle | $7.99 |

> **Note:** Pro subscribers get access to all premium themes as part of their subscription.

### Snake Coins (Consumable)

| Product ID | Name | Coins | Bonus | Total | Price |
|-----------|------|-------|-------|-------|-------|
| `coin_pack_small` | Starter Pack | 100 | — | 100 | $0.99 |
| `coin_pack_medium` | Value Pack | 500 | +50 | 550 | $4.99 |
| `coin_pack_large` | Premium Pack | 1,200 | +200 | 1,400 | $9.99 |
| `coin_pack_mega` | Ultimate Pack | 2,500 | +500 | 3,000 | $19.99 |

### Snake Skins (Non-Consumable)

| Product ID | Name | Price |
|-----------|------|-------|
| `golden` | Golden Snake | $1.99 |
| `fire` | Fire Snake | $1.99 |
| `ice` | Ice Snake | $1.99 |
| `electric` | Electric Snake | $1.99 |
| `rainbow` | Rainbow Snake | $2.99 |
| `neon` | Neon Snake | $2.99 |
| `shadow` | Shadow Snake | $2.99 |
| `galaxy` | Galaxy Snake | $3.99 |
| `crystal` | Crystal Snake | $3.99 |
| `cosmic` | Cosmic Snake | $3.99 |
| `dragon` | Dragon Snake | $4.99 |

### Trail Effects (Non-Consumable)

| Product ID | Name | Price |
|-----------|------|-------|
| `trail_particle` | Particle Trail | $0.99 |
| `trail_glow` | Glow Trail | $0.99 |
| `trail_rainbow` | Rainbow Trail | $1.99 |
| `trail_neon` | Neon Trail | $1.99 |
| `trail_shadow` | Shadow Trail | $1.99 |
| `trail_fire` | Fire Trail | $2.99 |
| `trail_electric` | Electric Trail | $2.99 |
| `trail_star` | Star Trail | $2.99 |
| `trail_cosmic` | Cosmic Trail | $3.99 |
| `trail_crystal` | Crystal Trail | $3.99 |
| `trail_dragon` | Dragon Trail | $3.99 |

### Cosmetic Bundles (Non-Consumable)

| Product ID | Name | Contents | Original | Price | Savings |
|-----------|------|----------|----------|-------|---------|
| `starter_pack` | Starter Pack | Golden + Fire skins, Particle + Glow trails | $5.96 | $3.99 | 33% |
| `elemental_pack` | Elemental Pack | Fire + Ice + Electric skins, Fire + Electric trails | $11.94 | $7.99 | 33% |
| `cosmic_collection` | Cosmic Collection | Galaxy + Cosmic + Crystal skins, Cosmic + Star + Crystal trails | $23.94 | $14.99 | 37% |
| `ultimate_collection` | Ultimate Collection | All 11 skins + All 11 trails | $71.89 | $29.99 | 58% |

### Power-ups (Non-Consumable)

| Product ID | Name | Contents | Price |
|-----------|------|----------|-------|
| `mega_powerups_pack` | Mega Power Pack | Mega Speed, Mega Invincibility, Mega Score, Mega Slow Motion | $4.99 |
| `exclusive_powerups_pack` | Exclusive Power Pack | Teleport, Size Reducer, Score Shield, Ghost Mode, + more | $7.99 |
| `premium_powerups_bundle` | Premium Powerups Bundle | All 14 premium power-ups | $12.99 |

### Tournament Entries (Consumable)

| Product ID | Name | Price |
|-----------|------|-------|
| `tournament_bronze` | Bronze Tournament Entry | $0.99 |
| `tournament_silver` | Silver Tournament Entry | $1.99 |
| `tournament_gold` | Gold Tournament Entry | $4.99 |
| `championship_entry` | Championship Entry | $9.99 |
| `tournament_vip_entry` | VIP Tournament Entry | $14.99 |

---

## Feature Comparison: Free vs Pro

| Feature | Free | Pro ($4.99/mo or $49.99/yr) |
|---------|------|-----|
| Classic gameplay | Yes | Yes |
| Basic themes (Classic, Retro, Matrix, Neon, Sunset, Midnight, Pastel) | Yes | Yes |
| Premium themes (Crystal, Cyberpunk, Space, Ocean, Desert, Forest) | Purchase individually | All included |
| Snake skins | Purchase individually | Purchase individually |
| Trail effects | Purchase individually | Purchase individually |
| Premium power-ups | Purchase individually | Purchase individually |
| Premium board sizes | No | Yes |
| Coin earning multiplier | 1x | 2x |
| Ad-free experience | No | Yes |
| Battle Pass premium track | No | With Battle Pass purchase |

---

## Google Play Console Setup

### 1. Create Subscription Products

Go to **Google Play Console > Your App > Monetize > Products > Subscriptions**.

#### Pro Monthly
- **Product ID:** `snake_classic_pro_monthly`
- **Name:** Snake Classic Pro (Monthly)
- **Description:** Unlock all premium themes, ad-free gameplay, 2x coin earning, and premium board sizes.
- **Default price:** $4.99
- **Billing period:** Monthly
- **Grace period:** 7 days
- **Account hold:** 30 days
- **Free trial:** 3 days (optional)
- **Resubscribe:** Allow

#### Pro Yearly
- **Product ID:** `snake_classic_pro_yearly`
- **Name:** Snake Classic Pro (Yearly)
- **Description:** Everything in Pro Monthly — save 17% with yearly billing.
- **Default price:** $49.99
- **Billing period:** Yearly
- **Grace period:** 14 days
- **Account hold:** 30 days
- **Free trial:** 7 days (optional)
- **Resubscribe:** Allow

#### Battle Pass Season
- **Product ID:** `battle_pass_season`
- **Name:** Battle Pass Season
- **Description:** Unlock the premium Battle Pass track with exclusive rewards, XP boosts, and seasonal cosmetics.
- **Default price:** $9.99
- **Billing period:** Seasonal (use a fixed duration, e.g. 90 days)
- **Grace period:** 3 days

### 2. Create In-App Products (One-Time)

Go to **Google Play Console > Your App > Monetize > Products > In-app products**.

Create each product from the tables above. For each:
- Set the **Product ID** exactly as listed (cannot be changed later)
- Set **Product type** to "Managed product" (non-consumable) or "Consumable" as noted
- Set the price and localized name/description

**Consumable products** (coins + tournament entries):
`coin_pack_small`, `coin_pack_medium`, `coin_pack_large`, `coin_pack_mega`,
`tournament_bronze`, `tournament_silver`, `tournament_gold`, `championship_entry`, `tournament_vip_entry`

**Non-consumable products** (everything else):
All themes, skins, trails, bundles, and power-up packs.

### 3. Grace Period Settings

For subscriptions, configure grace periods in **Google Play Console > Monetize > Subscriptions > [Product] > Grace period**:

| Setting | Pro Monthly | Pro Yearly | Battle Pass |
|---------|------------|------------|-------------|
| Grace period | 7 days | 14 days | 3 days |
| Account hold | 30 days | 30 days | — |

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
- **Product ID:** `snake_classic_pro_monthly`
- **Reference Name:** Pro Monthly
- **Subscription Duration:** 1 Month
- **Price:** $4.99 (Tier 5)
- **Subscription Group:** Snake Classic Pro
- **Level:** 1 (highest)

#### Pro Yearly
- **Product ID:** `snake_classic_pro_yearly`
- **Reference Name:** Pro Yearly
- **Subscription Duration:** 1 Year
- **Price:** $49.99 (Tier 30)
- **Subscription Group:** Snake Classic Pro
- **Level:** 1 (same level — user chooses billing frequency)

#### Battle Pass Season
- **Product ID:** `battle_pass_season`
- **Reference Name:** Battle Pass Season
- Create as a separate subscription group **Battle Pass** or as a non-renewing subscription
- **Price:** $9.99

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

## API Integration

### Verify Purchase

```
POST /api/v1/purchases/verify
Content-Type: application/json

{
  "platform": "android" | "ios",
  "receipt_data": "<server_verification_data>",
  "product_id": "snake_classic_pro_monthly",
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
   - Monthly → renews every 5 minutes
   - Yearly → renews every 30 minutes
4. **Test RTDN:** Monitor webhook endpoint logs for notification delivery
5. **Cancel/refund:** Test through Google Play subscription settings

### iOS Testing

1. **Sandbox accounts:** Create sandbox Apple IDs in **App Store Connect > Users and Access > Sandbox Testers**
2. **StoreKit Testing in Xcode:** Use StoreKit Configuration files for local testing
3. **Sandbox subscriptions:** Auto-renew at accelerated rates:
   - Monthly → renews every 5 minutes
   - Yearly → renews every 1 hour
4. **Server notifications:** Test sandbox notifications arrive at your sandbox URL

### Testing Checklist

- [ ] All 59 products appear in the store
- [ ] Consumables (coins, tournament entries) can be purchased multiple times
- [ ] Non-consumables (skins, trails, themes) show as purchased after buying
- [ ] Pro subscription unlocks premium themes + ad-free + 2x coins
- [ ] Battle Pass purchase unlocks premium track
- [ ] Cosmetic bundles unlock all included items
- [ ] RTDN/Server Notifications arrive at webhook endpoints
- [ ] Purchase restore works on fresh install
- [ ] Grace period keeps access when payment fails
- [ ] Subscription cancellation removes access after expiry

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|---------|
| Products not loading | Ensure all product IDs match exactly. Check `ProductIds.allProductIds` in `purchase_service.dart`. |
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
| `lib/services/purchase_service.dart` | Product IDs, purchase flow, store integration |
| `lib/services/backend_service.dart` | Backend API calls for verification and sync |
| `lib/presentation/bloc/premium/premium_cubit.dart` | Premium state management, purchase handling |
| `lib/presentation/bloc/premium/premium_state.dart` | Premium tiers, owned content tracking |
| `lib/presentation/bloc/premium/battle_pass_cubit.dart` | Battle Pass state and tier progression |
| `lib/models/premium_cosmetics.dart` | Snake skins, trail effects, cosmetic bundles |
| `lib/models/snake_coins.dart` | Coin packs, pricing, coin economy |
| `lib/models/premium_power_up.dart` | Premium power-ups and power-up bundles |
| `lib/models/tournament.dart` | Tournament model with entry system |
| `lib/screens/theme_selector_screen.dart` | Theme purchase UI |
| `lib/screens/cosmetics_screen.dart` | Cosmetics store UI |
| `lib/screens/battle_pass_screen.dart` | Battle Pass purchase and progression UI |
