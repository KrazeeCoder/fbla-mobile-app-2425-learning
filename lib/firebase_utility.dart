import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_utility.dart';

Future<List<String>?> getCompletedSubtopics() async {
  try {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userInfo.userId)
        .get();

    if (docSnapshot.exists){
      return docSnapshot.get('subtopicsCompleted');
    } else{
      return null;
    }
  } catch(e){
    return null;
  }
}

Future<String?> completeSubtopic(String subtopicId) async {
  try {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await FirebaseFirestore.instance.collection('users').doc(userInfo.userId).update({
      'subtopicsCompleted': FieldValue.arrayUnion([subtopicId]),
    });

  } catch(e){
    return e.toString();
  }
}

Future<String?> gainXP(int xpGained) async {
  try {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await FirebaseFirestore.instance.collection('users').doc(userInfo.userId).update({
      'currentXP': FieldValue.increment(xpGained),
    });

  } catch(e){
    return e.toString();
  }
}

Future<int?> getStreak() async {
  try {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userInfo.userId)
        .get();

    if (docSnapshot.exists){
      return docSnapshot.get('streakDays');
    } else{
      return null;
    }
  } catch(e){
    return null;
  }
} // can change later to have firestore store specific days instead of just days of streaks


// need to add custom exceptions later based on how we decide to structure firestore




