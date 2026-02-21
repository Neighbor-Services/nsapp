class CreditCard {
  final int? month;
  final int? year;
  final String? number;
  final String? cvc;

  // final String? city;
  final String? name;

  // final String? country;
  // final String? state;
  // final String? zipCode;

  CreditCard({
    this.cvc,
    this.month,
    this.number,
    this.year,
    // this.city,
    this.name,
    // this.country,
    // this.state,
    // this.zipCode,
  });

  Map<String, dynamic> toJson() {
    return {
      "card[number]": number,
      "card[exp_month]": month.toString(),
      "card[exp_year]": year.toString(),
      "card[cvc]": cvc,
      // "card[address_city]": city,
      // "card[address_country]": country,
      // "card[address_state]": state,
      // "card[address_zip]": zipCode,
      "card[currency]": "usd",
      "card[name]": name,
    };
  }
}
