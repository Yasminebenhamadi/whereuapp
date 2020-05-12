import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:whereuapp/classes/Groupe.dart';

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



  @override
  void initState()  {
    super.initState();
    group_markers() ;
    _GetdestinationLocation() ;


  }

  aaaa ()  async {Set <Marker> m = await  group.addMarkers() ;
  markers.addAll(m);}
  group_markers() { setState(()  {
    aaaa();
  });}
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

  void aff_info(Group g )
  {
    for (int i = 0 ; i<g.members.length ; i++ )
      {
        print (g.members[i].membersInfo.displayName) ;
        print(g.members[i].membersInfo.location.latitude);
         print(g.members[i].membersInfo.location.longitude);
      }
  }




  getsomePoints( )  async {
     // routeCoords.clear();
     //  polyline.clear() ;


      for (int k=0 ; k < group.members.length ; k++ ) {

       routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng( group.members[k].membersInfo.location.latitude, group.members[k].membersInfo.location.longitude),
          destination: LatLng(dest.latitude,dest.longitude),
          mode: RouteMode.driving);
         if (k==0) {
           polyline.add(Polyline(
               polylineId: PolylineId('route$k)'),
               visible: true,
               points: routeCoords,
               width: 3,
               color: Colors.lightGreen,
               startCap: Cap.buttCap,
               endCap: Cap.buttCap));
         } else {
           polyline.add(Polyline(
               polylineId: PolylineId('route$k)'),
               visible: true,
               points: routeCoords,
               width: 3,
               color: Colors.blue,
               startCap: Cap.buttCap,
               endCap: Cap.buttCap));
         }
    }}
  void get_som_point_test(){ setState(() {

 getsomePoints() ;  });}



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
          onPressed: (){   group_markers() ; get_users_new_location_test();} ,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.directions_car
          ),
        ),


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
