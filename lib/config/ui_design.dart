/// Which UI this build ships: `living_board` (the redesign) or `classic`.
///
/// The ONLY design-specific line in the telemetry module. Every number the
/// design-metrics dashboard compares is tagged with this value — on the
/// session rows, on the feedback rows, in the `X-UI-Design` header of every
/// API request and as the `ui_design` Firebase user property — so the two
/// designs are split by a compile-time constant rather than by anything the
/// device could disagree about. The `classic` branch sets `'classic'` here and
/// nothing else changes. See docs/design-metrics/CONTRACT.md.
const String kUiDesign = 'living_board';
