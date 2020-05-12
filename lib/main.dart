import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/servises/MessagesService.dart';
import 'package:provider/provider.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:whereuapp/servises/firestore.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  App () ;
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final MessagingService messagingService = MessagingService();
  final ServicesAuth _servicesAuth = ServicesAuth();
  final FirestoreService _firestoreService = FirestoreService();
  User user  = User ();
  @override
  Widget build(BuildContext context) {
    messagingService.configure();
    return ChangeNotifierProvider<User>(
      create: (context) => user,
      child: MaterialApp(
        home: Wrapper() ,
        debugShowCheckedModeBanner: false,
      ),
    ) ;
  }

  Widget logo (){
    return Scaffold(
      backgroundColor: Color(0xff739D84),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset("assets/logo_white_version.png", width: 100 , height:100),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
    );
  }
}
