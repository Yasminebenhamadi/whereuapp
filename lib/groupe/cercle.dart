import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/groupe/createcercle.dart';
import 'package:whereuapp/groupe/join.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/transition.dart';

// ignore: camel_case_types
class cercle extends StatefulWidget {
  @override
  _CercleState createState() => _CercleState();
}

class _CercleState extends State<cercle> {

  bool completed = false;

  String invitationCode;
  String errorText; //TODO show error text

  FirestoreService _firestoreService = FirestoreService();


  var outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Colors.transparent),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Color(0xff739D84)),
            backgroundColor: Color(0xffF2E9DB),
            leading: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => transition()));
              },)
        ),
        backgroundColor: Color(0xff739D84),
        body: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
            decoration: BoxDecoration(
                color: Color(0xffF2E9DB),
                //boxShadow: [BoxShadow(
                //color: Color(0xffF2E9DB),
                //blurRadius: 20,
                //offset: Offset(0.0, 10.0)
                //)],
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60.0),
                    bottomRight: Radius.circular(60.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Text(
                  "Rejoignez un cercle ? ",
                  style: TextStyle(
                      color: Color(0xff739D84),
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text("Veuillez entrer votre code d'invitation",
                  style: TextStyle(
                      color: Color(0xff739D84),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  widthFactor: 350,
                  child: OTPTextField(
                    length: 5,
                    width: 350,
                    fieldWidth: 50,
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff739D84),
                        fontWeight: FontWeight.bold
                    ),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    keyboardType: TextInputType.text,
                    fieldStyle: FieldStyle.box,

                    onCompleted: (pin) {
                      invitationCode = pin;
                      completed = true;
                      print("Completed: " + pin);
                    },
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'NOTE : Vous pouvez demander le code au créateur du cercle',
                  style: TextStyle(
                      color: Color(0xff739D84),
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0
                  ),
                ),
                SizedBox(
                  height: 1.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 25.0),
                      width: 300.0,
                      child: RaisedButton(
                        elevation: 5.0,
                        onPressed: () async {
                          if (completed) {
                            DocumentSnapshot groupInfo = await _firestoreService
                                .groupFromCode(invitationCode);
                            if (groupInfo != null)
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) =>
                                      JoinConfirme(groupInfo: groupInfo,)));
                            else
                              errorText =
                              'Aucun group avec ce code , verifier votre code ou demender le a créateur de cercle';
                          }
                          else
                            errorText =
                            'Entrer le code complé s\'il vous plaiz';
                        },
                        padding: EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0)),
                        color: Color(0xffF1B97A),
                        child: Text(
                          'Confirmer mon code',
                          style: TextStyle(
                              color: Color(0xffE8652D),
                              letterSpacing: 1.5,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 200.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 0.0,
                ),
                Text('______________________ OU ______________________',
                  style: TextStyle(
                      color: Color(0xffF2E9DB),
                      fontWeight: FontWeight.normal,
                      fontSize: 10.0
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text("Vous n'avez pas de code ?",
                  style: TextStyle(
                      color: Color(0xffF2E9DB),
                      fontWeight: FontWeight.normal,
                      fontSize: 11.0
                  ),
                ), Text("On va vous donner un code ",
                  style: TextStyle(
                      color: Color(0xffF2E9DB),
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0
                  ),
                ), Text("pour le partager",
                  style: TextStyle(
                      color: Color(0xffF2E9DB),
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      width: 300.0,
                      child: RaisedButton(
                        elevation: 10.0,
                        padding: EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0)),
                        color: Color(0xffE8652D),
                        child: Text(
                          'Créer mon cercle',
                          style: TextStyle(
                              color: Color(0xffF1B97A),
                              letterSpacing: 1.5,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => CreatePage()));
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ]));
  }
}


