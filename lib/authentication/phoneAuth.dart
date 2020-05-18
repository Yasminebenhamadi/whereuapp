import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' ;
import 'package:provider/provider.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/authentication/Phone.dart';
import 'package:whereuapp/authentication/changePasswordPhone.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/settings/compte.dart';
import 'package:whereuapp/transition.dart';

class PhoneAuth extends StatefulWidget {
  final String phoneNumber ;
  PhoneAuth ({this.phoneNumber});
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  Widget phoneAuth  ;
  String _verificationID;
  String _smsCode;
  List<int> _forceResendingToken;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance ;
  Utilisateur _utilisateur ;
  @override
  void initState() {
    super.initState();
    phoneAuth = Send(phoneAuthState: this,) ;
  }
  @override
  Widget build(BuildContext context) {
    setState(() {
      _utilisateur =Provider.of<User>(context, listen: false).utilisateur;
    });
    return phoneAuth;
  }
  Future<void> sendVerificationCode(String phone) async {
    //_auth.setLanguageCode('fr');
    if(phone!=null)
      await _firebaseAuth.verifyPhoneNumber(phoneNumber: phone, timeout: Duration(seconds: 60), verificationCompleted: _verificationCompleted,
          verificationFailed: _verificationFailed, codeSent: _codeSent, codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout);
  }
  //***************************Functions needed********************************
  //Auto-retrieval (detect SMS) / instant verification (no send/retrieve)
  void _verificationCompleted(AuthCredential credential) async {
    try{
      await setPhoneCredential(credential) ;
    }
    catch(error) {
      print(error.code);
      switch (error.code) {
        case 'ERROR_INVALID_VERIFICATION_CODE' :
          showDialog(
            context: context,
            builder: (context) =>
                errorDialog(context,
                    'Le code de vérification n\'est pas valid. Vérifier ou renvoyer le code.'),
          );
          break;
        case 'ERROR_SESSION_EXPIRED' :
          showDialog(
            context: context,
            builder: (context) =>
                errorDialog(context, 'Session expired : renvoyer le code.'),
          );
          break;
        case 'ERROR_CREDENTIAL_ALREADY_IN_USE' :
          print('ERROR_CREDENTIAL_ALREADY_IN_USE');
          showDialog(
            context: context,
            builder: (context) =>
                errorDialog(context,
                    'Phone number in use : this phone number is used for another account please use another.'),
          );
          break;
        default :
          break;
      }
    }
  }
  //Couldn't send SMS or Invalid Code
  void _verificationFailed(AuthException authException) async {
    print('verification failed'+authException.code);
    switch (authException.code) {
      case "INVALID_CREDENTIALS":
        {
          showDialog(
            context: context,
            builder: (context) => errorDialog(context, 'Invalid credentials : verifier votre numéro de télephone.') ,
          );
        }
        break;
      case "TOO_MANY_REQUESTS":
        showDialog(
          context: context,
          builder: (context) => errorDialog(context, 'Too many request  : try again later.') ,
        );
        break;
      default:
        {
          showDialog(
            context: context,
            builder: (context) => errorDialog(context, 'Uknown error : try again later') ,
          );
        }
        break;
    }
  }

  void _codeSent (String verificationId, [code]){
    this._verificationID = verificationId;
    this._forceResendingToken = code;
  }
  //Called after the timeout duration specified
  void _codeAutoRetrievalTimeout(String verificationId){
    this._smsCode = verificationId;
    //print('The verification code that has been set is now invalid, please add your phone number again');
  }
  Future<void> linkPhoneNumber (AuthCredential credential) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if ((user!=null)){
      print(user.phoneNumber);
      /*this._smsCode = smsCode;
      AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: this._smsCode);*/
      if(user.phoneNumber == null){
        print('phooone emtyyyyy');
        //Creating  a PhoneAuthCredential object
        await user.linkWithCredential(credential);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> transition())) ;
      }
      else {
        print('phooone noooot emtyyyyy');
        await user.updatePhoneNumberCredential(credential);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SettingsOnePage())) ;
      }
    }
    else
      print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
  }
  Future<Utilisateur> signInPhone(AuthCredential credential)async {
    /*this._smsCode = smsCode;
    //Creating  a PhoneAuthCredential object
    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: this._smsCode);*/
    AuthResult result = await _firebaseAuth.signInWithCredential(credential);
    FirebaseUser user = result.user; // Put the result in a objectwith the type : FirebaseUser
    String uid = user.uid;
    // Get user's info in an object Utilisateur
    SharableUserInfo userInfo = await FirestoreService().getUserInfo(uid);
    return Utilisateur.old(uid, userInfo);
  }
  Future<void> setPhone (String smsCode) async {
    //Creating  a PhoneAuthCredential object
    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: smsCode);
    setPhoneCredential(credential);
  }
  Future<void> setPhoneCredential (AuthCredential credential) async {
    if((await _firebaseAuth.currentUser())!=null){
    await linkPhoneNumber(credential).then((_)=>print('---done---'));
    await  _utilisateur.setPhone(widget.phoneNumber);
    }
    else{
    Utilisateur utilisateur = await signInPhone(credential);
    Provider.of<User>(context, listen: false).setUtilisateur(utilisateur);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MotPagePhone())) ;
    }
  }
  void setPhoneAuth (Widget widget){
    setState(() {
      phoneAuth = widget ;
    });
  }
}

//Send code

// ignore: camel_case_types
class Send extends StatefulWidget {
  final _PhoneAuthState phoneAuthState ;
  Send({this.phoneAuthState});
  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  Future<void> _sendCode () async {
    try {
      await widget.phoneAuthState.sendVerificationCode(widget.phoneAuthState.widget.phoneNumber);
      widget.phoneAuthState.setPhoneAuth ( Verify(phoneAuthState: widget.phoneAuthState,));
    }
    catch (e){
      print('------------------send codeeee--------------------------------');
      print(e);
      print('--------------------------------------------------------------');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff739D84),
        body:Column(children: <Widget>[
          Container(
              alignment: Alignment.topRight,
              child: SendUpImageAsset()
          )
          ,
          SizedBox(
            height: 10.0,
          ),
          Text('Un code de vérification va être',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),Text('envoyer au numero suivant',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),Text('${widget.phoneAuthState.widget.phoneNumber}',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),
          SizedBox(
            height: 100.8,
          ),
          Stack(
              alignment: Alignment.center,
              children :<Widget>[
                Container(
                    alignment: Alignment.bottomRight,
                    child: SendDownImageAsset()
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 0.0,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          width: 250.0,
                          child: RaisedButton(
                            elevation: 5.0,
                            onPressed: () async {
                              await _sendCode();
                            },
                            padding: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            color: Color(0xffE8652D),
                            child: Text(
                              'Envoyer le code',
                              style: TextStyle(
                                  color: Color(0xffF1B97A),
                                  letterSpacing: 1.5,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),


                    Container(
                      alignment: Alignment.center,
                      width: 250.0,
                      child:  FlatButton(
                        child:
                        Text("Annuler",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color:Color(0xFFF1B97A),
                          ),
                        ),
                        onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Phone())) ;},
                      ),
                    ),


                  ],
                )
              ])

        ]));
  }
}

class SendUpImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('assets/images/shapeup.png',);
    Image image = Image(image: assetImage , width: 411.0,fit: BoxFit.cover);
    return Container(child: image,);
  }

}class SendDownImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('assets/images/shapedown.png',);
    Image image = Image(image: assetImage , height: 220.0 ,fit: BoxFit.cover, alignment: Alignment.bottomLeft,);
    return Container(child: image,);
  }
}
class Verify extends StatefulWidget {
  final _PhoneAuthState phoneAuthState ;
  Verify({this.phoneAuthState});
  @override
  _VerifyState createState() => new _VerifyState();
}

class _VerifyState extends State<Verify> {
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
      widget.phoneAuthState.sendVerificationCode(widget.phoneAuthState.widget.phoneNumber);
    }
    catch (e){
      print(e);
    }
  }

  Future<void> _verify () async {
    _smsCode = concatinate();
    try{
      await widget.phoneAuthState.setPhone(_smsCode) ;
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
            showDialog(
              context: context,
              builder: (context) => errorDialog(context, 'Session expired : renvoyer le code.') ,
            );
            break ;
          case 'ERROR_CREDENTIAL_ALREADY_IN_USE' :
          print('ERROR_CREDENTIAL_ALREADY_IN_USE');
          showDialog(
            context: context,
            builder: (context) => errorDialog(context, 'Phone number in use : this phone number is used for another account please use another.') ,
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
                        new Text("Entrez le code qui a été envoyer au numéro \n${widget.phoneAuthState.widget.phoneNumber}", textAlign: TextAlign.center,
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
                              onPressed: () { widget.phoneAuthState.setPhoneAuth ( Send(phoneAuthState: widget.phoneAuthState,)) ;},
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
}
AlertDialog errorDialog (BuildContext context,String text){
  return AlertDialog(
    title: Text("Error",
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
