import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
//import 'package:google_maps_webservice/distance.dart';
import 'package:location/location.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';
import 'package:dio/dio.dart';
class track extends StatefulWidget {
  GoogleMapController _controller ;
  LatLng dest ;
  track (GoogleMapController controller , LatLng dest ) {this._controller=controller ; this.dest = dest ; }
  @override
  tracking createState() =>  tracking (_controller , dest );
}

class tracking  extends State<track>{
  tracking (GoogleMapController controller , LatLng dest ) {this._controller=controller ; this.dest = dest ; }
  GoogleMapController _controller ;
  LatLng dest ;
  final Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  Dio dio = new Dio();
  String time;
  GoogleMapPolyline googleMapPolyline =
  new GoogleMapPolyline(apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg");

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(36.752887,  3.042048),
    zoom: 14.4746,
  );

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Set <Circle> circle = {} ;
  Set <Marker> markers = {} ;

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/fleche.png");
    return byteData.buffer.asUint8List();
  }
  Future<Uint8List> getMarker2() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load('assets/destination.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      markers.add( Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 1,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));
      circle.add( Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeWidth: 2,
          strokeColor:Colors.orangeAccent,
          center: latlng,
          fillColor:Color(0xfff1b97a).withAlpha(70)));
      LatLng source = LatLng(newLocalData.latitude, newLocalData.longitude);
      getsomePoints (source  , dest);

    });

  }

  void getCurrentLocation() async {
    try {

      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }


      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);

        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }
  a(){}
  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }







  getsomePoints(  LatLng sourse,LatLng destination  ) async {
    // routeCoords.clear();
    //  polyline.clear() ;
    routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(sourse.latitude, sourse.longitude),
        destination: LatLng(destination.latitude,destination.longitude),
        mode: RouteMode.driving);

    polyline.add(Polyline(
        polylineId: PolylineId('route1'),
        visible: true,
        points: routeCoords,
        width: 6,
        color: Colors.teal,
        startCap: Cap.buttCap,
        endCap: Cap.buttCap));
  }





  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _GetdestinationLocation() ;
    setSourceAndDestinationIcons();
    Duration();


  }
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/user_icon.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination.png');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(children : <Widget>[ GoogleMap(
          /* myLocationEnabled: true,
           compassEnabled: false,
           tiltGesturesEnabled: false,*/
            mapType: MapType.normal, markers: markers,
            circles:  circle,
            polylines: polyline,
            initialCameraPosition: initialLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller; }
        ),

          /*Positioned (
                 top : 50.0 ,
                 right : 15.0 ,
                 left: 15.0 ,
                child: RaisedButton(onPressed: (){Distance();} , color:  Colors.white, child: Text("distance"),),
      ),
         Positioned (
           top : 100.0 ,
           right :15.0 ,
           left: 15.0 ,
           child: RaisedButton(onPressed: (){Duration();} , color:  Colors.white, child: Text("duration"),),
         ),*/

        ]));

  }

  Future<String> Distance ()async {
    double lat = dest.latitude ;
    double log = dest.longitude ;
    var location = await _locationTracker.getLocation();
    double slat = location.latitude ;
    double slong = location.longitude ;
    Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$slat,$slong&destinations=$lat,$log&key=AIzaSyClGaz1oBDjeB51QnEQ7Os9eJlALRamk5A");

    String distance  = response.data["rows"][0]["elements"][0]["distance"]["text"] ;
    print(distance) ;
    return distance ;
  }


  Future<String> Duration  ()async {
    double lat = dest.latitude ;
    double log = dest.longitude ;
    var location = await _locationTracker.getLocation();
    double slat = location.latitude ;
    double slong = location.longitude ;
    Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$slat,$slong&destinations=$lat,$log&key=AIzaSyClGaz1oBDjeB51QnEQ7Os9eJlALRamk5A");
    String duration = response.data["rows"][0]["elements"][0]["duration"]["text"] ;
    Text(duration);
    return duration ;

  }




  Future<void> _GetdestinationLocation()
  async {
    Uint8List imageData = await getMarker2();

    setState(

            () {
          final marker = Marker(
            icon: destinationIcon,
            markerId: MarkerId("destination"),
            position: dest ,
            infoWindow: InfoWindow(title: 'kermiche asma'),
          );
          markers.add(marker);

        } ) ;
  }


  Create_alert_dialogue_destance(BuildContext context) {
    return showDialog(context: context , builder : (context) {
      return AlertDialog(
        title: Text("") ,
        actions: <Widget>[
          RaisedButton(onPressed:(){ Navigator.of(context).pop(MaterialPageRoute());} , color:  Colors.blue, child: Text("okey") ,disabledTextColor: Colors.white,),],
      );
    });
  }
}
