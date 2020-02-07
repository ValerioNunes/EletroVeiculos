import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudMedthods {

  String collection = "";
  CrudMedthods(this.collection);

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }


  Future<void> addData(model) async {
    if (isLoggedIn()) {
      Firestore.instance.collection(collection).add(model.toJson()).catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }
  Future<Map<String, dynamic>> getUid(String uid) async {
    Map<String, dynamic> visitorData = null;
    print(uid);
    if (uid != null) {
      // wait for result to be returned
      await Firestore.instance.collection(collection)
          .document(uid)
          .get().then((visitorSnapshot) {
            print("121212(( "+ visitorSnapshot.toString());
        visitorData = visitorSnapshot.data;
      }).catchError((error) {

      });
    }
    return visitorData;
  }
  Future<DocumentSnapshot> getInfo(String groupId) async {
    DocumentSnapshot snapshot =  await  Firestore.instance.collection(collection).document(groupId).get();
    return snapshot;
  }


  Future<void> addDataUid(model) async {
    if (isLoggedIn()) {
      Firestore.instance.collection(collection).document(model.uid).setData(model.toJson()).catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }
  Future<void> updateData(model) async {
    if (isLoggedIn()) {
      Firestore.instance.collection(collection).document(model.uid).setData(model.toJson()).catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  Future<void> addDataList(model, atributo ,  object ) async {
    if (isLoggedIn()) {
      Firestore.instance
          .collection(collection)
          .document(model.uid)
          .updateData({atributo: FieldValue.arrayUnion([object])}
          ).catchError((e) {
        print(e);
      }
      );
    } else {
      print('You need to be logged in');
    }
  }
  Future<void> removeDataList(model, atributo ,  object ) async {
    if (isLoggedIn()) {
      Firestore.instance
          .collection(collection)
          .document(model.uid)
          .updateData({atributo:FieldValue.arrayRemove([object])}).catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }
  Future<void> deleteData(model) async {
    if (isLoggedIn()) {
      Firestore.instance.collection(collection).document(model.uid).delete().catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  getData() async {
    return await Firestore.instance.collection(collection).getDocuments();
  }

}