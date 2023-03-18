import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_map_app/app_constants.dart';
import 'package:my_map_app/models/map_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final pageController = PageController();
  var selectedMarker = 0;
  var currentPlace = mapMarkers[0];
  final MapController mapController = MapController();
  var currentCenter = AppConstants.initialLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapBox'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 5,
              maxZoom: 18,
              zoom: 13,
              center: currentCenter,
            ),
            nonRotatedChildren: [
              AttributionWidget.defaultWidget(
                source: 'MapBox',
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
              ),
              MarkerLayer(
                markers: [
                  ...mapMarkers.asMap().entries.map((e) {
                    final index = e.key;
                    final value = e.value;

                    return Marker(
                      height: 40,
                      width: 40,
                      point: value.location,
                      builder: (_) {
                        return GestureDetector(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 500),
                            scale: selectedMarker == index ? 2 : 1,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: selectedMarker == index ? 1 : 0.7,
                              child: const Icon(Icons.place, size: 32),
                            ),
                          ),
                          onTap: () {
                            pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );

                            selectedMarker = index;
                            currentPlace = value;
                            currentCenter = value.location;

                            setState(() {});
                          },
                        );
                      },
                    );
                  }).toList()
                ],
              )
            ],
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 24,
            height: MediaQuery.of(context).size.height * 0.3,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (value) {
                selectedMarker = value;
                currentPlace = mapMarkers[value];
                currentCenter = currentPlace.location;
                _mapMove(currentCenter, 11.5);
                setState(() {});
              },
              itemCount: mapMarkers.length,
              itemBuilder: (_, index) {
                final item = mapMarkers[index];

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Informacion del lugar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        item.address,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < item.rating; i++)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                            )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mapMove(LatLng destination, double destinationZoom) {
    final latTween = Tween<double>(
      begin: mapController.center.latitude,
      end: destination.latitude,
    );

    final lngTween = Tween<double>(
      begin: mapController.center.longitude,
      end: destination.longitude,
    );

    final zoomTween = Tween<double>(
      begin: mapController.zoom,
      end: destinationZoom,
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(
      () {
        mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      },
    );

    animation.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          controller.dispose();
        }
      },
    );

    controller.forward();
  }
}
