import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_model.dart';
import 'location_service.dart';

class MapPage extends StatefulWidget {
  final List<LocationModel> locations;
  final LocationService service;

  const MapPage({super.key, required this.locations, required this.service});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _ctrl;

  Future<String?> _showLabelDialog() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Name this place'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. My Office'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Called every time user taps the map
  void _onMapTap(LatLng tapped) async {
    final label = await _showLabelDialog();
    if (label == null || label.isEmpty) return;

    await widget.service.saveLocation(tapped.latitude, tapped.longitude, label);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"$label" saved!')));
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.locations.isNotEmpty
        ? LatLng(widget.locations.last.lat, widget.locations.last.lng)
        : const LatLng(-7.2575, 112.7521);

    return Scaffold(
      appBar: AppBar(title: const Text('Tap map to add a place')),
      body: GoogleMap(
        onMapCreated: (c) => _ctrl = c,
        initialCameraPosition: CameraPosition(target: center, zoom: 13),
        onTap: _onMapTap,
        myLocationEnabled: true,
        markers: widget.locations
            .map(
              (loc) => Marker(
            markerId: MarkerId(loc.id),
            position: LatLng(loc.lat, loc.lng),
            infoWindow: InfoWindow(title: loc.label),
          ),
        )
            .toSet(),
      ),
    );
  }
}
