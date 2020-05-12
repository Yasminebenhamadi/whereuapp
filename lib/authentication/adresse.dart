import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';
import 'package:whereuapp/authentication/Connection.dart';
import 'package:whereuapp/servises/auth.dart';




class AdressePage extends StatefulWidget {
  @override
  _AdressePageState createState() => _AdressePageState();
}

class _AdressePageState extends State<AdressePage> {

  final formKey = GlobalKey<FormState>();
  String _email;
  ServicesAuth _servicesAuth = ServicesAuth();


  Widget _text() {
    return Positioned(
      top: 200,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 250,
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
            SizedBox( height :20.0),
            Text( ' Veuillez utiliser votre adresse e-mail pour réinitialiser votre mot de passe . ' , style:TextStyle( fontSize:15.0 , fontWeight:FontWeight.bold, color:Color(0xFFF57C00 )  ) ,
                textAlign:TextAlign.center ),
            SizedBox( height:25.0),
            Row( children: <Widget>[


              SizedBox(  width : 18.0),


              Form(
                key :  formKey,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[


                    Center( child:  Container(
                      alignment: Alignment.centerLeft,


                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.0,
                            offset: Offset(0,2 ),
                          ),
                        ],),
                      height: 60.0,
                      width: 340,
                      child:
                      Row(
                        children: <Widget>[


                          SizedBox( height:3.0),
                          Expanded (child :
                          Form(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,),
                                  hintText: "Adresse e-mail",
                                  hintStyle: TextStyle(
                                    color: Color(0xff739D84),
                                    letterSpacing: 1.5,
                                    fontSize: 18.0,
                                  )),
                              validator: (val)  {
                                if (val.isEmpty)
                                  return 'Saisissez votre email s\'il vous plait' ;
                                else if (!EmailValidator.validate(val, true))
                                  return 'Cet email n\'est pas valide' ;
                                else
                                  return  null;
                              },
                              onSaved: ( String val){_email = val; },
                              textAlign:TextAlign.center,
                            ),
                          )),
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ],
            ),

            SizedBox( height : 20.0),

            FlatButton(
              padding :EdgeInsets.all(15.0),
              onPressed: () {
                try{
                  if(formKey.currentState.validate()){
                    formKey.currentState.save();
                    _servicesAuth.resetPasswordEmail(_email);
                  }
                }
                catch(e){
                  print(e);
                }
              },
              child: Text('Envoyer', style : TextStyle(fontSize:20.0, fontWeight: FontWeight.bold)),
              color: Color(0xFFf1B97A),
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
              textColor: Color(0xffE8652D),
            )
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  AlertDialog emailSent (BuildContext context){
    return AlertDialog(
      title: Text("Email envoyé",
          style: TextStyle(
            color: Color(0xff739D84),
          )),
      content: Text(
          "Un email pour recupérer le mot de passe a été envoyé .Verifier votre boite de mail"),
      actions: <Widget>[
        FlatButton(
            child: Text('Okay',
                style: TextStyle(
                  color: Color(0xffE8652D),
                )),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Connection ()));
            }),
      ],
    );
  }
}