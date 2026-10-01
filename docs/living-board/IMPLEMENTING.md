# Implementing a screen on the Living Board

How the redesign is built, for anyone (person or agent) bringing another
screen into the system. Read `design/DESIGN_SPEC.md` and `design/COPY.md`
first; the reference renders are in `screens/`.

## The pieces (`lib/widgets/lb/`, import `lib/widgets/lb/lb.dart`)

| Need | Use |
|---|---|
| A page | `LBScaffold(title:, subtitle:, trailing:, children:/body:, bottom:, banner:)` — grid board, header (back block + cell-font title + subtitle), scrolling body padded to `context.lbGutter`, banner slot |
| Colours | `context.lb` (`LBPalette`: board, deep, lime, head, ink, inkMuted, inkDim, gridLine, blockFill, blockStroke, cellOff, wall, onLime) and `LB.*` constants (gold, bonk, rarity, apple). Never hard-code theme colours; all 10 themes re-skin through the palette |
| Type | `LBText.label / body / button / value(context.lb, color:, size:)` — JetBrains Mono. Numbers and titles that are "loud" use `LBCellText` (cell font) |
| Surfaces | `LBBlock(kind:, onTap:, height:, padding:, alignment:, selected:)` — kinds: outline (default), fill (ONE per screen, the primary action), gold (rewards), goldFill (Pro CTA only), danger, muted, dashed, sheet. Children inherit a readable text colour: `LBBlock.foregroundOf(kind, p)` |
| Rows | `LBRow(title:, subtitle:, leading:, trailing:, onTap:, kind:)` |
| Choices | `LBChoiceBlock(title:, line:, selected:, onTap:)` |
| Icons | `LBPixelIcon(LBIcon.x, cell: 3–6, color:)` — replaces Material icons. 36 icons: apple back bolt buzz calendar chart check coin copy crown eye film flame friends gear gift grid heart hourglass invite lock music next pause play plus shield skull sound star swords target trophy tv user x |
| Progress | `LBCellsBar(count:, value:, cell:, color:, offColor:, colorAt:)` |
| Toggle / chip / section label | `LBToggle`, `LBChip(label:, kind:, icon:)`, `LBSectionLabel(text, trailing:)` |
| Header actions | `LBIconBlock(icon:, onTap:, semanticLabel:)` (2×2 cells) |
| Sheets / dialogs | `showLBSheet(context:, title:, builder:)`, `showLBDialog(context:, title:, body:, primaryLabel:, onPrimary:, secondaryLabel:)` |
| Logo | `LBCellSMark(size:)` |
| Feedback | `LBFeedback.tap()` / `.back()` — `LBBlock` already does this |
| Layout units | `context.lbCell` (20 dp × uiScale), `context.lbGutter` (content side padding, tablet-aware) |

Look at `lib/screens/run_setup_screen.dart`, `home_screen.dart`,
`game_over_screen.dart` and `lib/widgets/pause_overlay.dart` for the idiom.

## Rules that are not style

- **Keep every behaviour.** This is a reskin and a UX consolidation. Keep
  every callback, cubit/provider/service call, analytics event, navigation,
  `TapArmGuard`, `PopScope`, semantics and async-context capture exactly as
  it is. Replace the presentation (widgets, colours, fonts, Material icons),
  not the logic. When in doubt, keep it.
- **Ads**: never change an ad call, placement string, cadence, gate or
  guard. Rewarded buttons stay always-tappable (`showRewardedOrWait`).
  Restyle the surfaces around ads only. Banner gaps stay as they are.
- **Store**: never add, rename, remove or re-price a product; prices come
  from the store SDK. Restore purchases stays reachable.
- **Copy**: no hard-coded user-facing strings. Reuse an existing ARB key
  where it fits; add new ones (prefix `lb`) with
  `python tools/lb_add_strings.py my_strings.json` (see the script's
  docstring — it locks, merges into `app_en.arb` and runs gen-l10n). Voice
  rules are in `design/COPY.md`: primary labels UPPERCASE and plain, jokes
  only in secondary lines, never on money, account or privacy copy.
- **Tablets**: `lib/utils/responsive.dart`; phone layouts must be a no-op
  (`context.lbGutter` already includes `sideInset()`).
- **Accessibility**: ≥ 48 dp hit targets, `Semantics` labels on icon-only
  controls, no information carried by colour alone.
- `flutter analyze` must be clean for the files you touched. Remove imports
  you no longer use. Do not delete shared widgets other screens may still
  use; list them instead.
