import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {

        String uid = inputData['uid'];
        String currentDestinationAddress = inputData['currentDestination']; 


      await Firestore.instance.collection("pushNotifications")
        .document(uid)
        .setData({
        'user': uid,
        'parkingAddress': currentDestinationAddress,
       });

    return Future.value(true);
  });
}
