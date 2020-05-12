import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/groupe/discussion.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:whereuapp/settings/cercles_user.dart';
import 'package:whereuapp/settings/setting.dart';
import 'package:whereuapp/Alert.dart';
import 'dragging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:whereuapp/home/pin_pill_info.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/home/track_group/source_destionation_group.dart';
import 'package:whereuapp/home/src_dest.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/unknownError.dart';
import 'package:provider/provider.dart';
import 'direct_select_container.dart';
import 'direct_select_item.dart';
import 'direct_select_list.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg");

class HomePages_2 extends StatefulWidget {
  @override
  _MyHomePageState_2 createState() => _MyHomePageState_2();
}

class _MyHomePageState_2 extends State<HomePages_2> {
  final buttonPadding = const EdgeInsets.fromLTRB(0, 30, 0, 0);
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService() ;
  Group selectedGroup ;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  StreamSubscription _locationSubscription;
  Utilisateur user ;
  Marker marker;
  Group groupe ;
  Circle circle;
  PinInformation sourcePinInfo;
  final String pageRoute="";
  final String buttonTitle="";
  GoogleMapController mapController;
  final Set<Marker> _markers = {};

  final Set<Polyline> _polyline = {};

  static LatLng _initialPosition;

  LatLng _lastPosition = _initialPosition;

  LatLng userPosition;
  MapType _currentMapType = MapType.normal;
  BitmapDescriptor locationIcon;

  void setCustomMapPin() async {
    locationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/user_icon.png');
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(36.752887, 3.042048),
    zoom: 14.4746,
  );

  Widget button(Function function, IconData icon, Color color1, Color color2,String herotag) {
    return Container(
        height: 45,
        width: 45,
        child: FittedBox(
          child: FloatingActionButton(
            heroTag: herotag,
            onPressed: function,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: color1,
            child: Icon(icon, size: 30.0, color: color2),
          ),
        ));
  }
  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  int _selectedTabIndex = 0;
  Widget _build_Nav_Bar ()
  {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 21.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  color: Color(0xfff2e9db)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Icon(
                      Icons.map,
                      color: Color(0xffe8652d),
                    ),
                    onTap: () {_onMapTypeButtonPressed() ;},
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.group,
                      color: Color(0xffe8652d),
                    ),
                    onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>cercleUser()));},
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.add_alert,
                      color: Color(0xffe8652d),
                    ),
                    onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SosPage()));},
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.message,
                      color: Color(0xffe8652d),
                    ),
                    onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>messaging()));},
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.settings,
                      color: Color(0xffe8652d),
                    ),
                    onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingPage()));},
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 0),

        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    cloc();
    on_sync_coutton_pressed();
  }
  Widget messaging (){
    return selectedGroup == null ? cercleUser() : chat(group: selectedGroup,);
  }
  Widget body ;

  @override
  Widget build(BuildContext context) {
    setState(() {
      user = Provider
          .of<User>(context)
          .utilisateur;
    });
    return Scaffold(


      body:  Stack(
        //fit: StackFit.expand,
        children: <Widget>[
          GoogleMap(
            compassEnabled: true,
            tiltGesturesEnabled: false,
            mapType:_currentMapType,
            initialCameraPosition: initialLocation,
            markers: _markers,
            polylines: _polyline,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Positioned(
            child: GestureDetector(
              onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SourceDestination_grp (selectedGroup , Provider.of<User>(context).utilisateur  )));
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal,

                  Colors.teal[200],], begin: Alignment.topLeft, end: Alignment.bottomRight,),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(5, 5), blurRadius: 10,)],), child: Center(child: Text('Commencons un trajet ensemble', style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500,),),),),), bottom: 85, right: 60, left: 60,),
          Positioned(
            child: GestureDetector(
              onTap: () { on_sync_coutton_pressed() ;},
              child: Container(
                height: 45,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xffe8652d) , Color(0xfff2e9db),], begin: Alignment.topLeft, end: Alignment.bottomRight,),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(5, 5), blurRadius: 10,)],), child: Center(child: Text('La position des autres membres', style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500,),),),),), bottom: 140, right: 60, left: 60,),



          DirectSelectContainer(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.only(left:45.0,right:45,),
                      child: Column(
                        children: <Widget>[
                          //---------------------------------------GroupSelector------------------------------------------------------
                          FutureBuilder<List<GroupHeader>>(
                              future: Provider.of<User>(context).utilisateur.getUsersGroupsHeaders(),
                              builder: (buildContext,asyncSnapshot)
                              {
                                if (asyncSnapshot.hasError){
                                  return Center(child: Text('Something went wrong'));
                                }
                                else if (!asyncSnapshot.hasData){
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                else  {
                                  List<GroupHeader> groups = asyncSnapshot.data ;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: buttonPadding,
                                        child: Container(
                                          decoration: _getShadowDecoration(),
                                          child: Card(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Expanded(
                                                      child: Padding(
                                                          child: DirectSelectList<GroupHeader>(
                                                            values: groups,
                                                            defaultItemIndex: 0,
                                                            onItemSelectedListener: (groupHeader, int, context) async {
                                                              try {
                                                                Group group = await _firestoreService.getGroupInfo(groupHeader.gid);


                                                                setState(() {
                                                                  selectedGroup = group ;
                                                                });
                                                              } catch (e) {
                                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> unknownError (context)));
                                                                print(e);
                                                              }
                                                            },
                                                            itemBuilder: (GroupHeader value) => getDropDownMenuItem(value), focusedItemDecoration: _getDslDecoration(),
                                                          ),
                                                          padding: EdgeInsets.only(left:12 )
                                                      )
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 8),
                                                    child: _getDropdownIcon(),
                                                  )
                                                ],
                                              )),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                          ),
                          //----------------------------------------------------------------------------------------------------------
                          SizedBox(height: 20.0),
                          SizedBox(height: 15.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 240,
            child: Column(children: <Widget>[



              button(_segeolocaliser, Icons.my_location, Color(0xfff2e9db),
                  Color(0xffe8652d),"btn3"),
              SizedBox(height: 10),
              button(_onMapTypeButtonPressed, Icons.filter_none, Color(0xfff2e9db),
                  Color(0xffe8652d),"btn2"),
              SizedBox(height: 10),
              button((){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => s_d1()));} ,Icons.navigation, Color(0xfff2e9db),
                  Color(0xffe8652d),"btn4"),

              SizedBox(height: 10),

            ]),
          ),
          Positioned(
            top:44,
            left:5,
            child:button(()async {
              // show input autocomplete with selected mode
              // then get the Prediction selected
              Prediction p = await PlacesAutocomplete.show(
                context: context,
                mode: Mode.overlay,
                apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg",
              );
              displayPrediction(p);
            }, Icons.search, Color(0xfff2e9db), Color(0xffe8652d),"btn1"),
          ),
          Positioned(
            top:44,
            right:5,
            child:button((){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => s_d1()));} , Icons.notifications, Color(0xfff2e9db),
                Color(0xffe8652d),"btn5"),
          ),

          // selectGroup (),
          Dragging(group: selectedGroup,),
          _build_Nav_Bar(),
        ],
      ),

    );
  }


  //-------------------------------------Group selector ---------------------------------------------
  DirectSelectItem<GroupHeader> getDropDownMenuItem(GroupHeader groupHeader) {
    return DirectSelectItem<GroupHeader>(
        itemHeight: 45,
        value: groupHeader,
        itemBuilder: (context, value) {
          return Row(
            children: <Widget>[
              FutureBuilder(
                future :_storageService.groupsImage(groupHeader.photo,groupHeader.groupPhoto),
                builder: (context,asyncSnapshot) => CircleAvatar(
                  backgroundImage: asyncSnapshot.data,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 20,) ,
              Text(groupHeader.name ,  style: TextStyle(
                color: Color(0xffe8652d),
                fontSize: 15,
              ),),
            ],
          );
          /*return Text(value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          );*/
        });
  }

  _getDslDecoration() {
    return BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(width: 1, color: Color(0xffe8652d)),
          top: BorderSide(width: 1, color: Color(0xffe8652d)),
        ));
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black45.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 10.0,
        ),
      ],
    );
  }

  Icon _getDropdownIcon() {
    return Icon(
      Icons.unfold_more,
      color: Color(0xffe8652d),
    );
  }
  //------------------------------------------------------------------------------------------------------------------------
  _segeolocaliser() async {
    /*  hadi tmedlk l ihdathiat win raky */
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    /* hna bach ndir une marque f ma position */
    setState(() {
      _markers.clear();
      final marker = Marker(
        icon: locationIcon,
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
      );

      _markers.add(marker);
      /* hna bach tsra hadik l'animation ida konti fi plassa khra la map trej3ek f ta position */
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 11.0,
          ),
        ),
      );
    });
  }

  cloc() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    userPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
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

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(detail.result.geometry.location.lat,
                detail.result.geometry.location.lng),
            zoom: 18.0,
          ),
        ),
      );
    }
  }

  void groupsMarkers() async
  {
    Set <Marker> _marker = await selectedGroup.addMarkers();
    print(_marker);
    setState(() {
      _markers.clear();
      _markers.addAll(_marker);
    });
  }
/*  void sync () async
  {  groupe_track_sync g = groupe_track_sync(Provider.of<User>(context).utilisateur,selectedGroup) ;
    g.on_sync_coutton_pressed() ;
 /* Set <Marker> marker = await group.syncroniser();
    marker = await group.syncroniser();
    setState(()
    {_markers.clear();
    _markers.addAll(marker);
    });*/
  }*/
  /* void on_sync_coutton_pressed() async
  {
    Set <Marker> marker = await selectedGroup.syncroniser();
    marker = await selectedGroup.syncroniser();
    setState(()
    {_markers.clear();
    _markers.addAll(marker);
    });
  }*/
  void on_sync_coutton_pressed() async
  { selectedGroup.getMembers();
  Set <Marker> marker = await selectedGroup.syncroniser();
  marker = await selectedGroup.syncroniser();

  var currentLocation = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

  setState(()
  {
    _markers.clear();
    _markers.addAll(marker);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 9.0,
        ),
      ),
    );
  });
  }
/* Widget selectGroup (){
    return Scaffold(
      key: scaffoldKey,
      body:
      DirectSelectContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      //---------------------------------------GroupSelector------------------------------------------------------
                      FutureBuilder<List<GroupHeader>>(
                          future: Provider.of<User>(context).utilisateur.getUsersGroupsHeaders(),
                          builder: (buildContext,asyncSnapshot)
                          {
                            if (asyncSnapshot.hasError){
                              return Center(child: Text('Something went wrong'));
                            }
                            else if (!asyncSnapshot.hasData){
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            else  {
                              List<GroupHeader> groups = asyncSnapshot.data ;
                              return Column(
                                children: [
                                  Padding(
                                    padding: buttonPadding,
                                    child: Container(
                                      decoration: _getShadowDecoration(),
                                      child: Card(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Expanded(
                                                  child: Padding(
                                                      child: DirectSelectList<GroupHeader>(
                                                        values: groups,
                                                        defaultItemIndex: 0,
                                                        onItemSelectedListener: (groupHeader, int, context) async {
                                                          try {
                                                            Group group = await _firestoreService.getGroupInfo(groupHeader.gid);
                                                            setState(() {
                                                              selectedGroup = group ;
                                                            });
                                                          } catch (e) {
                                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> unknownError (context)));
                                                            print(e);
                                                          }
                                                        },
                                                        itemBuilder: (GroupHeader value) => getDropDownMenuItem(value), focusedItemDecoration: _getDslDecoration(),
                                                      ),
                                                      padding: EdgeInsets.only(left: 12)
                                                  )
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(right: 8),
                                                child: _getDropdownIcon(),
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                      ),
                      //----------------------------------------------------------------------------------------------------------
                      SizedBox(height: 20.0),
                      SizedBox(height: 15.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }*/
/*Widget map (){
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GoogleMap(
          compassEnabled: true,
          tiltGesturesEnabled: false,
          mapType:_currentMapType,
          initialCameraPosition: initialLocation,
          markers: _markers,
          polylines: _polyline,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
        ),
        Positioned(
          child: RaisedButton(
            onPressed: () async  {sync(selectedGroup) ;},
            child: Text("Sync_group"), color : Colors.white ,
          ),
          bottom: 300,
          right: 60,
          left: 60,
        ),
        Positioned(
          child: RaisedButton(
            onPressed: () async  { groupsMarkers(selectedGroup) ;},
            child: Text(" group markers"), color : Colors.white ,),
          bottom: 260,
          right: 60,
          left: 60,
        ),
        Positioned(
          child: RaisedButton(
            onPressed: ()   {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SourceDestination_grp (group : selectedGroup )));
            }, child: Text("track_group"), color : Colors.white ,),
          bottom: 200,
          right: 60,
          left: 60,
        ),
        Positioned(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => s_d1()));
            },
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal,
                    Colors.teal[200],
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(5, 5),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  'Commencons un trajet ensemble',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          bottom: 85,
          right: 60,
          left: 60,
        ),
        Positioned(
          right: 10,
          bottom: 240,
          child: Column(children: <Widget>[
            button(_segeolocaliser, Icons.my_location, Colors.white,
                Color(0xfff1b97a),"btn3"),
            SizedBox(height: 10),
            button(_onMapTypeButtonPressed, Icons.filter_none, Colors.white,
                Color(0xfff1b97a),"btn2"),
            SizedBox(height: 10),
            button(()async {
              // show input autocomplete with selected mode
              // then get the Prediction selected
              Prediction p = await PlacesAutocomplete.show(
                context: context,
                mode: Mode.overlay,
                apiKey: "AIzaSyCN5CJGsvRnutmMNhpN8toEprd3fn7cIBg",
              );
              displayPrediction(p);
            }, Icons.search, Colors.white, Color(0xfff1b97a),"btn1"),
          ]),
        ),
        selectGroup (),
        Dragging(group: selectedGroup,),
      ],
    );
  }*/
}