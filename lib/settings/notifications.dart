import 'package:flutter/material.dart';

class NotifPage extends StatefulWidget {
  @override
  _NotifPageState createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  bool value1 = true;

  bool value5 = true;
  void onChangedValue1(bool value) {
    setState(() {
      value1 = value;
    });
  }

  void onChangedValue5(bool value) {
    setState(() {
      value5 = value;
    });
  }

  Widget _image() {
    return Positioned(
      top: 24,
      child: Image(
        image: AssetImage("bell.png"),
        height: 250,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget _switch() {
    return Positioned(
      top: 280,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 350,
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
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new SwitchListTile(
                  value: value5,
                  onChanged: onChangedValue5,
                  activeColor: Colors.deepOrange,
                  secondary: new Icon(
                    Icons.battery_alert,
                    color: Color(0xffE8652D),
                  ),
                  title: new Text('Batterie utilisateur faible',
                      style:
                      TextStyle(fontSize: 18.0, color: Color(0xff739D84))),
                  subtitle: new Text(
                      "Prévenez-moi lorsque la batterie de quelqu'un est sur le point de se vider")),
              SizedBox(
                height: 20,
              ),
              new SwitchListTile(
                value: value1,
                onChanged: onChangedValue1,
                activeColor: Colors.deepOrange,
                secondary: new Icon(
                  Icons.trending_up,
                  color: Color(0xffE8652D),
                ),
                title: new Text('Vitesse maximum ',
                    style: TextStyle(fontSize: 18.0, color: Color(0xff739D84))),
                subtitle: new Text(
                    "M'avertir lorsqu'un membre atteint la vitesse maximale de 120km/h "),
              ),
            ],
          ),
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
          'Notification',
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
            _switch(),
          ],
        ),
      ),
    );
  }
  moveToLastSreen(){
    Navigator.pop(context) ;
  }
}
