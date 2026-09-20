# TASK: Board Theme system for LudoVibe (Flutter + Riverpod 2.6.1)

Shop mein user ek board theme khareede/select kare → wo theme game ke Ludo board par apply ho jaye (aur restart ke baad bhi yaad rahe).
**Game engine / dice / move rules ko bilkul mat chhedna.** Sirf board *rendering*, shop UI aur theme state par kaam karna hai.

## 0. Pehle ye karo (read-only)
1. Existing code inspect karo: board widget, token/pawn widget, home-base quadrant rendering, Shop module (models, coin balance, purchase flow), aur jahan persistent storage use ho rahi hai.
2. Existing board ko `classic` (free, default) theme ke taur par preserve karo — delete mat karo.
3. Existing coding style/patterns follow karo (Riverpod providers, folder structure).

## 1. Assets (already ready — `assets/themes/`)
```
assets/themes/<theme_id>/
  board.png      # 1024x1024, fully flattened board  ← game isi ko draw karega
  preview.png    # 512x512, shop card thumbnail
  layers/{background,frame,board,home,center,decor,effects}/*.png   # original separated layers (reference / future animations)
assets/themes/_unsorted/         # unidentified small vectors — ignore
themes_manifest.json             # single source of truth
```
Theme ids: `dessert, enchanted, cloudy, warrior, lightning, lucky_chest, frostfire, paint, storm_lightning, indigo_wallpaper, letter_from_spring`

- `pubspec.yaml` mein `assets/themes/` ke har `<theme_id>/` folder ko register karo (sirf `board.png` + `preview.png` chahiye — `layers/` ko pubspec mein add na karo, warna app size bekar barhega; sirf dev reference hai) aur `themes_manifest.json` ko bhi.
- Har theme ki `board.png` ek square image hai. **Har theme mein path 15x15 grid hai**, lekin grid image ke andar thodi inset ke saath hoti hai; exact rect manifest ke `grid` field mein fraction mein hai.

## 2. Manifest format (already generated)
```json
{ "id":"dessert","name":"Dessert","board":"assets/themes/dessert/board.png","preview":"...",
  "grid":{"left":0.06,"top":0.06,"size":0.8757,"cells":15},
  "seatColors":{"tl":"#5B3A24","tr":"#F2E7D3","bl":"#F27A96","br":"#E39B2D"},
  "homeSlots":{"slots":[[1.5,1.5],[4.5,1.5],[1.5,4.5],[4.5,4.5]]} }
```
- `grid.left/top/size` board ki side ka fraction hain.
- `seatColors` = us theme ke 4 home quadrants ka rang (tl/tr/bl/br). Ye "suggested" values hain; token tint ke liye use karo, aur ek jagah (manifest) se tweak ho sakein.
- `homeSlots` = 6x6 home block ke andar 4 token slots, cell units mein (block ke top-left se). Har theme ke liye default 2x2 hai; agar kisi theme mein slots thode off dikhein to manifest mein per-theme override do.

## 3. Data model
```dart
class LudoTheme {
  final String id, name, boardAsset, previewAsset;
  final Rect grid;               // left, top, size as fractions (0..1)
  final Map<Seat, Color> seatColors;   // Seat = tl,tr,bl,br
  final List<Offset> homeSlots;  // in cell units
  final int price;               // shop price, 0 = free
}
```
- `ThemeRepository` (loads `themes_manifest.json` once via `rootBundle`) → `List<LudoTheme>`.
- Prices manifest mein nahi hain: ek `themePrices` map (const) banao (classic = 0, baaki placeholder e.g. 500–2000 coins) — existing Shop currency/economy use karo.
- Riverpod providers:
  - `themeCatalogProvider` (FutureProvider) — sab themes.
  - `ownedThemesProvider` (Notifier<Set<String>>) — persisted; default `{classic}`.
  - `selectedThemeIdProvider` (Notifier<String>) — persisted; default `classic`.
  - `activeThemeProvider` — selected theme resolve karke deta hai (fallback classic).
- Persistence: jo storage app already use karti hai (SharedPreferences/Hive/backend) wahi use karo. Keys: `owned_theme_ids`, `selected_theme_id`.

## 4. Shop UI
- Shop mein "Board Themes" section/tab: grid of cards → `preview.png`, naam, price chip.
- Card state: **Buy** (price) → **Owned / Apply** → **Applied** (checkmark).
- Buy: existing coin balance check + deduct (same flow jo baaki Shop items use karte hain) → `ownedThemes` mein add → success toast. Insufficient coins par existing "not enough coins" behavior.
- Apply: `selectedThemeId` set karo → turant board update. Tap par ek fullscreen **preview dialog** (large `board.png`) with Buy/Apply button.
- Preview/Apply ke waqt `precacheImage(AssetImage(board), context)` karo taake flicker na ho.

## 5. Board rendering (core part)
Board widget ko theme-driven banao. Board ka side = `S` (LayoutBuilder se square).
```dart
final g = theme.grid;                       // fractions
final origin = Offset(g.left * S, g.top * S);
final cell = (g.size * S) / 15;
Offset cellCenter(int col, int row) => origin + Offset((col + .5) * cell, (row + .5) * cell);
```
- `Stack`: `Image.asset(theme.boardAsset, fit: BoxFit.fill, filterQuality: FilterQuality.medium)` bottom par, uske upar tokens/highlights/dice UI. `RepaintBoundary` lagao.
- **Existing engine ka 15x15 (col,row) coordinate mapping as-is use karo** — sirf pixel conversion `cellCenter` se karo. Purane tile-based/painted board ko theme != classic hone par skip karo (classic ke liye purana rendering rakho).
- Home tokens: quadrant ka 6x6 block origin = (0,0) tl, (9,0) tr, (0,9) bl, (9,9) br (cell units). Slot i ka center = blockOrigin + homeSlots[i] → `origin + that * cell`.
- Tokens ko seat ke hisaab se `seatColors[seat]` se tint/color karo (existing token asset agar colored hai to theme ke seat color ke saath recolor/`ColorFiltered`, ya token ko simple 3D dot/pawn style mein us color se draw karo). Important: **player ka rang = uss quadrant ka rang jahan wo baitha hai**, warna board aur tokens ka rang match nahi karega.
- Agar game current player ko neeche dikhane ke liye board rotate karta hai, to board image aur tokens ko ek hi transform ke andar rakho (Transform.rotate ke andar poora Stack).
- Path highlights / safe-cell markers / dice ki jagah existing logic se hi aaye; sirf coordinates `cellCenter` se lo.

## 6. Debug & QA (zaroori)
- Debug-only "Theme Gallery" screen: sab 11 themes ko cycle karo, 15x15 grid lines overlay toggle ke saath, aur har quadrant mein 4 dummy tokens dikhao — alignment verify karne ke liye.
- Unit test: `cellCenter` math (15 cells, corner cells) — har theme ke liye grid rect sanity (`left+size <= 1`).
- Test cases: buy → apply → app restart → theme persist; insufficient coins; classic par wapas switch; 2P/3P/4P games mein theme same dikhe; low-end device par memory (sirf active theme ki `board.png` memory mein rakho, baaki evict).

## 7. Deliverable
- Naye files: theme model/repository/providers, shop theme section, board widget changes, debug gallery, tests.
- Ek chhota summary do: kaunse files change hue, koi assumption jo maine manifest mein tweak karni pare.
