import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezsgame/cloud_firestore/cloud_firestore.dart';


class DatabaseService {

  final String uid;
  DatabaseService ({this.uid});

  final CollectionReference favoriteCollection = Firestore.instance.collection('favorites');

  Future updateUserData(String type, String location) async {
    return await favoriteCollection.document(uid).setData({
      'type': type,
      'location': location
    });
  }


  // get favorites stream
  Stream<QuerySnapshot> get favorites {
    return favoriteCollection.snapshots();
  }
}




