import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng ANU = const LatLng(-35.2777, 149.1185);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Find your partner'),
          backgroundColor: Colors.orange[600],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          scrollGesturesEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: ANU,
            zoom: 14.0,
          ),
        ),
      ),
    );
  }
}