import 'package:bef/models/noti_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bef/models/post_model.dart';
import 'package:bef/models/user_model.dart';
import 'package:bef/utilities/constants.dart';

class DatabaseService {
  static void updateUser(User user) {
    usersRef.document(user.id).updateData({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) {
    Future<QuerySnapshot> users =
        usersRef.where('name', isEqualTo: name).getDocuments();

    return users;
  }

  static void createPost(Post post) {
    postsRef.document(post.authorId).collection('userPosts').add({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'authorId': post.authorId,
      'timestamp': post.timestamp,
      'cmtCount': post.cmtCount,
    });
  }

  static void deletePost(Post post) {
    postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id)
        .delete();
  }

  static void followUser({String currentUserId, String userId}) {
    // Add user to current user's following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(userId)
        .setData({});
    // Add current user to user's followers collection
    followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
  }

  static void unfollowUser({String currentUserId, String userId}) {
    // Remove user from current user's following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // Remove current user from user's followers collection
    followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      {String currentUserId, String userId}) async {
    DocumentSnapshot followingDoc = await followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    return followingDoc.exists;
  }

  static Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot = await followingRef
        .document(userId)
        .collection('userFollowing')
        .getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot = await followersRef
        .document(userId)
        .collection('userFollowers')
        .getDocuments();
    return followersSnapshot.documents.length;
  }

  static Stream<List<Post>> getFeedPosts(String userId)  {
    return feedsRef
        .document(userId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)

   .snapshots()
        .map(
          (query) => query.documents
              .map(
                (snapshot) => Post.fromDoc(snapshot),
              )
              .toList(),);

  }


  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        userPostsSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<User> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot = await usersRef.document(userId).get();
    if (userDocSnapshot.exists) {
      return User.fromDoc(userDocSnapshot);
    }
    return User();
  }

  static void likePost({String currentUserId, String postID, String authorId}) {
    DocumentReference postRef =
        postsRef.document(authorId).collection('userPosts').document(postID);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount + 1});
      likesRef
          .document(postID)
          .collection('postLikes')
          .document(currentUserId)
          .setData({});
    });
    if (authorId != currentUserId)
      notificationsRef.document(authorId).collection('userNotis').add({
        'authorId': currentUserId,
        'content': 'đã thích bài viết của bạn',
        'timestamp': DateTime.now(),
        'type': 3,
      });
  }

  static void unlikePost(
      {String currentUserId, String postID, String authorId}) {
    DocumentReference postRef =
        postsRef.document(authorId).collection('userPosts').document(postID);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount - 1});
      likesRef
          .document(postID)
          .collection('postLikes')
          .document(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  static Future<bool> didLikePost({String currentUserId, String postID}) async {
    DocumentSnapshot userDoc = await likesRef
        .document(postID)
        .collection('postLikes')
        .document(currentUserId)
        .get();
    return userDoc.exists;
  }

  static void commentOnPost(
      {String currentUserId,
      String postId,
      String comment,
      String authorId,
      Post post}) {
    DocumentReference postRef =
        postsRef.document(authorId).collection('userPosts').document(postId);
    postRef.get().then((doc) {
      int cmtCount = doc.data['cmtCount'];
      postRef.updateData({'cmtCount': cmtCount + 1});
    });
    commentsRef.document(postId).collection('postComments').add({
      'content': comment,
      'authorId': currentUserId,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
    if (authorId != currentUserId)
      notificationsRef.document(authorId).collection('userNotis').add({
        'authorId': currentUserId,
        'content': 'đã bình luận bài viết của bạn',
        'timestamp': DateTime.now(),
        'type': 2,
      });
  }

  static Stream<Post> getPostStream(String postID, User author) {
    return postsRef
        .document(author.id)
        .collection('userPosts')
        .document(postID)
        .snapshots()
        .map((snapshot) => Post.fromDoc(snapshot));
  }

  static Stream<List<Noti>> getUserNotis(String userId) {
    return notificationsRef
        .document(userId)
        .collection('userNotis')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (query) => query.documents
              .map(
                (snapshot) => Noti.fromDoc(snapshot),
              )
              .toList(),
        );
  }

  static void deleteNoti(String userID, String notiID) {
    notificationsRef
        .document(userID)
        .collection('userNotis')
        .document(notiID)
        .delete();
  }
}
