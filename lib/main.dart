import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector_math/vector_math.dart' show radians;

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'vscodefirebase',
    options: const FirebaseOptions(
      googleAppID: "1:1050553742489:ios:b7aaeb772a3ecf08",
      bundleID: "com.example.eatWithMe",
      projectID: 'eatwithme-c103e',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();
  bool isOpened = false;
  double _fabHeight = 56.0;
  Animation<double> _translateButton;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  static const LatLng _center = const LatLng(45.521563, -122.677433);
  static const LatLng ANU = const LatLng(-35.2777, 149.1185);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  final List<userPosition> userPositions = [];
 
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void addUsers(userPosition user){
    if (!userPositions.contains(user))
      userPositions.add(user);
  }

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Inbox',
        child: Icon(Icons.inbox),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  _buildButton(double angle, {Color color, IconData icon}) {
      final double rad = radians(angle);
      return Transform(
        transform: Matrix4.identity()..translate(
          (_translateButton.value) * cos(rad), 
          (_translateButton.value) * sin(rad)
        ),

        child: FloatingActionButton(
          child: Icon(icon), backgroundColor: color, onPressed: (){}, elevation: 0)
      );
    }
  
  // load data from Firebase
  Future<void> loadData() async{
    double lat;
    double lng;
    String name;
    List interest;
    userPosition up;
    QuerySnapshot sn = await Firestore.instance.collection('User_Location').getDocuments();
    var list = sn.documents;
    list.forEach((DocumentSnapshot ds) => {
      name = ds.data['name'],
      lat = ds.data['location'].latitude,
      lng = ds.data['location'].longitude,
      interest = ds.data['interest'],
      getNewPosition(lat, lng),
      up = new userPosition(_lastMapPosition, name, interest),
      addUsers(up),
      addMarker(name, _lastMapPosition, interest)
      }
      );
  }

  void addMarker(String name, LatLng pos, List interest){
    setState(() {
      Marker markerChangeName = getMarkerByPos(pos);
      Marker markerChangePosition = getMarkerByName(name);
      Marker markerChangeInterest = getMarkerByInterest(interest);
      _markers.remove(markerChangeName);
      _markers.remove(markerChangePosition);
      _markers.remove(markerChangeInterest);
      _markers.add(Marker(
        markerId: MarkerId(name),
        position: pos,
        infoWindow: InfoWindow(
          title: name,
          snippet: "interests: " + interest.toString()
        ),
        icon: BitmapDescriptor.fromAsset("assets/orange.png")
      ));
    });
  }

  Marker getMarkerByPos(LatLng pos){
    for (Marker m in _markers) {
      if (m.position == pos)
        return m;
    }
  }

  Marker getMarkerByName(String name){
    for (Marker m in _markers) {
      if (m.markerId == MarkerId(name))
        return m;
    }
  }

  Marker getMarkerByInterest(List interest){
    for (Marker m in _markers) {
      if (m.infoWindow.snippet == "interests: " + interest.toString())
        return m;
    }
  }

  void getNewPosition(double lat, double lng){
    _lastMapPosition = new LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: AppBar(
          backgroundColor: Colors.orange[700],
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              rotateGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: ANU,
                zoom: 16.0,
              ),
              // Add markers
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            _buildButton(0, color: Colors.red),
            _buildButton(45, color: Colors.orange),
            _buildButton(90, color: Colors.black),
            toggle(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.bottomRight,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class userPosition{
  String user;
  LatLng position;
  List interest;
  userPosition(LatLng position, String user, List interest){
    this.position = position;
    this.user = user;
    this.interest = interest;
  }
  @override
  String toString() {
    return user + position.toString();
  }
}
