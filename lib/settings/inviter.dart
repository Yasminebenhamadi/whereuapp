import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class InvitePage extends StatefulWidget {
  /*final Group group ;
  final Widget previous ;
  InvitePage({this.group,this.previous});*/
  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {

  final formkey = GlobalKey <FormState>();
  Group group ;
  /*Widget _avatar() {
    return Positioned( child : Row ( children:<Widget> [
      SizedBox( width :80.0),
      Image(   image: AssetImage("send.png"),
        height: 250 ,
        width: 250 ,)
    ]
    ),
    );
  }*/

  Widget _code() {
    return Positioned(
      top: 30, // hint text + code + en bas un autre bouton send
      child: Column ( children: <Widget>[ Container(
        margin: EdgeInsets.all(20),
        height: 400,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20.0,
                  offset: new Offset(10.0, 10.0)),
            ]),
        child: Container(
          height: 200,
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0),
              Container (
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child : Image(   image: AssetImage("groupe.png"),height: 300, width: 300,)
                ),),
              Text(
                group.nom,
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff739D84)),
                textAlign: TextAlign.center,),
              SizedBox( height: 30.0),
              TextField(  enabled :false , textAlign : TextAlign.center, decoration: InputDecoration(border :InputBorder.none,  hintText:group.code , hintStyle: TextStyle(
                  fontSize:40.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffE8652D))
              )),
              SizedBox( height: 30.0),
              Text(
                " Partager ce code PIN avec les personnes pour qu'elles rejoignent votre cercle ",
                style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xff739D84)),
                textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
        SizedBox( height:20.0),
        Row( children:<Widget> [
          RaisedButton(
            onPressed:() => Share.share(group.code),
            padding :EdgeInsets.all(15.0),
            child: Text("  Partager le code d'invitation  ", style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
            color:  Color(0xffE8652D),
            shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
            textColor: Color(0xffF1B97A),
          ),

        ],
        ),
      ] ,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    setState((){
      group = Provider.of<User>(context).group;
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Inviter des gens',
          style: TextStyle(
              color: Color(0xffF2E9DB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              moveToLastSreen();
            }),
      ),
      backgroundColor: Color(0xffF2E9DB),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            _code(),

          ],
        ),
      ),
    );
  }
  moveToLastSreen() {
      Navigator.pop(context);
  }
}
