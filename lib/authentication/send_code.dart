import 'package:flutter/material.dart';
import 'package:whereuapp/authentication/Phone.dart';
import 'package:whereuapp/authentication/verification_code.dart';
import 'package:whereuapp/servises/auth.dart';

// ignore: camel_case_types
class Send extends StatefulWidget {
  final String phoneNumber ;
  Send({this.phoneNumber});
  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  ServicesAuth _servicesAuth = ServicesAuth();
  Future<void> _sendCode () async {
    try {
      await _servicesAuth.sendVerificationCode(widget.phoneNumber);
    }
    catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff739D84),
        body:Column(children: <Widget>[
          Container(
              alignment: Alignment.topRight,
              child: SendUpImageAsset()
          )
          ,
          SizedBox(
            height: 10.0,
          ),
          Text('Un code de vérification va être',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),Text('envoyer au numero suivant',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),Text('${widget.phoneNumber}',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),
          SizedBox(
            height: 100.8,
          ),
          Stack(
              alignment: Alignment.center,
              children :<Widget>[
                Container(
                    alignment: Alignment.bottomRight,
                    child: SendDownImageAsset()
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 0.0,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          width: 250.0,
                          child: RaisedButton(
                            elevation: 5.0,
                            onPressed: () async {
                              await _sendCode();
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Verify(phoneNumber: widget.phoneNumber,servicesAuth:_servicesAuth))) ;
                           },
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            color: Color(0xffE8652D),
                            child: Text(
                              'Envoyer le code',
                              style: TextStyle(
                                  color: Color(0xffF1B97A),
                                  letterSpacing: 1.5,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),


                    Container(
                      alignment: Alignment.center,
                      width: 250.0,
                      child:  FlatButton(
                        child:
                        Text("Annuler",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color:Color(0xFFF1B97A),
                          ),
                        ),
                        onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Phone())) ;},
                      ),
                    ),


                  ],
                )
              ])

        ]));
  }
}

class SendUpImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('assets/images/shapeup.png',);
    Image image = Image(image: assetImage , width: 411.0,fit: BoxFit.cover);
    return Container(child: image,);
  }

}class SendDownImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('assets/images/shapedown.png',);
    Image image = Image(image: assetImage , height: 220.0 ,fit: BoxFit.cover, alignment: Alignment.bottomLeft,);
    return Container(child: image,);
  }
}


