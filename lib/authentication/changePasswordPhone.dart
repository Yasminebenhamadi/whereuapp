import 'package:flutter/material.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:whereuapp/unknownError.dart';

/*import 'package:provider/provider.dart';*/
class MotPagePhone extends StatefulWidget {
  @override
  _MotPagePhoneState createState() => _MotPagePhoneState();
}

class _MotPagePhoneState extends State<MotPagePhone> {
  final formKey = GlobalKey<FormState>();

  final bool obscureText = false;
  final ServicesAuth _servicesAuth = ServicesAuth();
  String newPassword,confirmPassword;


  void _submitCommand() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      try {
        _servicesAuth.changePasswordPhone(newPassword);
      }
      catch (e) {
        print('UKNOWN_ERROR');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> unknownError (context)));
        return null;
      }
    }
  }
  Widget _text() {
    return Positioned(
      top: 30,
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
        child: Form(
          key: formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container (
                  width: 330.0,
                  child :
                  TextFormField(
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff739D84))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffE8652D))),
                        hintText: "Nouveau mot de passe ",
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                          color: Color(0xff739D84),
                        )),
                    obscureText: true,
                    onSaved: (val) => newPassword = val,
                    validator: (val) {
                      if (val.isEmpty)
                        return 'Saisisser le nouveau mot de passe s\'il vous plait';
                      else if (val.length < 6)
                        return 'Votre mot de passe doit contenir aumoin 6 caractères';
                      else
                        return null;
                    },
                  ),),
                SizedBox(
                  height: 10.0,
                ),
                Container (
                  width: 330.0,
                  child :
                  TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff739D84))),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffE8652D))),
                      hintText: "Confirmer ",
                      hintStyle:
                      TextStyle(color: Color(0xff739D84), fontSize: 20.0 , ),
                    ),
                    obscureText: true,
                    onSaved: (val) => confirmPassword = val,
                    validator: (val) {
                      if (val.isEmpty)
                        return 'Confirmer le nouveau mot de passe s\'il vous plait';
                      else if (confirmPassword !=  newPassword)
                        return 'Les deux mots de passe ne sont pas identique';
                      else
                        return null;
                    },
                  ),),
                SizedBox(height: 50.0),
                RaisedButton(
                  elevation: 5.0,
                  padding: EdgeInsets.all(15.0),
                  onPressed: () => _submitCommand (),
                  child: Text('  Enregistrer  ', style: TextStyle(color: Color(0xffE8652D),
                      letterSpacing: 1.5,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold)),
                  color: Color(0xffF1B97A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: (){
          return moveToLastSreen() ;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
            backgroundColor: Color(0xff739D84),
            title: Text(
              'Changer votre mot de passe',
              style: TextStyle(
                  color: Color(0xffF2E9DB),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            leading: IconButton(icon: Icon(Icons.clear), onPressed: () {
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
                _text(),
              ],
            ),
          ),
        ));
  }
  moveToLastSreen(){
    Navigator.pop(context) ;
  }
}