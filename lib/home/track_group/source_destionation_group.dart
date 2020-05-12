 //import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
 import 'package:whereuapp/home/swipe_button.dart';
import 'commencer_lestrack_groupe.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import'package:google_maps_webservice/places.dart';
import 'package:geocoder/geocoder.dart';
import '../../classes/Utilisateur.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg");

class SourceDestination_grp extends StatefulWidget {
   Group group;
   Utilisateur user ;
  SourceDestination_grp(Group groupe ,Utilisateur user  ){this.group = groupe; this.user = user ;}

  @override
  _SourceDestinationState_group createState() =>_SourceDestinationState_group(user , group);
}

class _SourceDestinationState_group extends State<SourceDestination_grp>
{
  Group groupe ;
  Utilisateur user ;
  GoogleMapController _controller ;
  _SourceDestinationState_group ( Utilisateur user ,Group groupe) {this.groupe = groupe ; this.user=user ;}
  static final CameraPosition _initialLocation = CameraPosition(target: LatLng(36.752887,  3.042048), zoom: 14.4746,);
  //static LatLng destination ;
  TextEditingController DestinationController = TextEditingController();
  Set <Marker> _markers = {} ;
  BitmapDescriptor destinationIcon;

  void setCustomMapPin() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination.png');
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    initialise ();
  }

  void initialise () async {
    await groupe.getMembers();
    await getMarkers();
  }
  Future<void> getMarkers () async {
    Set <Marker> m =  await  groupe.addMarkers() ;
    _markers.addAll(m);
  }

  @override
  Widget build(BuildContext context)
  {

    return Scaffold(

        body: Stack( children :  <Widget> [
          StreamBuilder<Set<Marker>>(
            initialData: _markers,
            stream: null, //TODO
            builder: (context, snapshot) {
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialLocation,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },);
            }
          ),
          Positioned (
            bottom :120.0 ,
            right : 15.0 ,
            left: 20.0 ,
            child : Container (
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0) ,
                color: Colors.white ,
                boxShadow : [BoxShadow(color: Colors.black12 , offset: Offset(1.0,5.0),blurRadius: 10 , spreadRadius: 3) ],
              ),
              child: TextField(
                controller: DestinationController,
                cursorColor: Colors.black,
                onTap: () async{

                  Prediction p = await PlacesAutocomplete.show(
                      context: context, apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg" ,  mode: Mode.overlay );
                  displayPrediction(p);
                  setState(() async {
                    Set <Marker> m = await  groupe.addMarkers() ;
                    _markers.addAll(m) ;
                  });
                } ,
                decoration : InputDecoration (
                  prefixIcon: Icon(Icons.location_on,color: Colors.teal),
                  hintText: "Votre destination" ,
                  border: InputBorder.none ,
                ),

              ),
            ),
          ),
          Positioned(
            top:50,
            right: 20,
            left: 20,
            child:Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Color(0xfff1b97a),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    offset: Offset(0, 5),
                    color: Color(0xffe8652d).withOpacity(.75),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10.0),
                  Flexible(
                    flex: 3,
                    child: Column(
                      children: [
                        SizedBox(height: 10,),
                        Text(
                          "Choisissez une destination pour commencer le trajet avec votre groupe ",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/destinationn.png'),

                ],
              ),
            ),
          ),
          Positioned(
            bottom:20,
            left : 20,
            right:20,
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: SwipeButton(
                  thumb: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                          widthFactor: 0.90,
                          child: Icon(
                            Icons.chevron_right,
                            size: 40.0,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  content: Center(
                    child: Text(
                      "Swipe à droite pour commencer ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onChanged: (result) {
                    if (result == SwipePosition.SwipeRight) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> track_groupe (groupe: groupe,)));
                    } else {}
                  },
                ),
              ),
            ),),

        ]));



  }


  void get_group_position()
  {
    for (int j=0 ; j < groupe.members.length ; j++)
    {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(groupe.members[j].membersInfo.id),
          position: groupe.members[j].membersInfo.location,
          infoWindow: InfoWindow(title: groupe.members[j].membersInfo.displayName),
          anchor: Offset(0.5, 0.5),));
      });
    }

  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // List <Place> _places ;
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);
      print(lat);
      print(lng);
      _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition ( target: LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng), zoom: 18.0 ,  ),
      ),
      );
      //destination =  LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng);
      widget.group.setLieuArrive(LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng));
      Placemark nation;
      // =  LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng);

      DestinationController.text = detail.result.name ;
      setState(() {
        final marker = Marker(
          icon: destinationIcon,
          markerId: MarkerId("destination"),
          position:  LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng),
          infoWindow: InfoWindow(title: 'Votre destination'),
        );
        _markers.add(marker);

      } ) ;
    }
  }
}
