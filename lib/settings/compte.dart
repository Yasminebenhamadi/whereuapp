import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:whereuapp/unknownError.dart';
import 'package:provider/provider.dart';
import 'phone.dart';
import 'nom.dart';
import 'adresse.dart';
import 'motdepasse.dart';
import 'genre.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }



  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
        this.currentLeftIndex(), this.currentMiddleIndex(), this.currentRightIndex())
        : DateTime(currentTime.day, currentTime.month, currentTime.year, this.currentLeftIndex(),
        this.currentMiddleIndex(), this.currentRightIndex());
  }
}

class SettingsOnePage extends StatefulWidget {
  @override
  _SettingsOnePageState createState() => _SettingsOnePageState();
}

class _SettingsOnePageState extends State<SettingsOnePage> {
  Utilisateur utilisateur;
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    setState(() {
      utilisateur = Provider.of<User>(context, listen: false).utilisateur;
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Compte',
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
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 70.0),
                Card(

                  margin: const EdgeInsets.all(10.0),
                  elevation: 20.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Color(0xff739D84),
                  child: ListTile(
                    onTap: () =>
                        Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new NamePage(),
                    )),
                    title: Text(utilisateur.sharableUserInfo.displayName, style: TextStyle(color: Colors.white)),
                    leading: /*CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.perm_identity,
                        color: Color(0xffE8652D),
                        size: 30.0,
                      ),
                    ),*/
                    FutureBuilder(
                      future: _storageService.usersPhoto(
                          utilisateur.sharableUserInfo.photo,utilisateur.sharableUserInfo.photoPath,utilisateur.sharableUserInfo.gender), //Photo
                      builder : (context,asyncSnapshot) => CircleAvatar(
                        radius: 45,
                        backgroundImage: asyncSnapshot.data,
                      ),
                    ),
                    trailing: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 70.0),
                Container(
                  height: 341,
                  child: Card(
                    elevation: 10.0,
                    margin: const EdgeInsets.only(left: 18.0, right: 18.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.lock_outline,
                            color: Color(0xffE8652D),
                          ),
                          title: Text("Modifier le mot de passe"),
                          trailing: Icon(Icons.keyboard_arrow_right, color: Color(0xffF1B97A)),
                          onTap: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new MotPage(),
                          )),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(
                            Icons.face,
                            color: Color(0xffE8652D),
                          ),
                          title: Text("Modifier le sexe"),
                          trailing: Icon(Icons.keyboard_arrow_right ,  color: Color(0xffF1B97A)),
                          onTap: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                                builder: (BuildContext context) => new GenrePage(),
                              )),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(
                            Icons.cake,
                            color: Color(0xffE8652D),
                          ),
                          title: Text("Modifier la date de naissance"),
                          trailing: Icon(Icons.calendar_today, color: Color(0xffF1B97A)),
                          onTap: (){
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(1950, 1, 1),
                                maxTime: DateTime(2100, 1, 1),
                                theme: DatePickerTheme(
                                    headerColor: Color(0xffF1B97A),
                                    backgroundColor: Color(0xffF1B97A),
                                    itemStyle: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                    doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
                                onChanged: (date) {
                                  print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                }, onConfirm: (date) {
                                  Provider.of<User>(context, listen: false).utilisateur.setDateOfBirth(date);
                                  print('confirm $date');
                                }, currentTime: DateTime.now(), locale: LocaleType.fr);
                          },
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(Icons.mail_outline,
                              color: Color(0xffE8652D)),
                          title: Text("Modifier l'adresse e-mail"),
                          trailing: Icon(Icons.keyboard_arrow_right , color: Color(0xffF1B97A)),
                          onTap: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new AdressePage(),
                          )),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Color(0xffE8652D),
                          ),
                          title: Text("Modifier le numéro de téléphone"),
                          trailing: Icon(Icons.keyboard_arrow_right , color: Color(0xffF1B97A)),
                          onTap: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new PhonePage(),
                          )),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: Color(0xffE8652D)),
                          title: Text("Supprimer le compte"),
                          trailing: Icon(Icons.keyboard_arrow_right , color: Color(0xffF1B97A),),
                          onTap: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return deleteConfirmation();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  moveToLastSreen(){
    Navigator.pop(context) ;
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: 350.0,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
  AlertDialog deleteConfirmation (){
    return AlertDialog(
      title: Text("Supprimer le compte  ?",
          style: TextStyle(
            color: Color(0xff739D84),
          )),
      content: Text(
          "Votre compte sera entiérement supprimé, tous les rapports de compte et les données seront perdus"),
      actions: <Widget>[
        FlatButton(
            child: Text('Annuler',
                style: TextStyle(
                  color: Color(0xffE8652D),
                )),
            onPressed: () {
              Navigator.pop(context);
            }),
        FlatButton(
            child: Text('Continuer',
                style: TextStyle(
                  color: Color(0xffE8652D),
                )),
            onPressed: () {Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) =>password() ));
            }),
      ],
    );
  }
  AlertDialog password () {
    ServicesAuth servicesAuth = ServicesAuth();
    bool wrongPassword;
    String password;
    final formKey = GlobalKey<FormState>();
    return AlertDialog(
      title: Text("Saissez votre motde passe pour continuer  ?",
          style: TextStyle(
            color: Color(0xff739D84),
          )),
      content: Form(
        key: formKey,
        child: Container(
          child: TextFormField(
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff739D84))),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffE8652D))),
                hintText: "Mot de passe",
                hintStyle: TextStyle(
                  fontSize: 20.0,
                  color: Color(0xff739D84),
                )),
            obscureText: true,
            validator: (val){
              if (val.isEmpty)
                return 'Saisisser votre mot de passe s\'il vous plait';
              else if (wrongPassword)
                return 'Wrong password';
              else
                return null;
            },
            onSaved: (val) => password = val,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('Annuler',
                style: TextStyle(
                  color: Color(0xffE8652D),
                )),
            onPressed: () {
              Navigator.pop(context);
            }),
        FlatButton(
            child: Text('Supprimer',
                style: TextStyle(
                  color: Color(0xffE8652D),
                )),
            onPressed: () async {
              final form = formKey.currentState;
              if (form.validate()) {
                form.save();
                try {
                  await servicesAuth.reauthenticateUserEmail(password);
                  Provider.of<User>(context, listen: false).delete();
                  Navigator.pop(context);
                }
                catch (e) {
                  switch (e.code){
                    case 'ERROR_WRONG_PASSWORD' :
                      {
                        wrongPassword = true;
                        form.validate();
                        wrongPassword = false;
                        break;
                      }
                    default :
                      {
                        print('UKNOWN_ERROR');
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> unknownError (context)));
                        break;
                      }
                  }
                  print(e);
                  return null;
                }
              }
            }),
      ],
    );
  }
}
