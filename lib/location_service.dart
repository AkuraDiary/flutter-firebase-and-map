import 'package:apb_maps_and_firebase/location_model.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  final _ref = FirebaseDatabase.instance.ref("locations");

  // to save a location
  Future<void> saveLocation(double lat, double lng, String label) async {
    await _ref.push().set({
      'lat': lat,
      'lng': lng,
      'label': label,
      'time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // to get all locations
  Stream<List<LocationModel>> getLocations() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.entries
          .map((e) => LocationModel.fromMap(e.key.toString(), e.value as Map))
          .toList();
    });
  }
}
