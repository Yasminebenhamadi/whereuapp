import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/authentication/Inscription.dart';
import 'package:whereuapp/authentication/resetPassword.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/home/home_page_2.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:whereuapp/unknownError.dart';
import 'package:provider/provider.dart';
class Connection extends StatefulWidget {
  @override
  _ConnectionState  createState() => new _ConnectionState ();
}

class _ConnectionState  extends State<Connection > {

  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  ServicesAuth _servicesAuth = ServicesAuth();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController ();
  //Errors
  bool _emailNotFound = false;
  bool _wrongPassword = false;

  void _submitCommand() async {
    final form = _formKey.currentState;
    Utilisateur utilisateur;
    if (form.validate()) {
      form.save();
      try {
        utilisateur = await _loginCommand();
        print('hiiiiiiiii');
        Provider.of<User>(context, listen: false).setUtilisateur(utilisateur);
        /*if (utilisateur.sharableUserInfo.phone == null )
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Phone ()));
        else*/
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePages_2 ()));
      }
      catch (e) {
        print(e.code);
        switch (e.code){
          case 'ERROR_USER_NOT_FOUND' :
            {
              _emailNotFound = true;
              form.validate();
              _emailNotFound = false;
              break;
            }
          case 'ERROR_WRONG_PASSWORD' :
            {
              _wrongPassword = true;
              form.validate();
              _passwordController.clear();
              _wrongPassword = false;
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
  }
  Future<Utilisateur> _loginCommand() async {
    Utilisateur utilisateur = await _servicesAuth.signInEmail(_email, _password);
    if (_rememberMe){
      await _servicesAuth.saveUsersCredential(_email, _password);
    }
    return utilisateur;
  }

  void setPassword (){
    String password = _servicesAuth.getUsersPassword(_emailController.text) ;
    if(password != null )
    {
      _passwordController.text = password ;
    }
    else{
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/login.jpg"),
                    fit: BoxFit.cover)),
          ), Center(
            child: new Container(
              height: 650.00,
              width: 382.0,
              decoration: BoxDecoration(
                color: Color(0xfff2e9db).withAlpha(100),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(24.00, 24.00),
                    color: Color(0xffF2E9DB).withAlpha(40),
                    blurRadius: 42,
                  ),
                ], borderRadius: BorderRadius.circular(50.00),
              ),
            ),
          ),
          Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 120.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox( height : 15.0) ,
                        new Text(
                          "Bienvenue !",
                          style: TextStyle(
                            fontFamily: "Segoe UI",
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: Color(0xffffffff),
                            shadows: [
                              Shadow(
                                offset: Offset(0.00, 3.00),
                                color: Color(0xFFE8652D),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "Email", style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            )),
                            SizedBox(height: 2.0,),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],),
                              height: 50.0,
                              child: TypeAheadFormField(//TextFormField(
                                validator: (val)  {
                                  if (val.isEmpty)
                                    return 'Saisissez votre email s\'il vous plait' ;
                                  else if (!EmailValidator.validate(val, true))
                                    return 'Cet email n\'est pas valide' ;
                                  else if (this._emailNotFound)
                                    return 'Email not found';
                                  else
                                    return  null;
                                },
                                onSaved: (val) => _email = val,
                                // Displaying emails that are already saved (autocopmete)
                                suggestionsCallback: (pattern) async {
                                  await _servicesAuth.getUsersCredentials();
                                  return _servicesAuth.getUsers(pattern);//CitiesService.getSuggestions(pattern);
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                transitionBuilder: (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                                onSuggestionSelected: (suggestion) {
                                  this._emailController.text = suggestion;
                                  setPassword ();
                                },
                                //--------------------------------------------------------------------
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller : this._emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: Color(0xff739D84)),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 14.0),
                                    prefixIcon: Icon(
                                      Icons.mail,
                                      color: Color(0xff739D84),
                                    ),
                                    hintText: "Entrer votre Email",
                                    hintStyle: TextStyle(
                                      color: Color(0xff739D84),
                                    ),
                                  ),
                                  onChanged :(val){
                                    setPassword ();
                                  },
                                ),

                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: 20.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "Mot de passe", style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            )),
                            SizedBox(height: 2.0,),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],),
                              height: 50.0,
                              child: TextFormField(
                                controller : _passwordController,
                                validator: (val) {
                                  if (val.isEmpty)
                                    return 'please enter your password';
                                  else if (val.length < 6)
                                    return 'Password too short..';
                                  else if (this._wrongPassword)
                                    return 'Wrong password';
                                  else
                                    return null;
                                },
                                onSaved: (val) => _password = val,
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                style: TextStyle(
                                    color: Color(0xff739D84)),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 14.0),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(0xff739D84),
                                  ),
                                  hintText: "Entrer votre mot de passe",
                                  hintStyle: TextStyle(
                                    color: Color(0xff739D84),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: FlatButton(
                            child: Text(
                                "Mot de passe oublié?",
                                style: TextStyle(
                                  color: Colors.white,
                                )
                            ),
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MotDePassePage ())),
                          ),
                        ),
                        Container(
                          height: 20.0,
                          child: Row(
                            children: <Widget>[
                              Theme(
                                data: ThemeData(unselectedWidgetColor: Colors
                                    .white),
                                child: Checkbox(
                                  value: _rememberMe,
                                  checkColor: Colors.green,
                                  activeColor: Colors.white,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'Souvient de moi',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          width: 250,
                          child: RaisedButton(
                            elevation: 5.0,
                            onPressed: _submitCommand,
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: Color(0xFFF1B97A),
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                color: Color(0xFFE8652D),
                                letterSpacing: 1.5,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Text("___________OU___________",
                              style: TextStyle(
                                color: Colors.white,
                              ),),
                            SizedBox(height: 20.0,),
                            Text('S\'inscrire avec', style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      height: 40.0, width: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/facebook.png"),
                                        ),
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    child: Container(
                                      height: 40.0, width: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/google.png"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> Register())),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Vous n\'avez pas un compte? ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'S\'enregistrer',
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            color: Color(0xFFE8652D),
                                            offset: Offset(0.00, 3.00),
                                            blurRadius: 6,)] ,
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ]),
                ),

              )
          ),

        ],
      ),

    );
  }
}
