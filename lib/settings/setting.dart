import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:provider/provider.dart';
import 'cercles_user.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/cupertino.dart';
import 'notifications.dart';
import 'geolocalisation.dart';
import 'trajet.dart';
import 'compte.dart';
import 'security.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>{
  Utilisateur utilisateur ;
  final StorageService _storageService = StorageService();

  Widget _avatar() {
    return Positioned(
      top: 25,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 200,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(

            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow : [BoxShadow (
              color:Colors.black12,
              blurRadius:10.0,
              offset:new Offset(10.0,10.0),)]

        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              Row( children: <Widget>[
                Icon(Icons.settings ,size : 35.0 , color:  Color(0xffE8652D)),
                SizedBox(
                  width: 20,
                ),
                Text("Réglages",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35,color: Color(0xff739D84),),
                ),


              ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children:<Widget>[
                  Container (
                    decoration : new  BoxDecoration  (
                        shape: BoxShape.circle,
                        boxShadow : [ new BoxShadow (
                          color:Colors.black12,
                          blurRadius:10.0,
                          offset:new Offset(0.0,10.0),) ]),

                    child:  /*CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child : Icon (Icons.perm_identity , color:  Color(0xffE8652D) , size : 50.0 ,  ),


                    ),*/
                    FutureBuilder(
                      future: _storageService.usersPhoto(
                          utilisateur.sharableUserInfo.photo,utilisateur.sharableUserInfo.photoPath,utilisateur.sharableUserInfo.gender), //Photo
                      builder : (context,asyncSnapshot) => CircleAvatar(
                        radius: 45,
                        backgroundImage: asyncSnapshot.data,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 40,
                  ),
                  Text(utilisateur.sharableUserInfo.displayName, style: TextStyle( fontSize: 30,color: Color(0xff739D84),)),
                ],),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settings() {
    return Positioned(
      top: 270,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 464,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow : [BoxShadow (color:Colors.black12,
                blurRadius:20.0,
                offset:new Offset(10.0,10.0)),]),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SettingsSection(
                tiles: [
                  SettingsTile(title: 'Notifications' , leading: Icon(Icons.notifications ,
                      color:  Color(0xffE8652D)),
                      onTap : ()=> Navigator.of(context).push(new MaterialPageRoute( builder :
                          (BuildContext context ) => new NotifPage(),
                      ),)),
                  SettingsTile(title: 'Gestion du cercle', leading: Icon(Icons.group,color:

                  Color(0xffE8652D)) ,
                      onTap : ()=> Navigator.of(context).push(new MaterialPageRoute( builder :
                          (BuildContext context ) => new cercleUser(),))
                  ),

                  SettingsTile(
                      title: 'Géolocalisation',
                      leading: Icon(Icons.map , color:  Color(0xffE8652D)),
                      onTap : ()=> Navigator.of(context).push(new MaterialPageRoute( builder :
                          (BuildContext context ) => new GeoPage(),))),

                  SettingsTile(title:'Compte',
                      leading: Icon(Icons.account_circle,color:  Color(0xffE8652D)),
                      onTap : ()=> Navigator.of(context).push(new MaterialPageRoute( builder : (BuildContext context ) => new SettingsOnePage(),))),
                  SettingsTile(
                      title: 'Détection du trajet',

                      leading: Icon(Icons.time_to_leave,color:  Color(0xffE8652D)),onTap : ()=> Navigator.of(context).push(new MaterialPageRoute( builder : (BuildContext context ) => new TrajetPage(),))
                  ),
                  SettingsTile(
                      title: 'Sécurité et confidentialité',
                      leading: Icon(Icons.security,color:  Color(0xffE8652D)),
                      onTap : ()=> Navigator.of(context).push(new MaterialPageRoute( builder :
                          (BuildContext context ) => new SecurityPage(),))),
                  SettingsTile(title:'Déconnecter', leading: Icon(Icons.exit_to_app ,color:
                  Color(0xffE8652D)), onTap: (){showDialog(barrierDismissible:false ,
                    context: context ,
                    builder : (context){ return AlertDialog( title: Text("Se déconnecter ?", style: TextStyle( color: Color(0xff739D84),)),
                      actions: <Widget> [
                        FlatButton ( child: Text ('Oui', style: TextStyle( color:  Color(0xffE8652D),)), onPressed:(){
                          Provider.of<User>(context, listen: false).signOut();
                          Navigator.pop(context);
                        }
                          ),
                        FlatButton ( child: Text ('Non',
                            style: TextStyle( color:  Color(0xffE8652D),)),
                            onPressed:(){Navigator.pop(context);}),
                      ],
                    );
                    },
                  ) ;
                  } ,
                  ),
                ],

              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      utilisateur = Provider.of<User>(context, listen: false).utilisateur;
    });
    return Scaffold(
      backgroundColor: Color(0xffF2E9DB),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),

            _avatar(),
            _settings(),
          ],
        ),
      ),
    );
  }
}