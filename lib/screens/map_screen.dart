import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_map_app/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapBox'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              minZoom: 5,
              maxZoom: 18,
              zoom: 13,
              center: LatLng(51.5090214, -0.1982948),
            ),
            nonRotatedChildren: [
              AttributionWidget.defaultWidget(
                source: 'Mapbox',
                onSourceTapped: () async {},
              )
            ],
            children: [
              TileLayer(
                urlTemplate: AppConstants.mapBoxUrl,
                additionalOptions: const {
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxToken,
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
