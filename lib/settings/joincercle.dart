import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whereuapp/groupe/join.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
class Join extends StatefulWidget {
  @override
  _JoinState createState() => _JoinState();
}

// ignore: camel_case_types
class _JoinState extends State<Join> {

  bool completed = false;

  String invitationCode;
  String errorText;

  FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
          backgroundColor: Color(0xff739D84),
          title: Text(
            'Rejoindre un cercle',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 50.0,),
          Text("Saisissez le code d'invitation" ,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0 ,
              color: Color(0xff739D84)
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            widthFactor: 350,
            child: OTPTextField(
              length: 5,
              width: 350,
              fieldWidth: 50,
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff739D84) ,
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
            height: 20.0,
          ),
          Text("Vous pouvez obtenir ce code auprés d'une personne\ndu cercle que vous souhaitez rejoindre" ,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.0 ,
                color: Colors.black45
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          SizedBox(
            height: 20.0,
          ) ,
          RaisedButton(
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
              '      Continuer      ',
              style: TextStyle(
                  color: Color(0xffE8652D),
                  letterSpacing: 1.5,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      )
    );
  }
  moveToLastSreen() {
    Navigator.pop(context);
  }
}