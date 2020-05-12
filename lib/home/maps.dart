import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/home/source_destintation.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'tracking !'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title,this.group}) : super(key: key);
  final Group group;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription _locationSubscription;
  Marker marker;
  GoogleMapController _controller;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  Group group;
  final Set <Marker> _markers = Set <Marker> ();

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(36.752887, 3.042048),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
        ),
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
              top: 70.0,
              right: 15.0,
              left: 15.0,
              child: RaisedButton(
                /* yesmin hna bach yrooh  la fenetre bach yhawes ala destination lazem ydi le groupe comme parametre  bch ykder yjbed les membres o les position nta3hom*/
                onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => SourceDestination(group : group)));},
                child: Text("lets go"),),
              ),

            FloatingActionButton(
              child: Icon(Icons.search,),
              onPressed: () async {print_group_info();},
              /* hada c juste bch ycryily le groupe u know lazem bch ykon andi group bch nkhdem and nty  il faut juste executer  on_bouton_group pressed
                *ana  9assdi qnd il clique ala l9roupe le but ntaha c yjbed  locations ntaaa3 members o yhathom sur la map des markers  */
              backgroundColor: Colors.blue,),
            Positioned
              (
              top: 150.0,
              right: 15.0,
              left: 15.0,
              child: RaisedButton(
                onPressed: () {print_group_info();on_sync_coutton_pressed(); },
                  /* hna qnd la position ntaa les membres change  l user clique sur  le btn hdek ykherjolo les nv position nta les autre user ida kano on line */
                 child: Text("sync"),),
            ),

          ],));
  }

  @override

  void onboutton_group_pressed(Group g) async
  { /*bch lyjbed les position o ydirhom f _markers li apres ybano fel map */
    Set <Marker> _marker = await g.addMarkers();
    setState(() {
      _markers.addAll(_marker);
    });
  }
  void on_sync_coutton_pressed() async
  { /* hna syncroniser ki ttbedel la position ysupprimer  markers l9dem o yjib jded */
    Set <Marker> marker = await group.syncroniser();
     marker = await group.syncroniser();
    setState(()
      {_markers.clear();
       _controller ;
       _markers.addAll(marker);
      });
  }


  Group creer_groupe() {
    SharableUserInfo u1 = SharableUserInfo('1', 'amina', 'amina', Gender.Female, DateTime.now());
    u1.location = LatLng(35.652887, 3.142048);
    SharableUserInfo u2 =  SharableUserInfo('2', 'Yasmine', 'Yasmine', Gender.Female, DateTime.now());
    u2.location = LatLng(36.652887, 3.142048);
    SharableUserInfo u3 = SharableUserInfo('3', 'sarah', 'sarah', Gender.Female, DateTime.now());
    u3.location = LatLng(36.523874, 3.142048);
    SharableUserInfo u4 = SharableUserInfo('4', 'asma', 'asma', Gender.Female, DateTime.now());
    u4.location = LatLng(36.692887, 3.142088);
    SharableUserInfo u5 = SharableUserInfo('5', 'meriem', 'meriem', Gender.Female, DateTime.now());
    u5.location= LatLng(36.652287, 3.142048);
    SharableUserInfo u6 = SharableUserInfo('6', 'marwa', 'marwa', Gender.Female, DateTime.now());
    u6.location = LatLng(36.654887, 3.142038);
    List <SharableUserInfo> membersg1 = [];
    Group g1 = Group('id', 'nom', '1',false,'');
    g1.members.add(Member.test('1',DateTime.now(),u1));
    g1.members.add(Member.test('2',DateTime.now(),u2));
    g1.members.add(Member.test('1',DateTime.now(),u3));
    g1.members.add(Member.test('1',DateTime.now(),u4));
    g1.members.add(Member.test('1',DateTime.now(),u5));
    g1.members.add(Member.test('1',DateTime.now(),u6));
    return g1;
  }


  void print_group_info()
  {
    Group g = creer_groupe();
    onboutton_group_pressed(g);
    group = g;
    for (int i =0 ; i< g.members.length ; i++)
   { print (group.members[i].membersInfo.displayName) ;
    print(group.members[i].membersInfo.location.latitude);
    print(group.members[i]..membersInfo.location.longitude); }
  }
   /* rani darya attribut group melfo9 lazemli initialisation yedi le groupe li rana fih daacc ! honey <3 <3 */
}
