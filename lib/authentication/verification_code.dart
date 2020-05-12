import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/authentication/changePasswordPhone.dart';
import 'package:whereuapp/authentication/send_code.dart';
import 'package:whereuapp/transition.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/auth.dart';
import 'package:provider/provider.dart';

class Verify extends StatefulWidget {
  final String phoneNumber ;
  final ServicesAuth servicesAuth;
  Verify({this.phoneNumber,this.servicesAuth});
  @override
  _VerifyState createState() => new _VerifyState();
}

class _VerifyState extends State<Verify> {
  //String _phoneNumber = '+213 676370021';
  Utilisateur _utilisateur ;
  List<String>_digits = List<String>(6);
  String _smsCode;
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> controllers = <TextEditingController>[
    new TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  void _sendCode (){
    try {
      widget.servicesAuth.sendVerificationCode(widget.phoneNumber);
    }
    catch (e){
      print(e);
    }
  }
  Future<void> _verify () async {
    _smsCode = concatinate();
    try{
      if(await widget.servicesAuth.isSignedIn()){
        await widget.servicesAuth.linkPhoneNumber(widget.phoneNumber, _utilisateur, _smsCode).then((_)=>print('---done---'));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> transition())) ;
      }
      else{
        Utilisateur utilisateur = await widget.servicesAuth.signInPhone(_smsCode);
        Provider.of<User>(context, listen: false).setUtilisateur(utilisateur);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MotPagePhone())) ;
      }
    }
    catch(error){
      print(error.code);
      switch(error.code){
        case 'ERROR_INVALID_VERIFICATION_CODE' :
          showDialog(
              context: context,
              builder: (context) => errorDialog(context, 'Le code de vérification n\'est pas valid. Vérifier ou renvoyer le code.') ,
          );
          break ;
        case 'ERROR_SESSION_EXPIRED' :
          print('ERROR_SESSION_EXPIRED');
          showDialog(
            context: context,
            builder: (context) => errorDialog(context, 'Session expired : renvoyer le code.') ,
          );
          break ;
        default :
          break ;
      }
    }
  }
  @override
  void initState() {
    super.initState();
    int i;
    for (i=0;i<6;i++){
      _digits[i] ='-';
    }
  }
  @override
  Widget build(BuildContext context) {
    setState(() {
      _utilisateur =Provider.of<User>(context, listen: false).utilisateur;
    });
    return new Scaffold(
        backgroundColor: Color(0xff739D84),
        body: Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 30.0,
              ),
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("assets/images/texto.png"),
                        SizedBox(
                          height: 30.0,
                        ),
                        new Text("Entrez le code qui a été envoyer au numéro \n${widget.phoneNumber}", textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                        SizedBox(height: 40,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: pinBoxs(50.0, controllers, Color(0xfff2e9db), Color(0xffe8652d), context, false),
                        ),
                        SizedBox(height: 60,),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          width: 250,
                          child: RaisedButton(
                            elevation: 5.0,
                            onPressed: () async {
                              await _verify ();
                              },
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: Color(0xFFF1B97A),
                            child: Text(
                              'Vérifier',
                              style: TextStyle(
                                color: Color(0xFFE8652D),
                                letterSpacing: 1.5,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              child:
                              Text("Annuler",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:Color(0xFFF1B97A),
                                ),
                              ),
                              onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Send())) ;},
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            FlatButton(
                              child:
                              Text("Renvoyer le code ",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:Color(0xFFF1B97A),
                                ),
                              ),
                              onPressed: () => _sendCode () ,
                            ),
                          ],
                        )

                      ]
                  )
              ),
            )
        )
    );
  }
  //---------------------------------Pinbox methodes------------------------------------------
  InputDecoration inputFormat(Color fillColor){
    return new InputDecoration(
      fillColor: fillColor,
      filled: true,
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(12.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
    );
  }

  TextStyle textStyle(double fontSize, Color color, FontWeight fontWeight){
    return new TextStyle(
        color: color,
        decoration: TextDecoration.none,
        fontSize: fontSize,
        fontWeight: fontWeight
    );
  }

  Container pinBox(double width, TextEditingController con, FocusNode focusNode,
      FocusNode nextFocusNode, Color boxColor, Color textColor, BuildContext context, bool show,int pos) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      width: 45.00,
      child: new TextField(
        decoration: inputFormat(boxColor),
        controller: con,
        textAlign: TextAlign.center,
        cursorColor: boxColor,
        maxLines: 1,
        onChanged: (text) {
          if (text.length > 1) {
            con.text = text.substring(text.length - 1);
          }
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
          _digits[pos] = con.text;
        },
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        autofocus: false,
        style: textStyle(30.0, textColor, FontWeight.bold),
      ),
    );
  }

  List<Widget> pinBoxs(double width, List<TextEditingController> cons,
      Color boxColor, Color textColor, BuildContext context, bool show) {
    List<Widget> boxs = new List();
    List<FocusNode> focusNodes = new List();
    focusNodes.add(new FocusNode());
    for(int i = 0; i < cons.length ; i++){
      focusNodes.add(new FocusNode());
      if(i == cons.length - 1){
        focusNodes[i+1] = null;
      }
      boxs.add(pinBox(width, cons[i], focusNodes[i], focusNodes[i+1], boxColor, textColor,context, show,i));
    }
    return boxs;
  }
//Concatinate six digits
  String concatinate ( ){
    String smsCode ='';
    int i;
    for(i=0;i<6;i++){
      smsCode = smsCode + _digits[i];
    }
    return smsCode;
  }
  AlertDialog errorDialog (BuildContext context,String text){
    return AlertDialog(
      title: Text("Uknown Error",
          style: TextStyle(
            color: Color(0xff739D84),
          )),
      content: Text(text),
      actions: <Widget>[
        FlatButton(
            child: Text('Okay',
                style: TextStyle(
                  color: Color(0xffE8652D),
                )),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
  }
}
