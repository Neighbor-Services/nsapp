class Place {
  final String? id;
  final double? lat;
  final double? lng;
  final String? name;

  Place({
    this.id,
    this.lat,
    this.lng,
    this.name,
  });

  static Place fromJson(dynamic map) {
    var json = map as Map<String, dynamic>;
    return Place(
      id: json["id"],
      lat: json["location"]["latitude"],
      lng: json["location"]["longitude"],
      name: json["displayName"]["text"],
    );
  }
}