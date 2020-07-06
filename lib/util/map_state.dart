import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voluntario/ui/widgets/marker_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MapState with ChangeNotifier {
  GoogleMapController get mapController => _mapController;
  Geolocator location = Geolocator();

  Set<Marker> get markers => _markers;
  BitmapDescriptor redIcon, greenIcon;
  GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng initialPosition;
  var position;

  MapState() {
    getUserLocation();
  }

  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    mapController.setMapStyle(
        '[{"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},{"featureType":"administrative","elementType":"geometry.fill","stylers":[{"color":"#d6e2e6"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#cfd4d5"}]},{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#7492a8"}]},{"featureType":"administrative.neighborhood","elementType":"labels.text.fill","stylers":[{"lightness":25}]},{"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#dde2e3"}]},{"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#cfd4d5"}]},{"featureType":"landscape.natural","elementType":"geometry.fill","stylers":[{"color":"#dde2e3"}]},{"featureType":"landscape.natural","elementType":"labels.text.fill","stylers":[{"color":"#7492a8"}]},{"featureType":"landscape.natural.terrain","stylers":[{"visibility":"off"}]},{"featureType":"poi","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry.fill","stylers":[{"color":"#dde2e3"}]},{"featureType":"poi","elementType":"labels.icon","stylers":[{"saturation":-100}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#588ca4"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#a9de83"}]},{"featureType":"poi.park","elementType":"geometry.stroke","stylers":[{"color":"#bae6a1"}]},{"featureType":"poi.sports_complex","elementType":"geometry.fill","stylers":[{"color":"#c6e8b3"}]},{"featureType":"poi.sports_complex","elementType":"geometry.stroke","stylers":[{"color":"#bae6a1"}]},{"featureType":"road","elementType":"labels.icon","stylers":[{"saturation":-45},{"lightness":10},{"visibility":"off"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#41626b"}]},{"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#c1d1d6"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#a6b5bb"}]},{"featureType":"road.highway","elementType":"labels.icon","stylers":[{"visibility":"on"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.fill","stylers":[{"color":"#9fb6bd"}]},{"featureType":"road.local","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"labels.icon","stylers":[{"saturation":-70}]},{"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#b4cbd4"}]},{"featureType":"transit.line","elementType":"labels.text.fill","stylers":[{"color":"#588ca4"}]},{"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#008cb5"}]},{"featureType":"transit.station.airport","elementType":"geometry.fill","stylers":[{"saturation":-100},{"lightness":-5}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#a6cbe3"}]}]');

    notifyListeners();
  }

  void getUserLocation() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    initialPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  Future<void> animateToUser() async {
    location
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.best)
        .then((userLocation) {
      animateToPosition(
          LatLng(userLocation.latitude, userLocation.longitude), 14.5);
    });
    notifyListeners();
  }

  void animateToPosition(LatLng pos, double zoom) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: zoom)));
    notifyListeners();
  }

  Future<void> markersDialog(
      DocumentSnapshot document, BuildContext context, String userId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          titlePadding: EdgeInsets.only(top: 24.0, bottom: 16.0),
          contentPadding: EdgeInsets.only(top: 0.0),
          title: Text(
            'ACEITAR PEDIDO?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
          ),
          content: MarkerDialog(document, context, userId),
        );
      },
    );
  }
}
