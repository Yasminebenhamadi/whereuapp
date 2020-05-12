import 'package:flutter/material.dart';


class Msg2Page extends StatefulWidget {
  @override
  _Msg2PageState createState() => _Msg2PageState();
}

class _Msg2PageState extends State<Msg2Page> {
  

  Widget _text() {
    return Positioned(
      top: 250,
      child: Column(
       
       crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[ 
          
         
               
           
            Row( children :<Widget> [
             SizedBox( width:40.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(20.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text("Réduire votre vitesse,SVP ", style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 6.0),
                  Image.asset('assets/speedometer.png', height:40 , width:40 ),
          ])),
            ]),
            
        
               
           
          ]
         
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
