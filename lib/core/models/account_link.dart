class AccountLink {
  final String url;
  final DateTime created;
  final DateTime expiresAt;

  AccountLink({
    required this.url,
    required this.created,
    required this.expiresAt,
  });

  static AccountLink fromJson(dynamic json) {
    return AccountLink(
      url: json["url"],
      created: DateTime.fromMillisecondsSinceEpoch(json["created"]),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json["expires_at"]),
    );
  }
}
