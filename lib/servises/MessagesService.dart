import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:whereuapp/classes/Message.dart';

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging ();
  final String serverToken = 'AAAAxP_Ly7A:APA91bE_YSkhxi3cXaCvcjrBUksPFkpme99DmX0qs344gT0djvuP1LfaqjnKk05KAGcnWpnfpC4WbWzOguVx_dj5fn-bl_qfstpss1_IMyU9px7kaSwpksL-6VLGZjS3af-XPH5M9lQl';

  void configure (){
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      //onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
    );
    registrationToken () ;
  }
  Future<String> registrationToken () async {
    String token = await _firebaseMessaging.getToken();
    print(token);
    return token;
  }
  void onToken () async {
    _firebaseMessaging.onTokenRefresh.listen((data){
      //
    });
  }
//------------------------------Receiving a message-----------------------------
  Message exctractJSONNotification(){
    /*
    final Map<String, Item> _items = <String, Item>{};
    Item _itemForMessage(Map<String, dynamic> message) {
    final dynamic data = message['data'] ?? message;
    final String itemId = data['id'];
    final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
     .._matchteam = data['matchteam']
      .._score = data['score'];
    return item;
    }
    */
  }
  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    /*
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }*/

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      // create custom message object
      // set delivered to true if it's false in firestore
    }

    // Or do other work.
  }

  void _onMessageFunction() {
      //set seen by me to true
  }

  void _onResumeFunction() {
    //set seen by me to true
  }

  void _onLaunchFunction() {
    //set seen by me to true
  }
//----------------------------Sending a message---------------------------------
  /*void sendMessage (){
    //title : name of the groupe
    //body : fromWhome : the message
    // additional data (payload): datetime , uid , gid , type ,
    //our custom message : all of that + sent = false , delivered = false , bools in map = false
    // when it's sent add it to firestore
    final String serverToken = '<Server-Token>';
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();


  }*/
  /*Future<void> sendMessage(String notificationKey,String fromDisplayName,String text,String groupName) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message':{
            'token': await _firebaseMessaging.getToken(),
            'notification': <String, dynamic>{
              'body': fromDisplayName+' : '+text,
              'title': groupName,
            },
          },
          'to': notificationKey,
        },
      ),
    );
  }*/
}

