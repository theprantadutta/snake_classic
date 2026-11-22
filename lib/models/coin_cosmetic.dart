/// A cosmetic the server sells for coins (`coin_cosmetics` in
/// premium-content, or GET /cosmetics/coin-catalog). Prices come from the
/// server only; the client never hardcodes them.
class CoinCosmeticOffer {
  const CoinCosmeticOffer({
    required this.type,
    required this.id,
    required this.price,
    required this.owned,
  });

  /// `skin`, `trail` or `theme`.
  final String type;

  /// Stored form: skins bare (`fire`), trails prefixed (`trail_glow`).
  /// Matches [SnakeSkinType.id] / [TrailEffectType.id].
  final String id;
  final int price;
  final bool owned;

  CoinCosmeticOffer copyWith({bool? owned}) => CoinCosmeticOffer(
    type: type,
    id: id,
    price: price,
    owned: owned ?? this.owned,
  );

  static CoinCosmeticOffer? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final type = raw['cosmetic_type'];
    final id = raw['cosmetic_id'];
    final price = raw['coin_price'];
    if (type is! String || id is! String || price is! num || price <= 0) {
      return null;
    }
    return CoinCosmeticOffer(
      type: type,
      id: id,
      price: price.toInt(),
      owned: raw['owned'] == true,
    );
  }

  /// Parses a server list, dropping malformed entries. Null when [raw] is
  /// not a list at all (the field was absent: keep what we had).
  static List<CoinCosmeticOffer>? parseList(Object? raw) {
    if (raw is! List) return null;
    return raw.map(tryParse).whereType<CoinCosmeticOffer>().toList();
  }

  @override
  bool operator ==(Object other) =>
      other is CoinCosmeticOffer &&
      other.type == type &&
      other.id == id &&
      other.price == price &&
      other.owned == owned;

  @override
  int get hashCode => Object.hash(type, id, price, owned);
}
