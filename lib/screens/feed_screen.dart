import 'package:flutter/material.dart';

import 'package:bef/models/post_model.dart';
import 'package:bef/models/user_model.dart';
import 'package:bef/services/database_service.dart';
import 'package:bef/widgets/post_view.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Stream<List<Post>> postAsyncer;

  @override
  void initState() {
    _setupFeed();
    super.initState();
  }

  _setupFeed() {
    postAsyncer = DatabaseService.getFeedPosts(widget.currentUserId); //h
  }

//abc
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        title: Text(
          'BeF',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Billabong',
            fontStyle: FontStyle.italic,
            fontSize: 35.0,
          ),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            _setupFeed();
          },
          child: StreamBuilder(
              stream: postAsyncer,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return SizedBox.shrink();
                else {
                  List<Post> _posts = snapshot.data;
                  if (_posts.length == 0)
                    return Center(
                      child: Text('Theo dõi bạn bè để xem bài viết của họ'),
                    );
                  return ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      Post post = _posts[index];
                      return FutureBuilder(
                        future: DatabaseService.getUserWithId(post.authorId),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          User author = snapshot.data;
                          return PostView(
                            currentUserId: widget.currentUserId,
                            postID: post.id,
                            author: author,
                          );
                        },
                      );
                    },
                  );
                }
              })),
    );
  }
}
