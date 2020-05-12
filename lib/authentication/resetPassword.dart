import'package:flutter/material.dart';
import'telephone.dart';
import'adresse.dart';

class MotDePassePage extends StatefulWidget {
  @override
  _MotDePassePageState createState() => _MotDePassePageState();
}

class _MotDePassePageState extends State<MotDePassePage> {

  Widget _text() {

    /* onTap: (){showDialog(barrierDismissible:false ,
    context: context ,
builder : (context){*/
    return Positioned(
      top : 150 ,

      child:
      AlertDialog( title: Text("Mot de passe oublié?", style: TextStyle( color: Color(0xff739D84), fontWeight:FontWeight.bold ,fontSize: 20.0)),

        actions: <Widget> [

          Column( children : <Widget> [
            Text(' Comment réinitialiser votre mot de passe?', style : TextStyle( fontSize:15.0,color:Color(0xffE8652D)) ),
            SizedBox( height:10.0),

            FlatButton(

              onPressed:() =>Navigator.of(context).push(new MaterialPageRoute( builder : (BuildContext context ) => new PhonePage(),)),

              padding :EdgeInsets.all(15.0),
              child: Text('Par téléphone', style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
              color:  Color(0xffF1B97A),
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
              textColor: Color(0xffE8652D),
            ),
            SizedBox(height:10.0,),

            RaisedButton(
              onPressed:() => Navigator.of(context).push(new MaterialPageRoute( builder : (BuildContext context ) => new AdressePage(),)),

              padding :EdgeInsets.all(15.0),
              child: Text('Par adresse ', style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
              color:  Color(0xffF1B97A),
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
              textColor: Color(0xffE8652D),
            ),
          ]
          )
        ],
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
}