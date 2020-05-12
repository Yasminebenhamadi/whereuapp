import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:provider/provider.dart';


class GenrePage extends StatefulWidget {
  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  Utilisateur utilisateur;
  bool  homme ;
  bool femme  ;
  @override
  void initState() {
    super.initState();
    utilisateur = Provider.of<User>(context, listen: false).utilisateur;
    print(utilisateur.sharableUserInfo.gender);
    print(utilisateur.sharableUserInfo.gender == Gender.Male);
    print(utilisateur.sharableUserInfo.gender == Gender.Female);
    homme  = utilisateur.sharableUserInfo.gender == Gender.Male ;
    femme  = utilisateur.sharableUserInfo.gender == Gender.Female ;
  }

  Widget _text() {
    return Positioned(
      top: 200,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 200,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: new Offset(10.0, 10.0),
              )
            ]),
        child: Column (
            children: <Widget>[
              SizedBox( height:25.0),
              Text( ' Vous êtes' , style:TextStyle(color:Color(0xffE8652D), fontWeight: FontWeight.bold, fontSize: 25.0),),
              SizedBox( height:25.0),


              Row( children: <Widget>[
                SizedBox( width :30.0),
                Text( "Homme",style:TextStyle(color:Color( 0xff739D84), fontSize: 18.0)),
                Checkbox(

                  value: homme,
                  activeColor : Color( 0xffE8652D),
                  checkColor: Colors.white,
                  onChanged: ( bool value){ setState(() {
                    if (value)
                      utilisateur.setGender(Gender.Male);
                    homme =value; femme = !value; });},

                ),
              ]
              ) ,
              SizedBox( height: 10.0),
              Row( children: <Widget>[
                SizedBox( width : 30.0),
                Text( "Femme",style:TextStyle(color:Color( 0xff739D84), fontSize: 18.0)),
                Checkbox(

                  value: femme,
                  activeColor : Color(0xffE8652D),
                  checkColor: Colors.white,
                  onChanged: ( bool value){ setState(() {
                    if (value)
                      utilisateur.setGender(Gender.Female);
                    femme =value;
                    homme = !value ;
                  });},

                ),
              ]
              ) ,


            ]
        ),

      ),

    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Modifier le sexe',
          style: TextStyle(
              color: Color(0xffF2E9DB),
              fontSize: 17.0,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(icon: Icon(Icons.clear), onPressed: () {
          moveToLastSeen() ;
        }),
      ),
      backgroundColor:Color(0xffF2E9DB),

      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            _text(),
          ],
        ),
      ),
    );
  }
  moveToLastSeen(){
    Navigator.pop(context) ;
  }
}