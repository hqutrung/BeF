import 'dart:async';

import 'package:animator/animator.dart';
import 'package:bef/screens/comment_screen.dart';
import 'package:bef/services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bef/models/post_model.dart';
import 'package:bef/models/user_model.dart';
import 'package:bef/screens/profile_screen.dart';

class PostView extends StatefulWidget {
  final String currentUserId;
  final String postID;
  final User author;

  PostView({this.currentUserId, this.postID, this.author});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  bool _isLiked = false;
  bool _heartAnim = false;
  Stream<Post> postAsyncer;
  Post _post;

  @override
  void initState() {
    _initPostLiked();
    postAsyncer = DatabaseService.getPostStream(widget.postID, widget.author);
    super.initState();
  }

  @override
  void didUpdateWidget(PostView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  _initPostLiked() async {
    bool isLiked = await DatabaseService.didLikePost(
      currentUserId: widget.currentUserId,
      postID: widget.postID,
    );
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  _likePost() {
    if (_isLiked) {
      // Unlike Post
      DatabaseService.unlikePost(
          currentUserId: widget.currentUserId,
          postID: widget.postID,
          authorId: widget.author.id);
      setState(() {
        _isLiked = false;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId,
          postID: widget.postID,
          authorId: widget.author.id);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Post>(
        stream: postAsyncer,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          } else {
            _post = snapshot.data;
            return Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        currentUserId: widget.currentUserId,
                        userId: widget.author.id,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 25.0,
                          backgroundColor: Colors.grey,
                          backgroundImage: widget.author.profileImageUrl.isEmpty
                              ? AssetImage('assets/images/user_placeholder.jpg')
                              : CachedNetworkImageProvider(
                                  widget.author.profileImageUrl),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          widget.author.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onDoubleTap: _likePost,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(_post.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      _heartAnim
                          ? Animator(
                              duration: Duration(milliseconds: 300),
                              tween: Tween(begin: 0.5, end: 1.4),
                              curve: Curves.elasticOut,
                              builder: (anim) => Transform.scale(
                                scale: anim.value,
                                child: Icon(
                                  Icons.favorite,
                                  size: 100.0,
                                  color: Colors.red[400],
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: _isLiked
                                ? Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : Icon(Icons.favorite_border),
                            iconSize: 30.0,
                            onPressed: _likePost,
                          ),
                          IconButton(
                              icon: Icon(Icons.comment),
                              iconSize: 30.0,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CommentsScreen(
                                        post: _post,
                                        author: widget.author,
                                      ),
                                    ),
                                  )),
                          (_post.authorId == widget.currentUserId)
                              ? IconButton(
                                  icon: Icon(Icons.more_horiz),
                                  iconSize: 30.0,
                                  onPressed: () {
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Row(
                                              children: <Widget>[
                                                Text('Xóa bài viết'),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                  child: const Text('Hủy'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  }),
                                              FlatButton(
                                                  child: const Text('Xác nhận'),
                                                  onPressed: () {
                                                    DatabaseService.deletePost(
                                                        _post);
                                                    Navigator.pop(context);
                                                  })
                                            ],
                                          );
                                        });
                                  })
                              : Container(),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${_post.likeCount} lượt thích',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              '${_post.cmtCount} bình luận',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                left: 12.0,
                                right: 6.0,
                              ),
                              child: Text(
                                widget.author.name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              child: Expanded(
                                child: Text(
                                  _post.caption,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.0),
                    ],
                  ),
                ),
              ],
            );
          }
        });
  }
}
