import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_map_app/app_constants.dart';
import 'package:my_map_app/models/map_marker.dart';
import 'package:my_map_app/services/places_service.dart';
import 'package:my_map_app/utilities/screen_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<MapMarker> mapMarkers = [];
  final pageController = PageController();
  var selectedMarker = 0;
  late MapMarker? currentPlace;
  final MapController mapController = MapController();
  var currentCenter = AppConstants.initialLocation;
  final service = PlacesService();
  Stream<QuerySnapshot<Map<String, dynamic>>>? placesStream;
  var screenState = ScreenState.idle;

  @override
  void initState() {
    super.initState();
    currentPlace = mapMarkers.isEmpty ? null : mapMarkers.first;
    getPlacesSteam();
  }

  void getPlacesSteam() {
    setState(() {
      screenState = ScreenState.loading;
    });
    service.getPlaces().fold((l) {
      setState(() {
        screenState = ScreenState.error;
      });
    }, (r) {
      placesStream = r;
      setState(() {
        screenState = ScreenState.completed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (screenState.isLoading()) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (screenState.isError() || placesStream == null) {
      return const Scaffold(
        body: Center(
          child: Text('Ocurrio un error'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MapBox'),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: placesStream,
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              if (data != null) {
                final List<MapMarker> result = [];
                data.forEach((element) {
                  final elementData = element.data();
                  final marker =
                      MapMarker.fromMap(elementData as Map<String, dynamic>);

                  result.add(marker);
                });

                mapMarkers = result;
              }
              return Stack(
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                      opacity:
                                          selectedMarker == index ? 1 : 0.7,
                                      child: const Icon(Icons.place, size: 32),
                                    ),
                                  ),
                                  onTap: () {
                                    pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 500),
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
                        currentCenter = currentPlace != null
                            ? currentPlace!.location
                            : AppConstants.initialLocation;
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
                          child: ListView(
                            padding: const EdgeInsets.all(16.0),
                            children: [
                              const Text(
                                'Informacion del lugar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (item.image != null)
                                Image.network(
                                  item.image!,
                                  height: 100,
                                  width: 100,
                                ),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
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
              );
            }),
      );
    }
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
