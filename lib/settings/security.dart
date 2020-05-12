import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  Widget _image() {
    return Positioned(
      top: 24,
      child: Image(
        image: AssetImage("security.png"),
        height: 250,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget _text() {
    return Positioned(
      top: 280.0,
      child: Container(

        margin: EdgeInsets.all(20),
        height: 310,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20.0),
            Container(
              width: 320.0,
              child :
            Text(
                "Lorsque vous utilisez nos services, vous nous faites confiance pour le traitement de vos informations. Nous savons qu'il s'agit d'une lourde responsabilité, c'est pourquoi nous nous efforçons de les protéger, tout en vous permettant d'en garder le contrôle.",
                style: TextStyle(fontSize: 18 , color: Colors.black ),
                textAlign: TextAlign.justify),) ,
            SizedBox(height: 10.0),
            Icon(Icons.done_all, size: 60.0, color: Color(0xFFF57C00)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Sécurité et confidentialité',
          style: TextStyle(
              color: Color(0xffF2E9DB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
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
    );
  }
  moveToLastSreen(){
    Navigator.pop(context) ;
  }
}
