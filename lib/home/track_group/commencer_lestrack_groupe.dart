import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:whereuapp/classes/Groupe.dart';
import '../../classes/Utilisateur.dart';
class track_groupe extends StatefulWidget {
  //LatLng dest ;
  final Group groupe ;
  track_groupe ( {this.groupe} );
  @override
  tracking createState() =>  tracking ();
}
class tracking  extends State<track_groupe>{
  GoogleMapController _controller ;
  LatLng destination ;
  Group group ;
  final Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  List <List<LatLng>> les_routes_des_users = [];
  Location _locationTracker = Location();
  GoogleMapPolyline googleMapPolyline =
  new GoogleMapPolyline(apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg");
  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(36.752887,  3.042048),
    zoom: 14.4746,
  );
  StreamSubscription _locationSubscription;
  Set <Circle> circle = {} ;
  Set <Marker> markers = {} ;
  Future<Uint8List> getMarker2() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load('assets/destination.png');
    return byteData.buffer.asUint8List();
  }
  BitmapDescriptor  destinationIcon;
  void setDestinationIcon() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination.png');
  }

  @override
  void initState()  {
    super.initState();
    setDestinationIcon();
    group = widget.groupe;
    destination = group.lieuArrive;
    group_markers() ;
    _GetdestinationLocation() ;
    group_markers() ;
    get_users_new_location_test();

  }

  aaaa ()  async {Set <Marker> m = await  group.addMarkers() ;
  markers.addAll(m);}
  group_markers() { setState(()  {
    aaaa();
  });}

  Future<void> _GetdestinationLocation()
  async {
    Uint8List imageData = await getMarker2();

    setState(

            () {
          final marker = Marker(
            icon: destinationIcon,
            markerId: MarkerId("destination"),
            position: destination ,
            infoWindow: InfoWindow(title: 'kermiche asma'),
          );
          markers.add(marker);

        } ) ;
  }




  getsomePoints( )  async {
    // routeCoords.clear();
    //  polyline.clear() ;


    for (int k=0 ; k < group.members.length ; k++ ) {

      routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng( group.members[k].membersInfo.location.latitude, group.members[k].membersInfo.location.longitude),
          destination: LatLng(destination.latitude,destination.longitude),
          mode: RouteMode.driving);
      if (k==0) {
        polyline.add(Polyline(
            polylineId: PolylineId('route$k)'),
            visible: true,
            points: routeCoords,
            width: 3,
            color: Color(0xffe8652d),
            startCap: Cap.buttCap,
            endCap: Cap.buttCap));
      } else {
        polyline.add(Polyline(
            polylineId: PolylineId('route$k)'),
            visible: true,
            points: routeCoords,
            width: 3,
            color: Colors.teal,
            startCap: Cap.buttCap,
            endCap: Cap.buttCap));
      }
    }}
  void get_som_point_test(){ setState(() {

    getsomePoints() ;  });}



  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body:Stack(children : <Widget>[
          GoogleMap(
            mapType: MapType.normal, markers: markers,
            polylines: polyline,
            initialCameraPosition: initialLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller; }
        ),
          /*FloatingActionButton(
            onPressed: (){   group_markers() ; get_users_new_location_test();} ,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.blue,
            child: Icon(
                Icons.directions_car
            ),
          ),*/


        ]));

  }












































  void updateMarkerAndCircle() {
    this.setState(() {
      for (int p = 0; p < group.members.length; p++){
        if (p==0) {
          //group.members[p].on_location_changed() ;
          group.listenToChanges(group.members[p]);
          LatLng latLng =  group.members[p].membersInfo.location ;
          markers.add(Marker(
            markerId: MarkerId(group.members[p].membersInfo.id),
            infoWindow: InfoWindow(title: group.members[p].membersInfo.displayName),

            position: latLng,
          ));}
        else {/*group.get_members()[p].on_location_changed()*/ ;
        LatLng latLng =  group.members[p].membersInfo.location ;
        markers.add(Marker(
          markerId: MarkerId(group.members[p].membersInfo.id),
          infoWindow: InfoWindow(title: group.members[p].membersInfo.displayName),
          position: latLng,
        ));}
      }
    });

  }

  /* void getCurrentLocations() async {
    try {
       get_som_point_test() ;
       if (_controller != null) {
         for (int m = 0 ; m < group.get_members().length ; m++)
             {   group.get_members()[m].on_location_changed() ;
                 LatLng location =  group.get_members()[m].get_position() ;
                 _controller.animateCamera(
                 CameraUpdate.newCameraPosition(new CameraPosition(
                     bearing: 192.8334901395799,
                     target: LatLng(location.latitude,location.longitude),
                     tilt: 0,
                     zoom: 18.00)));
             }


       }


       } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }
*/




  void getCurrentLocation() async {
    try {
      get_som_point_test() ;
      updateMarkerAndCircle();

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }


      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 15.00)));
          updateMarkerAndCircle();
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }





  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }
  void get_users_new_location_test () {
    setState(() {
      getCurrentLocation();
    });
  }

}
