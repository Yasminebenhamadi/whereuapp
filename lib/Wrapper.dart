import 'package:flutter/material.dart';
import 'package:whereuapp/authentication/Connection.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/home/home_page_2.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return either Home or Authenticate depending on the Firebase.Auth instance
    if (Provider
        .of<User>(context)
        .utilisateur == null)
      return Connection();
    /*else {
      return CreatePage();
    }*/
    else
      return HomePages_2();
  }
}
class User  extends ChangeNotifier {
  Utilisateur _utilisateur;
  final ServicesAuth _servicesAuth = ServicesAuth();

  void setUtilisateur (Utilisateur utilisateur){
    _utilisateur = utilisateur;
    notifyListeners();
  }
  void onUserModified (){
    notifyListeners();
  }
  void signOut (){
    if(_utilisateur!=null){
      _servicesAuth.signOut(_utilisateur.sharableUserInfo.id);
      _utilisateur = null ;
      notifyListeners();
    }
  }
  void delete () async {
    if(_utilisateur!=null){
      await _servicesAuth.delete();
      await _utilisateur.delete();
      _utilisateur = null;
      notifyListeners();
    }
  }
 Utilisateur get utilisateur => _utilisateur;
}

