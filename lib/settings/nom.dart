import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:provider/provider.dart';

class NamePage extends StatefulWidget {
  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();

  Utilisateur utilisateur;
  Map data = {'name': String, 'email': String, 'age': int};
  File usersPhoto ;
  String displayName;

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
            future : _storageService.usersPhoto(utilisateur.sharableUserInfo.photo, utilisateur.sharableUserInfo.photoPath,utilisateur.sharableUserInfo.gender),
            builder: (context,asyncSnapshot) {
              ImageProvider image = asyncSnapshot.data ;
              return CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: usersPhoto != null ? FileImage(usersPhoto) : image, // No image selected but group has image
                child :
                IconButton(
                  icon : Icon (Icons.group , color: Color(0xffE8652D) , size : 65.0 ,  ),
                  onPressed: () async {
                    try {
                      File photo = await _storageService.pickPhoto();
                      setState(() {
                        usersPhoto = photo;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                ),

              );
            }
        ),/*CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child : Icon (Icons.perm_identity , color: Color(0xffE8652D) , size : 65.0 ,  ),
        ),*/
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
                    hintText:"nom",
                    hintStyle:TextStyle(color:Color(0xff739D84), fontSize: 20.0),
                  ),
                  onSaved: (val){
                    if(val.isNotEmpty)
                      displayName = val ;
                  },
                ),),
                SizedBox(height: 30.0,),
                SizedBox( height: 10.0),
                RaisedButton(
                  onPressed: () {
                    formKey.currentState.save();
                    if(displayName !=null && displayName !='' ){
                      utilisateur.setDisplayName(displayName);
                    }
                    if(usersPhoto!=null){
                      utilisateur.setPhoto(usersPhoto);
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
    utilisateur = Provider.of<User>(context, listen: false).utilisateur; 
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: (){
      return moveToLastSreen() ;
    },
    child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Changer votre nom et photo de profil',
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
  moveToLastSreen(){
    Navigator.pop(context) ;
  }
}