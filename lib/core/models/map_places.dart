class MapPlaces{
  final String? placeId;
  final String? description;

  final dynamic name;

  MapPlaces({
    required this.placeId,
    required this.description,
    required this.name,
  });
  static MapPlaces fromJSON(dynamic map) {
    var json = map as Map<String, dynamic>;

    return MapPlaces(
      placeId: json["placePrediction"]["placeId"],
      description: json["placePrediction"]["structuredFormat"]["secondaryText"]
      ["text"],
      name: json["placePrediction"]["structuredFormat"]["mainText"]["text"],
    );
  }
}
