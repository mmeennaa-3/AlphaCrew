import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tourguide/features/city_page.dart';

class MapPage extends StatelessWidget {
  final LatLng? center;

  const MapPage({super.key, this.center});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center ?? LatLng(30.0444, 31.2357),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          if (center != null)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CityPage(center: center!),
                  ),
                );
              },
              child: MarkerLayer(
                markers: [
                  Marker(
                    point: center!, // الموقع فقط
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
