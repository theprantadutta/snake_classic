# App Store IAP Review Screenshots — Upload Mapping

All product IDs are prefixed `com.pranta.snakeclassic.`

## ✅ Products that have a screenshot — upload these

| Product ID | Screenshot file |
|---|---|
| pro_monthly | 01_pro_subscriptions.png |
| pro_yearly | 01_pro_subscriptions.png |
| coin_pack_small | 02_coins.png |
| coin_pack_medium | 02_coins.png |
| coin_pack_large | 02_coins.png |
| coin_pack_mega | 02_coins.png |
| crystal_theme | 03_themes_1.png |
| cyberpunk_theme | 03_themes_1.png |
| space_theme | 03_themes_1.png |
| ocean_theme | 03_themes_2.png |
| desert_theme | 03_themes_2.png |
| forest_theme | 03_themes_2.png |
| premium_themes_bundle | 03_themes_1.png |
| skin_golden | 04_skins_1.png |
| skin_rainbow | 04_skins_1.png |
| skin_galaxy | 04_skins_1.png |
| skin_dragon | 04_skins_1.png |
| skin_electric | 04_skins_2.png |
| skin_fire | 04_skins_2.png |
| skin_ice | 04_skins_2.png |
| skin_shadow | 04_skins_2.png |
| skin_neon | 04_skins_3.png |
| skin_crystal | 04_skins_3.png |
| skin_cosmic | 04_skins_3.png |
| trail_particle | 05_trails_1.png |
| trail_glow | 05_trails_1.png |
| trail_rainbow | 05_trails_1.png |
| trail_fire | 05_trails_1.png |
| trail_electric | 05_trails_2.png |
| trail_star | 05_trails_2.png |
| trail_cosmic | 05_trails_2.png |
| trail_neon | 05_trails_2.png |
| trail_shadow | 05_trails_3.png |
| trail_crystal | 05_trails_3.png |
| trail_dragon | 05_trails_3.png |
| tournament_silver | 07_tournament_silver.png |
| tournament_gold | 08_tournament_gold.png |

(Pick whichever single screenshot from a product's section shows that product; Apple allows reusing one screenshot across products in the same section.)

## ⚠️ Products with NO in-app purchase path — DELETE from App Store Connect (or remove from this submission)

These cannot be screenshotted because nothing in the app actually sells them. A registered IAP that can't be purchased risks an "IAP not functional" rejection, so the safe move is to delete them from App Store Connect unless you add UI first.

| Product ID | Why |
|---|---|
| tournament_bronze | Entry tier for Daily Challenge, but the backend currently seeds daily challenges as FREE — no purchase prompt ever appears. Keep ONLY if you plan to charge for daily entries. |
| championship_entry | Defined as a constant only; never passed to any purchase call. |
| tournament_vip_entry | Defined as a constant only; never passed to any purchase call. |
| battle_pass_season | Marked "Coming Soon — not registered on stores yet"; no purchase UI. |
| starter_pack | Cosmetic bundle model exists, but no purchase UI anywhere. |
| elemental_pack | Cosmetic bundle model exists, but no purchase UI anywhere. |
| cosmic_collection | Cosmetic bundle model exists, but no purchase UI anywhere. |
| ultimate_collection | Cosmetic bundle model exists, but no purchase UI anywhere. |

## 06_powerups_coins.png — reference only

Power-Ups are bought with in-game Snake Coins, NOT real money, so they are NOT App Store IAPs and need no review screenshot.
