import 'package:latlong2/latlong.dart';

class MapMarker {
  final String? image;
  final String title;
  final String address;
  final LatLng location;
  final int rating;

  MapMarker({
    this.image,
    required this.title,
    required this.address,
    required this.location,
    required this.rating,
  });

  factory MapMarker.fromMap(Map<String, dynamic> map) => MapMarker(
        image: map['image'],
        title: map['title'],
        address: map['address'],
        location: LatLng(map['location'].latitude, map['location'].longitude),
        rating: map['rating'],
      );
}


// MapMarker(
    //     title: 'Alexander The Great Restaurant',
    //     address: '8 Plender St, London NW1 0JT, United Kingdom',
    //     location: LatLng(51.5382123, -0.1882464),
    //     rating: 4),
    // MapMarker(
    //     title: 'Mestizo Mexican Restaurant',
    //     address: '103 Hampstead Rd, London NW1 3EL, United Kingdom',
    //     location: LatLng(51.5090229, -0.2886548),
    //     rating: 5),
    // MapMarker(
    //     title: 'The Shed',
    //     address: '122 Palace Gardens Terrace, London W8 4RT, United Kingdom',
    //     location: LatLng(51.5090215, -0.1959988),
    //     rating: 2),
    // MapMarker(
    //     title: 'Gaucho Tower Bridge',
    //     address: '2 More London Riverside, London SE1 2AP, United Kingdom',
    //     location: LatLng(51.5054563, -0.0798412),
    //     rating: 3),
    // MapMarker(
    //   title: 'Bill\'s Holborn Restaurant',
    //   address: '42 Kingsway, London WC2B 6EY, United Kingdom',
    //   location: LatLng(51.5077676, -0.2208447),
    //   rating: 4,
    // ),
