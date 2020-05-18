import 'package:flutter/material.dart';
import 'package:whereuapp/authentication/Connection.dart';
import 'package:whereuapp/classes/Groupe.dart';
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
  Group _group;
  final ServicesAuth _servicesAuth = ServicesAuth();
  User () ;
  User.utilisateur (Utilisateur utilisateur){
    _utilisateur = utilisateur ;
  }
  void setUtilisateur (Utilisateur utilisateur){
    _utilisateur = utilisateur;
    notifyListeners();
  }
  void setGroup (Group group){
    _group = group;
    notifyListeners();
  }
  void onUserModified (){
    notifyListeners();
  }
  Future<void> signOut () async {
    if(_utilisateur!=null){
      await _servicesAuth.signOut(_utilisateur.sharableUserInfo.id);
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
  Group get group  => _group ;
}

