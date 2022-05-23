// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, unused_local_variable, avoid_print

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';

void main() => runApp(CompassScreen());

class CompassScreen extends StatefulWidget {
  var appBarSize;
  var image;
  var images;
  var padding;


  CompassScreen(
      {Key? key, this.padding, this.appBarSize, this.image, this.images})
      : super(key: key);

  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? animationController;
  var degree;
  Timer? timer;
  var _lastRead;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(seconds: 1),
        upperBound: math.pi * 2
    );

    // animationController?.war;
    animationController!.addListener(() {
      setState(() {
        if (animationController!.status == AnimationStatus.completed) {
          // animationController!.srepeat();
        }
      });
    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      readCompass();
    });
    // timer = Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
        locationChnaged();
    // });
  }

  readCompass() async {
    print("in read compass");
    // print("")
    // animationController?.forward(from: _lastRead);

    final CompassEvent tmp = await FlutterCompass.events!.first;
    _lastRead = tmp.heading;
    animationController!.animateTo(_lastRead);
    print(_lastRead);
    setState(() {
    });
  }

  locationChnaged() async {
      final CompassEvent tmp = await FlutterCompass.events!.first;
      final locData = Location().onLocationChanged;
      var location = await locData.first;
      double dLon = (39.826197083199034 - location.longitude!);
      double y = math.sin(dLon) * math.cos(21.42262271669748);
      double x = math.cos(location.latitude!) * math.sin(21.42262271669748) -
          math.sin(location.latitude!) *
              math.cos(21.42262271669748) *
              math.cos(dLon);
      double brng = math.atan2(y, x);
      degree = (360 - ((brng + 360) % 360));
      print("------------------$degree");
      setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _lastRead == null ?  Container()
        : Center(
      child: SizedBox(
          height: MediaQuery.of(context).size.height -
              50 -
              widget.appBarSize -
              widget.padding,
          width: double.infinity,
          child: Column(
      children: [
      const SizedBox(
      height: 15,
      ),
      _lastRead <= 5.0-90 && _lastRead >= -5.0-90
          ? const Text("yeeeeeyyyyy!")
          : Container(),
      Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        child: Container(
          height: 300,
          width: 300,
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Colors.white),
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 360.0).animate(animationController!),
            // angle: (double.parse(_lastRead.toString()) * (math.pi / 180) * -1),
            child: Image.asset(
              widget.image,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
      Container(
        height: 120,
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: ListView.builder(
          itemBuilder: (context, i) => GestureDetector(
            onTap: () {
              widget.image = widget.images[i];
              setState(() {});
            },
            child: Container(
              color: Colors.white,
              height: 100,
              width: 100,
              child: Image.asset(
                widget.images[i],
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          itemCount: widget.images.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
        ),
      )
      ],
    )

    ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
