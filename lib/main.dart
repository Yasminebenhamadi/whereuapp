import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/MessagesService.dart';
import 'package:provider/provider.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'unknownError.dart' ;

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
  User user = User () ;
  @override
  Widget build(BuildContext context) {
    messagingService.configure();
    //getUser();
    return ChangeNotifierProvider<User>(
      create: (context) => user,
      child: MaterialApp(
        home: Wrapper () , //home() ,
        debugShowCheckedModeBanner: false,
      ),
    ) ;
  }
  Widget home (){
    if(user == null)
      return logo();
    else
      return Wrapper();
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
  Future<void> getUser () async {
    if(await _servicesAuth.isSignedIn()){
      try {
        Utilisateur utilisateur;
        String uid = await _servicesAuth.userID();
        SharableUserInfo usersInfo = await _firestoreService.getUserInfo(uid);
        utilisateur = Utilisateur.old(uid,usersInfo);
        setState(() {
                user = User.utilisateur(utilisateur);
              });
      } catch (e) {
        print(e);
        Navigator.push(context, MaterialPageRoute(builder: (context)=> unknownError (context)));
      }
    }
    else{
      setState(() {
        user = User() ;
      });
    }
  }
}
