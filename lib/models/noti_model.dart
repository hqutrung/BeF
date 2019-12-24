import 'package:cloud_firestore/cloud_firestore.dart';

class Noti {
  final String id;
  final String content;
  final String authorId;
  final Timestamp timestamp;
  final int type;

  Noti({
    this.id,
    this.content,
    this.authorId,
    this.timestamp,
    this.type,
  });

  factory Noti.fromDoc(DocumentSnapshot doc) {
    return Noti(
      id: doc.documentID,
      content: doc['content'],
      authorId: doc['authorId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
    );
  }
}
