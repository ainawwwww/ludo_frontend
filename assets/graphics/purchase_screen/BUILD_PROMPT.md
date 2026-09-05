# Prompt — Purchase Screen (LudoVibe, Flutter)

Build a **Purchase Screen** for my Flutter Ludo game app (LudoVibe). It's a bottom-sheet / full-screen modal with a dark navy-blue theme, 3 tabs, and rounded card UI. Follow the reference screenshots pixel-by-pixel for layout, spacing, colors, and font sizes.

## Structure

### 1. Header (shared across all 3 tabs)
- Top-left: player avatar with a purple crown badge overlay + a small "PRO" pill and a thin gradient XP/level bar underneath.
- Top-right: coin balance chip (coin icon + "33k"), diamond balance chip (diamond icon + "33"), and a close (X) button.
- Assets: `common/icon_coin_header.png`, `common/icon_diamond_header.png`, `common/btn_close.png`, `common/bar_xp_progress.png`, `common/badge_pro_pill.png`.

### 2. Tab bar
3 segmented tabs: **Gold | Diamond | Subscription**, pill-shaped container, active tab gets a gradient-filled pill background, inactive tabs are transparent/outlined.
- Assets: `common/tab_label_*.png` (or just render as styled `Text`), `common/tab_pill_bg_active_gold.png`, `common/tab_pill_bg_active_purple.png`.
- Recreate the pill shapes with `BoxDecoration` + `LinearGradient` — don't use the flat rectangle PNGs.

### 3. Gold Tab / Diamond Tab (same layout, different data)
- **Top banner card**: light lavender rounded card with a treasure chest illustration on the left and a speech-bubble on the right showing 3 small reward-preview icons (ring +1, diamond +150, gold +150000) plus headline "First Reward Recharge" and subtext "Recharge any amount to get bonus rewards".
  - Assets: `gold_tab/banner_chest_bubble_bg.png`, `gold_tab/text_first_reward_title.png`, `gold_tab/text_recharge_subtitle.png`, `gold_tab/icon_reward_preview_chest.png`, `gold_tab/text_reward_qty_plus*.png`.
- **Package grid**: 2 columns × 3 rows of package cards. Each card = orange/gold rounded chip showing the amount (icon + number, e.g. "33k") at top, and a purple "USD 0.99" price pill/button at the bottom. Some cards carry a small ribbon tag in the top-right corner: HOT (flame, red-orange), POPULAR (pink ribbon), BEST (red ribbon).
  - Gold tier icons in order: `tier1_icon_33k_coins.png` → `tier6` (17.0M) — files in `gold_tab/`.
  - Diamond tier icons in order: `tier1_icon_300_diamonds_small.png` → `tier6_icon_161_7k_chest_bag_best.png` — files in `diamond_tab/`.
  - Tags: `tags_badges/badge_hot_flame.png`, `tags_badges/ribbon_bg_pink_popular.png` + `tag_text_popular.png`, `tags_badges/ribbon_bg_red_best.png` + `tag_text_best.png`.
- **Footer link**: "Gold Details" text button under the grid (`gold_tab/text_gold_details_link.png`, or just styled `Text` + `GestureDetector`).

### 4. Subscription Tab
- **Toggle selector** near top: two small pill buttons "🛡 KNIGHT" / "🛡 BARON" — active one highlighted. Small shield icons: `subscription_tab/icon_knight_shield_small.png`, `icon_baron_shield_small.png`.
- **Hero section**: dark navy podium background (`subscription_tab/bg_panel_podium.png`) with a radial glow behind a large emblem (`emblem_knight_large.png` or `emblem_baron_large.png` depending on selected tier), plus left/right chevron arrows (`nav_chevron_left.png` / `nav_chevron_right.png`) to swipe between Knight and Baron.
- **"Exclusive Privileges" section**: heading + a 2-column grid of 6 privilege rows, each = icon + short label:
  1. `privilege1_icon_exclusive_logo_display.png` — Exclusive logo and Display
  2. `privilege2_icon_vip_room.png` — The right to create or join a VIP room
  3. `privilege3_icon_daily_benefits.png` — Subscribe to get daily benefits
  4. `privilege4_icon_priority_friendlist.png` — Priority display on the friend list
  5. `privilege5_icon_front_row.png` — Front row on the online user list in room
  6. `privilege6_icon_profile_frame.png` — Use exclusive profile frame to decorate your profile photo
- **Bottom subscribe bar**: a lighter purple bar showing 3 small reward chips (coins/diamonds/chest count for the day) + a big orange "Subscribe for a month — $11.99" (Knight) or "$39.99" (Baron) button, and a small "Manage Subscriptions" link.
  - Assets: `price_knight_11_99.png` / `price_baron_39_99.png`, `label_daily_coins_*`, `label_daily_diamonds_*`, `label_daily_chest_qty_1.png`, `text_subscribe_for_month.png`, `text_manage_subscriptions.png`.

## Technical requirements
- Flutter 3.x, use `TabController`/`TabBarView` or a custom segmented control for the 3 tabs — match whatever pattern the rest of LudoVibe already uses.
- Package all image assets under `assets/purchase_screen/<subfolder>/...` matching the folder structure I'm giving you, and register them in `pubspec.yaml`.
- Build reusable widgets: `PackageCard` (gold/diamond grid item), `PrivilegeRow`, `TierToggleButton`, `SubscribeFooterBar` — don't hardcode 6 copies of the same card.
- Numbers (coin/diamond amounts, prices) should come from a simple data model / list, not be hardcoded per-widget, so backend values can be swapped in later.
- Flat gradient rectangles and pill shapes (tab backgrounds, dividers) → build with `BoxDecoration`/`LinearGradient` in code, not as image assets.
- Keep it responsive for different phone widths (use `MediaQuery`/`LayoutBuilder`, avoid fixed pixel widths where possible).

Reference the 2 attached screenshots for exact colors, spacing, corner radii, and font weights.
