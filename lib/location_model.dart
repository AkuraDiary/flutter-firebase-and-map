class LocationModel {
  final String id;
  final String label;
  final double lat;
  final double lng;
  final int timestamp;

  LocationModel({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  // Data Model -> Json
  Map<String, dynamic> toMap() => {
    'label': label,
    'lat': lat,
    'lng': lng,
    'time': timestamp,
  };

  // Json -> DataModel
  factory LocationModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return LocationModel(
      id: id,
      label: map['label'] ?? 'Unknown',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      timestamp: map['time'] ?? 0,
    );
  }
}
