import 'package:apb_maps_and_firebase/location_model.dart';
import 'package:apb_maps_and_firebase/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = LocationService();
  final _labelCtrl = TextEditingController();
  List<LocationModel> _locations = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // listen to firebase stream
    _service.getLocations().listen((locations) {
      setState(() {
        _locations = locations;
      });
    });
  }

  Future<void> _saveCurrentLocation() async {
    // check request & permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location Permission Denied")),
        );
        return;
      }
    }

    setState(() {
      _loading = true;
    });

    // get current position
    final pos = await Geolocator.getCurrentPosition();

    // save to firebase
    await _service.saveLocation(
      pos.latitude,
      pos.longitude,
      _labelCtrl.text.isEmpty ? "Lokasi Saya" : _labelCtrl.text,
    );
    _labelCtrl.clear();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Saver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MapPage(locations: _locations, service: _service,)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _labelCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Location label (optional)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _saveCurrentLocation,
                  icon: _loading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.my_location),
                  label: const Text('Save GPS'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (_, i) {
                final loc = _locations[i];
                return ListTile(
                  leading: const Icon(Icons.location_pin, color: Colors.red),
                  title: Text(loc.label),
                  subtitle: Text(
                    '${loc.lat.toStringAsFixed(4)}, '
                        '${loc.lng.toStringAsFixed(4)}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
