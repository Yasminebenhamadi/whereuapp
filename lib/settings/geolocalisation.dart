import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:provider/provider.dart';
class GeoPage extends StatefulWidget {
  @override
  _GeoPageState createState() => _GeoPageState();
}

class _GeoPageState extends State<GeoPage> {

  Utilisateur utilisateur;
  bool value5 = true ;

  void onChangedValue5( bool value) {
    setState(() { value5= value ; });
    utilisateur.removeLocation();
  }

  Widget _image() {
    return Positioned(
      top: 24,
      child: Image(
        image : AssetImage("map.png"),
        height: 250,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    utilisateur = Provider.of<User>(context, listen: false).utilisateur;
  }

  Widget _switch() {
    return
      Positioned(
        top: 300,

        child: Container(
          margin: EdgeInsets.all(20),
          height: 200,
          width: MediaQuery.of(context).size.width * 0.90,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow : [BoxShadow (
                color:Colors.black12,
                blurRadius:10.0,
                offset:new Offset(10.0,10.0),)]),

          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Center(
                  child:  Text( "Activer la fonctionnalité pour permettre aux membres de votre cercle de vous positionner sur la carte ",
                      textAlign: TextAlign.justify,
                      style: TextStyle( fontSize:15.0)),
                ),

                SizedBox(
                  height: 20,
                ),
                new SwitchListTile(
                  value :value5 ,
                  onChanged: onChangedValue5 ,
                  activeColor: Colors.deepOrange,
                  secondary : new Icon(Icons.location_on , color: Color(0xffE8652D),),
                  title: new Text('Géolocalisation',style: TextStyle( fontSize:20.0, color: Color(0xff739D84) )),

                ),








              ],
            ),
          ),
        ),

      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:Color(0xffF2E9DB),
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Géolocalisation',
          style: TextStyle(
              color: Color(0xffF2E9DB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
          moveToLastSreen() ;
        }),
      ),

      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            _image(),

            _switch(),
          ],
        ),
      ),
    );
  }
  moveToLastSreen(){
    Navigator.pop(context) ;
  }
}