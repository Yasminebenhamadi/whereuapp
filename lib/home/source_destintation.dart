import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'request/commencer_letracking.dart';
import 'package:geolocator/geolocator.dart';
import 'request/commencer_letracking.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import'package:google_maps_webservice/places.dart';
import 'package:geocoder/geocoder.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg");

class SourceDestination extends StatefulWidget {
  final Group group ;
  SourceDestination({this.group });

  @override
  _SourceDestinationState createState() =>_SourceDestinationState();
}

class _SourceDestinationState extends State<SourceDestination>
{
  Group group ;
  GoogleMapController _controller ;
  static final CameraPosition _initialLocation = CameraPosition(target: LatLng(36.752887,  3.042048), zoom: 14.4746,);
  static LatLng destination ;
  TextEditingController DestinationController = TextEditingController();
  Set <Marker> _markers = {} ;


@override
void initState() {
  group = widget.group;
  group_markers();
}

aaaa ()async {
  Set <Marker> m =  await  group.addMarkers() ;
  _markers.addAll(m);}

group_markers() { setState(()  {aaaa();});}  // pour afficher  'markers' fel map

@override
  Widget build(BuildContext context)
  {

    return Scaffold(
      appBar: AppBar(
        title: Text("home_page"),
      ),
      body: Stack( children :  <Widget> [
          GoogleMap(
           mapType: MapType.normal,
           initialCameraPosition: _initialLocation,
           markers: _markers,
           onMapCreated: (GoogleMapController controller) {
           _controller = controller;
        },),

        Positioned (
          top : 105.0 ,
          right : 15.0 ,
          left: 15.0 ,
          child : Container (
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10.0) ,
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
                  Set <Marker> m = await  group.addMarkers() ;
                  _markers.addAll(m) ;
                });
                } ,
                decoration : InputDecoration ( icon: Container(margin: EdgeInsets.only(left: 20,top: 5), width: 10, height: 10, child: Icon ( Icons.directions_car ), ) ,
                  hintText: "Destination" ,
                  border: InputBorder.none ,
                ),

            ),
          ),
        ),
        Positioned(  top : 80.0 ,
                     right : 10.0 ,
                     left: 10.0 ,
            child: RaisedButton( color : Colors.white ,onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> track (_controller , destination , group))); }, child: Text("commencer"),) ),

    ]));



  }


 void get_group_position()
 {
    for (int j=0 ; j < group.members.length ; j++)
      {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(group.members[j].membersInfo.id),
            position: group.members[j].membersInfo.location,
            infoWindow: InfoWindow(title: group.members[j].membersInfo.displayName),
            anchor: Offset(0.5, 0.5),));
        });
      }

 }



  /* _GetUsersLocation()  async{
  setState(() async {

    if (group.get_members().isNotEmpty)
    {
      for(int i=0 ; i< group.get_members().length; i++ ) {
        if (i==0){
          await group.get_members()[i].get_user_locc();
          LatLng loc = await group.get_members()[i].get_position();
          print('loc');
          print(loc.latitude);
          print(loc.longitude);
          _markers.add(Marker(
            markerId: MarkerId(group.get_members()[i].name),
            position: loc,
            infoWindow: InfoWindow(title: group.get_members()[i].get_name()),
            anchor: Offset(0.5, 0.5),));
        }
        else {
          _markers.add(Marker(
            markerId: MarkerId(group.get_members()[i].name),
            position: group.get_members()[i].get_position(),
            draggable: false,
            zIndex: 2,
            infoWindow: InfoWindow(title: group.get_members()[i].get_name()),
            flat: true,
            anchor: Offset(0.5, 0.5),));
        }
      }

    }
    return _markers ;
  });


}*/
  /*hada methode ntaa la recherche */
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
       destination =  LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng);
       Placemark nation;
       // =  LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng);

      DestinationController.text = detail.result.name ;
      setState(() {
        final marker = Marker(
          markerId: MarkerId("destination"),
          position:  LatLng ( detail.result.geometry.location.lat,  detail.result.geometry.location.lng),
          infoWindow: InfoWindow(title: 'Your destination'),
        );
        _markers.add(marker);

      } ) ;
    }
  }
}

