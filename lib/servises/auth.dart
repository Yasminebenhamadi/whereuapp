import 'dart:convert';
import 'dart:io';
import 'dart:async' ;
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/firestore.dart';

class ServicesAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  //List of user's authenticated in this app
  UsersCredentials _usersCredentials = UsersCredentials();
  //Attributes used in phone authenticaion :
  String _verificationID;
  String _smsCode;
  bool _phoneVerified ;
  List<int> _forceResendingToken;

  Future<bool> isSignedIn() async {
    return (await _firebaseAuth.currentUser()!=null);
  }
   Future<String> userID () async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }
  Future<void> delete () async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await user.delete();
  }
  Future<String> email () async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.email;
  }
  //--------------------------------Authentication-----------------------------------------
  Future<Utilisateur> signInEmail(String email, String password) async
  {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password); //Sign in with email and password
      FirebaseUser user = result.user; // Put the result in a objectwith the type : FirebaseUser
      String uid = user.uid;
       // Get user's info in an object Utilisateur
      SharableUserInfo userInfo = await _firestoreService.getUserInfo(uid);
      return Utilisateur.old(uid, userInfo);
  }

  Future<Utilisateur> registerEmail(String email, String password, String displayName,String username,DateTime dateOfBirth,Gender gender) async {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password); //Create new user
      FirebaseUser user = result.user;
      await user.sendEmailVerification().then((_){
        print('A verification email has been sent');
      }).catchError((error){
        print('something went wrong when sending the verification email'+error.code);
      });
      String uid = user.uid;
      if(uid!=null)
        {
          print('++++++'+(await _firestoreService.userNameExists(username)).toString());
          await _firestoreService.createAccount(uid, displayName, username,gender,dateOfBirth)
              .then((_){
            print('A user doc has been created');
          });
      }
      Utilisateur utilisateur =  uid != null
          ? Utilisateur(uid, displayName, username, gender, dateOfBirth)
          : null;
      return utilisateur ;//Return an 'Utilisateur' object
  }

  //If the user forgets his password (send verification email beforr using this method)
  Future<Utilisateur> signInPhone(String smsCode)async {
    this._smsCode = smsCode;
    //Creating  a PhoneAuthCredential object
    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: this._smsCode);
    AuthResult result = await _firebaseAuth.signInWithCredential(credential);
    FirebaseUser user = result.user; // Put the result in a objectwith the type : FirebaseUser
    String uid = user.uid;
    // Get user's info in an object Utilisateur
    SharableUserInfo userInfo = await _firestoreService.getUserInfo(uid);
    return Utilisateur.old(uid, userInfo);
  }

  //-------------------------Changing user's email-----------------------------------------------
  Future<void> changeEmail(String password ,String newEmail) async
  {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if(user!=null){
      await reauthenticateUserEmail(password);
        //Pass in the password to updatePassword.
        await user.updateEmail(user.email);
          await user.sendEmailVerification();
          print('email changed');
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  //-------------------------Changing user's password-----------------------------------------------
  Future<void>changePassword(String currentPassword,String newPassword) async
  {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if(user!=null){
      await reauthenticateUserEmail(currentPassword);
      print('reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
      await user.updatePassword(newPassword);
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  Future<void> changePasswordPhone (String newPassword) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if(user!=null){
        //Pass in the password to updatePassword.
        await user.updatePassword(newPassword);
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  //-------------------------Resetting user's password-----------------------------------------------
  Future<void> resetPasswordEmail(String email)async {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
  //----------------------------Phone relates methods-----------------------------------------------
  //Sending a verification code to the the provided phone number
  Future<void> sendVerificationCode(String phone) async {
    //_auth.setLanguageCode('fr');
    _phoneVerified = false ;
    if(phone!=null)
      await _firebaseAuth.verifyPhoneNumber(phoneNumber: phone, timeout: Duration(seconds: 60), verificationCompleted: _verificationCompleted,
          verificationFailed: _verificationFailed, codeSent: _codeSent, codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout);
  }
  //***************************Functions needed********************************
  //Auto-retrieval (detect SMS) / instant verification (no send/retrieve)
  void _verificationCompleted(AuthCredential credential) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    _phoneVerified = false ;
    if(user!=null){
      if(user.phoneNumber == null){
        print('phooone emtyyyyy');
        //Creating  a PhoneAuthCredential object
        await user.linkWithCredential(credential);
      }
      else {
        print('phooone noooot emtyyyyy');
        await user.updatePhoneNumberCredential(credential);
      }
      print('phone number added');
    }
    throw SendCodeException('VERIFICATION_COMPLETED');
  }
  //Couldn't send SMS or Invalid Code
  void _verificationFailed(AuthException authException) async {
    print('verification failed'+authException.code);
    switch (authException.code) {
      case "INVALID_CREDENTIALS":
        {
          print('INVALID_CREDENTIALS');
        }
        break;
      case "TOO_MANY_REQUESTS":
        {
          print('TOO_MANY_REQUESTS');
        }
        break;
      default:
        {
          print('UKNOWN_ERROR');
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
  //***************************************************************************
  //Adding a phone number  (send verification email beforr using this method)
  Future<void> linkPhoneNumber (String phone,String smsCode) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if ((user!=null)){
      this._smsCode = smsCode;
      AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: this._smsCode);
      if(user.phoneNumber == null){
        print('phooone emtyyyyy');
        //Creating  a PhoneAuthCredential object
        await user.linkWithCredential(credential);
      }
      else {
        print('phooone noooot emtyyyyy');
        await user.updatePhoneNumberCredential(credential);
      }
    }
    else
      print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
  }

  //Removing a phone number
  void removePhoneNumber () async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.unlinkFromProvider(PhoneAuthProvider.providerId);
  }


  //-------------------------Re-authenticating user-----------------------------------------------
  Future<void> reauthenticateUserEmail (String password ) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    print('-----------------------------------------'); print(user);
    if (user!=null){
      AuthCredential credential = EmailAuthProvider.getCredential(email: user.email ,password: password);
      await user.reauthenticateWithCredential(credential);
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  Future<void> reauthenticateUserPhone (String smsCode) async {
    FirebaseUser user = await _firebaseAuth.currentUser(); // Get current user
    if (user!=null){
      AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: this._verificationID, smsCode: smsCode);
      user.reauthenticateWithCredential(credential).then((authResult){
        //AuthResult a = authResult;
        print('User reauthenticated');
      });
    }
    else
      print('Please authenticate user : this should\'nt happen');
  }
  //----------------------------------------Remebred users--------------------------------------------------------
  String getUsersPassword (String email){
    if (_usersCredentials.emailsIsSaved(email)){
      return _usersCredentials.passwordOf(email);
    }
    else
      return null;
  }
  List<String> getUsers (Pattern pattern){
    List<String> suggestions = new List<String>() ;
    _usersCredentials.rememberedUsers().forEach((email){
      if(email.startsWith(pattern)){
        suggestions.add(email);
      }
    });
    if (suggestions.isNotEmpty)
      return suggestions;
    else
      return null;
  }
  Future<void> saveUsersCredential (String email,String password) async {
    File myUsersCredentials;
    Directory myDirectory;
    String fileName = 'usersCredentials.json';
    bool fileExists  = false ;
    /* Getting/Creating my file */
    await getApplicationDocumentsDirectory().then((Directory directory) {
      myDirectory = directory;
      myUsersCredentials = new File(myDirectory.path + '/' + fileName);

      if(!fileExists){
        myUsersCredentials.createSync();
        fileExists = true;
      }
      _usersCredentials.addCredentials(email, password);
      String encodedUsersCredentials = jsonEncode(_usersCredentials);
      myUsersCredentials.writeAsStringSync(encodedUsersCredentials);
    });
  }
  Future<void> getUsersCredentials () async {
    File myUsersCredentials;
    Directory myDirectory;
    String fileName = 'usersCredentials.json';
    bool fileExists  = false ;
    UsersCredentials usersCredentials;
    /* Getting/Creating my file */
    myDirectory =  await getApplicationDocumentsDirectory();
    myUsersCredentials = new File(myDirectory.path+ "/" + fileName);
    fileExists = myUsersCredentials.existsSync();
    if(!fileExists){
      usersCredentials = UsersCredentials ();
    }
    else {
      String encodedUsersCredentials = myUsersCredentials.readAsStringSync();
      usersCredentials = UsersCredentials.fromJson(jsonDecode(encodedUsersCredentials));
    }
    _usersCredentials = usersCredentials;
  }
  //-------------------------------Sign out-----------------------------------------
  Future<void> signOut (String uid)async {
    await _firestoreService.removeToken(uid);
    await _firebaseAuth.signOut();
  }

  bool get phoneVerified => _phoneVerified;

}

class UsersCredentials {
  Map<String,String> _usersCredentials;

  UsersCredentials (){
    _usersCredentials = new Map<String,String>();

  }
  UsersCredentials.fromJson (Map<String, dynamic> json){
    _usersCredentials = new Map<String,String>();
    json.forEach((key,value){
        _usersCredentials.putIfAbsent(key, ()=>value);
    });
  }
  Map<String,dynamic> toJson() => _usersCredentials;

  void addCredentials (String email,String password){
    if(!_usersCredentials.containsKey(email)){
      _usersCredentials.putIfAbsent(email , ()=> password);
    }
  }
  String passwordOf(String email) {
    return _usersCredentials[email];
  }
  List<String> rememberedUsers (){
    return new List.from(_usersCredentials.keys);
  }
  bool emailsIsSaved (String email){
    return _usersCredentials.containsKey(email);
  }

}

class SendCodeException {
  String _code ;
  SendCodeException(String code){_code = code ;}
  String get code => _code ;
}