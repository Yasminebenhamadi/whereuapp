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
import 'package:whereuapp/classes/Groupe.dart';
import 'package:permission/permission.dart';
import 'distance.dart';
import 'package:dio/dio.dart';
import 'package:whereuapp/home/groupe_user.dart';
class track extends StatefulWidget {
  GoogleMapController _controller ;
  LatLng dest ;
  Group group ;
  track (GoogleMapController controller , LatLng dest , Group group ) {this._controller=controller ; this.dest = dest ; this.group = group ; }
  @override
  tracking createState() =>  tracking (_controller , dest, group );
}

class tracking  extends State<track>{
  tracking (GoogleMapController controller , LatLng dest  , Group group ) {this._controller=controller ; this.dest = dest ;  this.group = group ;}
  GoogleMapController _controller ;
  LatLng dest ;
  Group group ;
  final Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  List <List<LatLng>> les_routes_des_users = [];
  Dio dio  = new Dio();
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



  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }






  getsomePoints( Group group ,LatLng destination  ) async {
    // routeCoords.clear();
    //  polyline.clear() ;
    for (int i=0 ; i < group.members.length ; i++ ) {

      routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng( group.members[i].membersInfo.location.latitude, group.members[i].membersInfo.location.longitude),
          destination: LatLng(destination.latitude,destination.longitude),
          mode: RouteMode.driving);

      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: routeCoords,
          width: 3,
          color: Colors.blue,
          startCap: Cap.buttCap,
          endCap: Cap.buttCap));
    }}
  void get_som_point_test(){getsomePoints(group, dest) ;}
  void _GetdestinationLocation()
  {setState(() {
    final marker = Marker(
      markerId: MarkerId("destination"),
      position: dest ,
      infoWindow: InfoWindow(title: 'Your destination'),
    );
    markers.add(marker);

  } ) ;
  }

  aaaa ()async {Set <Marker> m =  await  group.addMarkers() ;
  markers.addAll(m);}

  group_markers() { setState(()  {
    aaaa();
  });}



  @override
  void initState()  {
    super.initState();
    _GetdestinationLocation() ;
    group_markers() ;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("home_page"),
        ),
        body:Stack(children : <Widget>[ GoogleMap(
            mapType: MapType.normal, markers: markers,
            polylines: polyline,
            initialCameraPosition: initialLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller; }
        ),
          FloatingActionButton(
            onPressed:get_som_point_test,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.blue,
            child: Icon(
                Icons.directions_car
            ),
          ),

          Positioned (
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
          ),

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
    print (duration) ;
    return duration ;

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

















  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/az.png");
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
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));
      circle.add( Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70)));
      LatLng source = LatLng(newLocalData.latitude, newLocalData.longitude);
      // getsomePoints (source  , dest);

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

        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

}
