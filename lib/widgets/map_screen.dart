// ignore_for_file: use_key_in_widget_constructors, avoid_print, prefer_typing_uninitialized_variables, unused_local_variable, library_prefixes, must_be_immutable

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;
import 'dart:math' as Math;
import 'package:permission_handler/permission_handler.dart' as permission;

class LocationInput extends StatefulWidget {
  var appBarSize;
  var kGooglePlex;
  var padding;

  LocationInput({this.appBarSize, this.kGooglePlex, this.padding});

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? tabController;
  String? previewImage;
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? locationData;
  Set<Polyline>? lines;
  List<String> paths = [
    "assets/compass.jpg",
    "assets/compass1.jpeg",
    "assets/compass2.jpeg",
    "assets/compass3.png",
    "assets/compass4.jpeg"
  ];
  var quiblaCheck = false;
  var path = "assets/compass.jpg";

  List<Marker> _markers = [
    Marker(
      onTap: () {},
      markerId: const MarkerId("1"),
      position: const LatLng(21.42262271669748, 39.826197083199034),
      infoWindow: InfoWindow(
        title: "Title",
        snippet: "something",
        onTap: () {},
      ),
    ),
  ];
  CompassEvent? _lastRead;

  PolylinePoints polylinePoints = PolylinePoints();
  Set<Circle>? circles;
  Timer? timer;
  List<LatLng> polylineCoordinates = [];
  var degree;

  Future<void> getCurrentLocation() async {
    await permission.Permission.locationWhenInUse.request();
    var status = await permission.Permission.locationWhenInUse.status;
    if (Platform.isIOS) {
      _hasPermissions = true;
      final locData = await Location().getLocation();
      locationData = LatLng(locData.latitude!, locData.longitude!);
      lines = {
        Polyline(
          points: [
            locationData!,
            const LatLng(21.42262271669748, 39.826197083199034)
          ],
          color: Colors.blue,
          width: 3,
          polylineId: const PolylineId("line_one1"),
        )
      };
      if (tabController!.index == 0) {
        setState(() {});
      }
    } else {
      if (status.isGranted || status.isLimited) {
        _hasPermissions = true;
        final locData = await Location().getLocation();
        locationData = LatLng(locData.latitude!, locData.longitude!);
        lines = {
          Polyline(
            points: [
              locationData!,
              const LatLng(21.42262271669748, 39.826197083199034)
            ],
            color: Colors.blue,
            width: 3,
            polylineId: const PolylineId("line_one1"),
          )
        };
        if (tabController!.index == 0) {
          setState(() {});
        }
      }
    }
  }

  readCompass() async {
    // print("")
    final CompassEvent tmp = await FlutterCompass.events!.first;
    _lastRead = tmp;
    final GoogleMapController controller = await _controller.future;
    // var location = await locData.first;
    var zoom = await controller.getZoomLevel();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: quiblaCheck
          ? const LatLng(21.42262271669748, 39.826197083199034)
          : locationData!,
      zoom: zoom,
      bearing: tmp.heading!,
    )));

    setState(() {});
    if (_lastRead!.heading! <= 6.0 && _lastRead!.heading! >= -6.0) {

    }
  }

  LatLngBounds? bounds;

  locationChnaged() async {
    if (_hasPermissions) {
      final CompassEvent tmp = await FlutterCompass.events!.first;
      final locData = Location().onLocationChanged;
      final GoogleMapController controller = await _controller.future;
      var location = await locData.first;
      var zoom = await controller.getZoomLevel();
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: quiblaCheck
            ? const LatLng(21.42262271669748, 39.826197083199034)
            : locationData!,
        zoom: zoom,
        bearing: tmp.heading!,

      ),
      ),
        // animationDuration: const Duration(milliseconds: 100),
      );
      lines = {
        Polyline(
          points: [
            LatLng(location.latitude!, location.longitude!),
            const LatLng(21.42262271669748, 39.826197083199034)
          ],
          color: Colors.blue,
          width: 3,
          polylineId: const PolylineId("line_one1"),
        )
      };
      double dLon = (39.826197083199034 - location.longitude!);
      double y = Math.sin(dLon) * Math.cos(21.42262271669748);
      double x = Math.cos(location.latitude!) * Math.sin(21.42262271669748) -
          Math.sin(location.latitude!) *
              Math.cos(21.42262271669748) *
              Math.cos(dLon);
      double brng = Math.atan2(y, x);
      degree = (360 - ((brng + 360) % 360));
      _markers.removeWhere(
              (m) => m.markerId.value == "2");
      _markers.add(        Marker(
        // icon: BitmapDescriptor.fromBytes(
        //  Icon(Icons.my_location)
        // ),
        // Icon(Icons.my_location,color: Colors.blue,),
        onTap: () {},
        markerId: const MarkerId("2"),
        position:  LatLng(location.latitude!, location.longitude!),
        infoWindow: InfoWindow(
          title: "Title",
          snippet: "something",
          onTap: () {},
        ),
      ),
      );

      print("------------------$degree");
      setState(() {});
    }
  }

  @override
  void initState() {
    getIcon();
    zoom = 10;
    super.initState();
    final locData = Location().getLocation();
    getCurrentLocation();
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
    //   if (tabController!.index == 0) {
    //     readCompass();
    //   }
    // });
    //   Location().requestPermission().then((permissionStatus) {
    //     if (permissionStatus == PermissionStatus.granted || permissionStatus == PermissionStatus.grantedLimited) {
    //       // If granted listen to the onLocationChanged stream and emit over our controller
    //       Location().onLocationChanged.listen((locationData) {
    //         if (locationData != null) {
    //           locationChnaged();
    //
    //           // _locationController.add(UserLocation(
    //           //   latitude: locationData.latitude,
    //           //   longitude: locationData.longitude,
    //           // ));
    //         }
    //       });
    //     }
    //   });
 
    timer = Timer.periodic( const Duration(milliseconds: 500), (Timer t) {
      if (tabController!.index == 0) {
        locationChnaged();
      }
    });
    tabController = TabController(length: 3, vsync: this);
  }

  bool _hasPermissions = false;

  BuildContext? mycontext;
  double? zoom;
  var cusicon;
  var cusicon1;
  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  getIcon() async {
    final Uint8List? markerIcon =
        await getBytesFromAsset('assets/quiblapin2.png', 80);

    cusicon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.1, size: Size.square(5)),
      'assets/quiblapin2.png',
    );
    cusicon1 = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.1, size: Size.square(5)),
      'assets/quiblapin2.png',
    );
    _markers = [
      Marker(
        onTap: () {},
        icon: BitmapDescriptor.fromBytes(markerIcon!),
        markerId: const MarkerId("1"),
        position: const LatLng(21.42262271669748, 39.826197083199034),
        infoWindow: InfoWindow(
          title: "Title",
          snippet: "something",
          onTap: () {},
        ),
      ),
    ];
  }

  _handleTap(LatLng point) {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
        child: locationData == null || lines == null
            ? Container(
                height:
                    MediaQuery.of(context).size.height - 50 - widget.appBarSize,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.5, color: Colors.grey),
                ),
                child: const Center(
                  child: Text(".........."),
                ))
            : Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        50 -
                        widget.appBarSize -
                        widget.padding,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: widget.kGooglePlex,
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      rotateGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      indoorViewEnabled: true,
                      scrollGesturesEnabled: true,
                      polylines: Set<Polyline>.of(lines!),
                      markers: Set<Marker>.of(_markers),
                      mapType: MapType.hybrid,
                      // myLocationEnabled: true,
                      compassEnabled: true,
                      myLocationButtonEnabled: true,
                      onTap: (value) {
                        _handleTap(value);
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Column(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                              color: Colors.white.withAlpha(170),
                              borderRadius: BorderRadius.circular(2)),
                          child: GestureDetector(
                            child: Icon(Icons.my_location),
                            onTap: () async {
                              quiblaCheck = false;
                              setState(() {});
                              final GoogleMapController controller =
                                  await _controller.future;
                              controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                       CameraPosition(
                                target: LatLng(
                                    locationData!.latitude, locationData!.longitude),
                                zoom: 19,
                                bearing: 30,
                              )));
                            },
                          ),
                        ),

                        const Divider(
                          height: 1,
                        ),
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                              color: Colors.white.withAlpha(170),
                              borderRadius: BorderRadius.circular(2)),
                          child: GestureDetector(
                            child: Image.asset("assets/quibla.png"),
                            onTap: () async {
                              quiblaCheck = true;
                              setState(() {});
                              final GoogleMapController controller =
                                  await _controller.future;
                              controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                      const CameraPosition(
                                target: LatLng(
                                    21.42262271669748, 39.826197083199034),
                                zoom: 19,
                                bearing: 30,
                              )));
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
