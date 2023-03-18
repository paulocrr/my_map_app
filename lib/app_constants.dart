import 'package:latlong2/latlong.dart';

class AppConstants {
  static const mapBoxToken =
      'pk.eyJ1IjoicGF1bG9jcnIiLCJhIjoiY2tvNTNxenprMDhsdTJwcW9zOWFjZ2oxMSJ9.vXcp1bO8ExxsAbwfuYIdbQ';
  static const mapBoxStyleId = 'clfder68a000f01nt2j7a96qa';
  static const mapBoxUrl =
      'https://api.mapbox.com/styles/v1/paulocrr/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}';

  static final initialLocation = LatLng(51.5090214, -0.1982948);
}
