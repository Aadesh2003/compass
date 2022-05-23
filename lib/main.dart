// ignore_for_file: use_key_in_widget_constructors, avoid_print, prefer_const_constructors, prefer_typing_uninitialized_variables, unused_local_variable, avoid_unnecessary_containers, unused_import, unused_field

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:compass/widgets/compass_screen.dart';
import 'package:compass/widgets/map_screen.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController? tabController;
  String? previewImage;
  var quiblaCheck = false;
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
  List<String> arrows = [
    "assets/quiblaArrow1.png",
    "assets/quiblaArrow2.png",
    "assets/quiblaArrow3.png"
  ];
  var path = "assets/compass.jpg";
  var arrow = "assets/quiblaArrow1.png";

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

  var angle = 10.0;

  readCompass() async {
    final CompassEvent tmp = await FlutterCompass.events!.first;
    _lastRead = tmp;
    angle = tmp.heading!;
    setState(() {});
    if (_lastRead!.heading! <= 6.0 && _lastRead!.heading! >= -6 + .0) {
      setState(() {});
    } else if (angle.toString().contains(".0")) {
      setState(() {});
    }
  }

  LatLngBounds? bounds;

  locationChnaged() async {
    if (_hasPermissions) {
      final CompassEvent tmp = await FlutterCompass.events!.first;
      final locData = Location().onLocationChanged;

      final GoogleMapController controller = await _controller.future;
      var zoom = await controller.getZoomLevel();
      controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: quiblaCheck
            ? LatLng(21.42262271669748, 39.826197083199034)
            : locationData!,
        zoom: zoom,
        bearing: tmp.heading!,
      )));
      var location = await locData.first;
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
    tabController = TabController(length: 3, vsync: this);
  }

  bool _hasPermissions = false;

  void _fetchPermissionStatus() async {
    permission.Permission.locationWhenInUse.status.then((status) async {
      if (mounted) {
        setState(() =>
            _hasPermissions = status == permission.PermissionStatus.granted);
      }
    });
  }

  BuildContext? mycontext;
  double? zoom;
  var cusicon;
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

  Widget _buildPermissionSheet() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "Compass App",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Location Permission Required'),
            ElevatedButton(
              child: Text('Request Permissions'),
              onPressed: () async {
                permission.Permission.locationWhenInUse
                    .request()
                    .then((ignored) {
                  _fetchPermissionStatus();
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Open App Settings'),
              onPressed: () {
                permission.openAppSettings().then((opened) {
                  _fetchPermissionStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appbar = AppBar(
      elevation: 0,
      centerTitle: true,
      title: Text("Compasss App"),
    );
    if (locationData != null) {
      CameraPosition _kGooglePlex = CameraPosition(
        target: locationData!,
        zoom: 19,
      );
      mycontext = context;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: appbar,
        body: _hasPermissions == false
            ? _buildPermissionSheet()
            : lines == null
                ? CircularProgressIndicator(color: Colors.black)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 50,
                          color: Colors.blue,
                          child: TabBar(
                            labelPadding: EdgeInsets.zero,
                            indicatorPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            unselectedLabelColor: Colors.white,
                            indicatorColor: Colors.black,
                            controller: tabController,
                            tabs: [
                              Tab(
                                  child: tabController!.index == 0
                                      ? Text(
                                          "Map",
                                          style: TextStyle(color: Colors.black),
                                        )
                                      : Text(
                                          "Map",
                                          style: TextStyle(color: Colors.white),
                                        )),
                              Tab(
                                  child: tabController!.index == 1
                                      ? Text(
                                          "Arrow",
                                          style: TextStyle(color: Colors.black),
                                        )
                                      : Text(
                                          "Arrow",
                                          style: TextStyle(color: Colors.white),
                                        )),
                              Tab(
                                  child: tabController!.index == 2
                                      ? Text(
                                          "Compass",
                                          style: TextStyle(color: Colors.black),
                                        )
                                      : Text(
                                          "Compass",
                                          style: TextStyle(color: Colors.white),
                                        )),
                            ],
                            onTap: (e) {
                              setState(() {});
                            },
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              LocationInput(
                                appBarSize: appbar.preferredSize.height,
                                kGooglePlex: _kGooglePlex,
                                padding: MediaQuery.of(context).padding.top,
                              ),
                              CompassScreen(
                                appBarSize: appbar.preferredSize.height,
                                padding: MediaQuery.of(context).padding.top,
                                image: arrow,
                                images: arrows,
                              ),
                              CompassScreen(
                                appBarSize: appbar.preferredSize.height,
                                padding: MediaQuery.of(context).padding.top,
                                image: path,
                                images: paths,
                              )
                            ],
                            controller: tabController,
                          ),
                        )
                      ],
                    ),
                  ),
      );
    } else {
      getCurrentLocation();

      return _buildPermissionSheet();
    }
  }
}
