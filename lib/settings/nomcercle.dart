import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:provider/provider.dart';

class NamecerclePage extends StatefulWidget {
  /*final Group group ;
  final Widget previous ;
  NamecerclePage({this.group,this.previous});*/
  @override
  _NamecerclePageState createState() => _NamecerclePageState();
}

class _NamecerclePageState extends State<NamecerclePage> {
  final formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  File groupsPhoto;
  String nom ;
  Group group ;

  Widget _image() {

    return Center(child :
    Column ( children : <Widget> [
      SizedBox( height:40.0),
      Container (
        decoration : new  BoxDecoration  (
            shape: BoxShape.circle,
            boxShadow : [ new BoxShadow (
              color:Colors.black12,
              blurRadius:10.0,
              offset:new Offset(0.0,10.0),) ]),

        child: FutureBuilder(
          future : _storageService.groupsImage(group.photo, group.groupPhoto),
          builder: (context,asyncSnapshot) {
            ImageProvider image = asyncSnapshot.data ;
            return CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: groupsPhoto != null ? FileImage(groupsPhoto) : image, // No image selected but group has image
            child :
            IconButton(
              icon : Icon (Icons.group , color: Color(0xffE8652D) , size : 65.0 ,  ),
              onPressed: () async {
                try {
                  File photo = await _storageService.pickPhoto();
                  setState(() {
                    groupsPhoto = photo;
                  });
                } catch (e) {
                  print(e);
                }
              },
            ),

          );
            }
        ),
      ),



    ],
    ),

    );
  }
  Widget _text() {
    return
      Positioned(
        top: 180,

        child: Container(
          margin: EdgeInsets.all(20),
          height: 180,
          width: MediaQuery.of(context).size.width * 0.90,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow : [BoxShadow (
                color:Colors.black12,
                blurRadius:10.0,
                offset:new Offset(10.0,10.0),)]),

          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300.0,
                  child :
                  TextFormField(
                    decoration :InputDecoration (
                      enabledBorder:UnderlineInputBorder(borderSide :BorderSide(color:Color(0xff739D84))),
                      focusedBorder:UnderlineInputBorder(borderSide :BorderSide(color:Color(0xffE8652D))),
                      hintText:"nom du cercle",
                      hintStyle:TextStyle(color:Color(0xff739D84), fontSize: 20.0),
                    ),
                    onSaved: (val) {
                      nom = val;
                    },
                  ),),
                SizedBox(height: 30.0,),
                SizedBox( height: 10.0),
                RaisedButton(
                  onPressed: () {
                    formKey.currentState.save();
                    if(nom!=null && nom!=''){
                      group.setNom(nom);
                    }
                    if(groupsPhoto!=null){
                      group.setPhoto(groupsPhoto);
                    }
                  },
                    padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  color: Color(0xffF1B97A),
                  child: Text('  Enregistrer  ' , style : TextStyle( color: Color(0xffE8652D),
                      letterSpacing: 1.5,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                  ),)
              ],
            ),
          ),
        ),
      );
  }
  @override
  void initState() {
     super.initState();
     group = Provider.of<User>(context).group;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
           await moveToLastSreen() ;
           return true ;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
            backgroundColor: Color(0xff739D84),
            title: Text(
              'Changer le nom et la photo du cercle',
              style: TextStyle(
                  color: Color(0xffF2E9DB),
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold),
            ),
            leading: IconButton(icon: Icon(Icons.clear), onPressed: () {
              moveToLastSreen() ;
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

                _image(),
                _text(),
              ],
            ),
          ),
        ));
  }
  moveToLastSreen() {
      Navigator.pop(context);
  }
}