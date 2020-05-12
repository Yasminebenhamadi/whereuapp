import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/groupe/cercle.dart';
import 'package:whereuapp/authentication/verification_code.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class transition extends StatefulWidget {
  @override
  _TransitionState createState() => _TransitionState();
}

// ignore: camel_case_types
class _TransitionState extends State<transition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF2E9DB),
        body:Stack(children: <Widget>[
          Container(
              alignment: Alignment.topCenter,
              child:
              ShapeImageAsset()
          )
          ,
          Container(
              padding: EdgeInsets.only(left: 20.0, right: 10.0),
              alignment: Alignment.topCenter,
              child: Column(

                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  Text('Salut ${Provider.of<User>(context).utilisateur.sharableUserInfo.displayName}!\nMaintenant vous pouvez rejoindre ou créer votre cercle',
                  style: TextStyle(
                    color: Color(0xffF2E9DB),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 0.0,
                  ),
                  ImageImageAsset(),
                  SizedBox(
                    height: 0.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 25.0),
                    width: 220.0,
                    child: RaisedButton(
                      elevation: 5.0,
                      onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> cercle())) ;},
                      padding: EdgeInsets.all(15.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      color: Color(0xffE8652D),
                      child: Text(
                        'Continuer',
                        style: TextStyle(
                            color: Color(0xffF1B97A),
                            letterSpacing: 1.5,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: 550.0,
                    child:  FlatButton(
                      child:
                      Text("Annuler",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color:Color(0xFFF1B97A),
                        ),
                      ),
                      onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Verify())) ;},
                    ),
                  ),
                ],
              )


          ),



        ]));
  }
}

class ImageImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('assets/images/image.png',);
    Image image = Image(image: assetImage ,  height  : 300.0, fit: BoxFit.cover);
    return Container(child: image,);
  }

}
class ShapeImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('assets/images/shape.png',);
    Image image = Image(image: assetImage , height: 360.0 ,width :550.0, fit: BoxFit.cover, alignment: Alignment.bottomLeft,);
    return Container(child: image,);
  }
}


