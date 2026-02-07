class SubscriptionPlan {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? currency;
  final String? formattedPrice;
  final List<String>? features;
  final String? stripePriceId;
  final String? stripeProductId;
  final int? displayOrder;
  final String? tier;
  final String? interval;

  SubscriptionPlan({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.formattedPrice,
    this.features,
    this.stripePriceId,
    this.stripeProductId,
    this.displayOrder,
    this.tier,
    this.interval,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      currency: json['currency'],
      formattedPrice: json['formatted_price'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      stripePriceId: json['stripe_price_id'],
      stripeProductId: json['stripe_product_id'],
      displayOrder: json['display_order'],
      tier: json['tier'],
      interval: json['interval'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'formatted_price': formattedPrice,
      'features': features,
      'stripe_price_id': stripePriceId,
      'stripe_product_id': stripeProductId,
      'display_order': displayOrder,
      'tier': tier,
      'interval': interval,
    };
  }
}
