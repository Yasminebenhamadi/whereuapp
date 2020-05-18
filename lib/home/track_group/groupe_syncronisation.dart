import 'dart:async';
//import 'dart:html' ;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import '../../classes/Groupe.dart';
import '../../classes/Utilisateur.dart';
import 'package:whereuapp/home/home_page_2.dart';
import 'package:geolocator/geolocator.dart';
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg");

class groupe_home_page extends StatefulWidget {
  Utilisateur user ;
  Group group ;
  groupe_home_page (Utilisateur user ,Group group   ) {this.user = user ; this.group = group ; }

  @override
  groupe_track_sync createState() => new groupe_track_sync (user, group );

}


class groupe_track_sync extends State<groupe_home_page> {
  groupe_track_sync ( Utilisateur user ,Group group ) {this.groupe = group ;  this.user = user ;}
  StreamSubscription _locationSubscription;
  Group groupe ;
  Utilisateur user ;
  Marker marker;
  GoogleMapController _controller;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;

  final Set <Marker> _markers = Set <Marker> ();

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(36.752887, 3.042048),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    setState(() {
     groupe.getMembers();
    });
    return Scaffold(

        body: Stack(
          children: <Widget>[

            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },

            ),
            Positioned
              (
              top: 300.0,
              right: 15.0,
              left: 15.0,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePages_2 ())) ;

                },
                /* hna qnd la position ntaa les membres change  l user clique sur  le btn hdek ykherjolo les nv position nta les autre user ida kano on line */
                child: Text("quiter"),),
            ),

            Positioned
              (
              top: 150.0,
              right: 15.0,
              left: 15.0,
              child: RaisedButton(
                onPressed: () {on_sync_coutton_pressed(); },
                /* hna qnd la position ntaa les membres change  l user clique sur  le btn hdek ykherjolo les nv position nta les autre user ida kano on line */
                child: Text("sync"),),
            ),

          ],));
  }

  @override

  void onboutton_group_pressed(Group g) async
  {
    Set <Marker> _marker = await g.addMarkers();
    setState(() {
      _markers.addAll(_marker);
    });
  }
  void on_sync_coutton_pressed() async
  {
    Set <Marker> marker = await groupe.syncroniser();
    marker = await groupe.syncroniser();
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(()
    {_markers.clear();
    _markers.addAll(marker);

    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 9.0,
        ),
      ),
    );
    });
  }

}
