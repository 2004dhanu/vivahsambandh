import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseHelper {
  FirebaseHelper._();

  static FirebaseHelper firebaseHelper = FirebaseHelper._();

  Future<String> getFirebaseToken() async {
    try {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      String token = await firebaseMessaging.getToken() ?? '';
      await firebaseMessaging.subscribeToTopic(DateTime.now().microsecondsSinceEpoch.toString());
      return token;
    } catch(error) {
      return "";
    }
  }
}