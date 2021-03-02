import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voluntario/ui/widgets/request_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/util/map_state.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class MapPage extends StatefulWidget {
  final Map userData;
  final Function homeVisibility;

  MapPage({Key key, @required this.userData, this.homeVisibility})
      : super(key: key);

  @override
  _MapPageState createState() => _MapPageState(userData);
}

class _MapPageState extends State<MapPage> {
  final PermissionHandler _permissionHandler = PermissionHandler();
  bool hasLocPermission = false;
  BitmapDescriptor redIcon, greenIcon;
  final Map userData;
  var pos;

  _MapPageState(this.userData);

  Set<Marker> markers = Set<Marker>();
  Location location = Location();
  GoogleMapController mapController;
  String _lastZoom;

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<void> getMarker(int size) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/green_icon.png', size);
    greenIcon = BitmapDescriptor.fromBytes(markerIcon);

    final Uint8List scndMarkerIcon =
        await getBytesFromAsset('assets/red_icon.png', size);
    redIcon = BitmapDescriptor.fromBytes(scndMarkerIcon);
  }

  void changeMarkerSize(CameraPosition position) {
    if (position.zoom.toStringAsFixed(3) != _lastZoom) {
      setState(() {
        getMarker(((position.zoom * position.zoom) / 1.8).round());
      });
      _lastZoom = position.zoom.toStringAsFixed(3);
    }
  }

  hasLocationPermission() async {
    hasLocPermission = await hasPermission(PermissionGroup.locationAlways);
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
        await _permissionHandler.checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    hasLocationPermission();
    getMarker(117);
  }

  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    return Stack(
      children: <Widget>[
        StreamBuilder(
          stream: Firestore.instance.collection('requests').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 5.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                      height: 30,
                      width: 30));
            } else {
              markers = Set<Marker>();

              for (int i = 0; i < snapshot.data.documents.length; i++) {
                DocumentSnapshot document = snapshot.data.documents[i];
                bool isPickerDismissed = false;

                if (document['dismissedPickers'] != null) if (document[
                        'dismissedPickers']
                    .contains(userData['userId'])) isPickerDismissed = true;

                if ((document['state'] == 1 && !isPickerDismissed) ||
                    (document['state'] == 2 &&
                        document['pickerId'] == userData['userId'])) {
                  Marker marker = Marker(
                      markerId: MarkerId(document.documentID),
                      position: LatLng(document['location'].latitude,
                          document['location'].longitude),
                      icon: document['state'] == 1 ? redIcon : greenIcon,
                      onTap: () {
                        if (document['state'] == 1) {
                          mapState.markersDialog(
                            document,
                            context,
                            userData['userId'],
                          );
                        } else {
                          showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) {
                              return RequestBottomSheet(
                                  document, widget.homeVisibility);
                            },
                          );
                        }
                      });
                  markers.add(marker);
                }
              }
              return hasLocPermission
                  ? mapState.initialPosition == null
                      ? Container(
                          alignment: Alignment.center,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Stack(
                          children: <Widget>[
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: mapState.initialPosition,
                                zoom: 14.5,
                              ),
                              onMapCreated: mapState.onCreated,
                              onCameraMove: changeMarkerSize,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              myLocationEnabled: true,
                              markers: markers,
                            ),
                            SafeArea(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: FloatingActionButton(
                                    mini: true,
                                    child: Icon(
                                      Icons.gps_fixed,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      mapState.animateToUser();
                                    },
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Favor permitir o acesso a localização"),
                          FlatButton(
                            child: Text("PERMITIR"),
                            onPressed: () async {
                              bool verified = await _requestPermission(
                                PermissionGroup.locationAlways,
                              );
                              if (verified) {
                                setState(() {
                                  hasLocPermission = true;
                                });
                                mapState.getUserLocation();
                              }
                            },
                          )
                        ],
                      ),
                    );
            }
          },
        ),
      ],
    );
  }
}
