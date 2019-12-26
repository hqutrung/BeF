import 'package:bef/models/noti_model.dart';
import 'package:bef/models/user_model.dart';
import 'package:bef/screens/profile_screen.dart';
import 'package:bef/services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotiScreen extends StatefulWidget {
  final String currentUserId;

  const NotiScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  _NotiScreenState createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  Stream<List<Noti>> notisAsyncer;

  @override
  void initState() {
    updateNotisAsyncer();
    super.initState();
  }

  void updateNotisAsyncer() {
    notisAsyncer = DatabaseService.getUserNotis(widget.currentUserId);
  }

  _buildNoti(Noti noti) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(noti.authorId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User author = snapshot.data;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                currentUserId: widget.currentUserId,
                userId: author.id,
              ),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25.0,
              backgroundColor: Colors.grey,
              backgroundImage: author.profileImageUrl.isEmpty
                  ? AssetImage('assets/images/user_placeholder.jpg')
                  : CachedNetworkImageProvider(author.profileImageUrl),
            ),
            title: Text(
              author.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  author.name + ' ' + noti.content,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 6.0),
                Text(
                  DateFormat('dd-MM-yyyy')
                      .add_jm()
                      .format(noti.timestamp.toDate()),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text('Gỡ thông báo này'),
                      title: Text('Gỡ thông báo'),
                      actions: <Widget>[
                        FlatButton(
                            child: const Text('Hủy'),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        FlatButton(
                            child: const Text('Gỡ'),
                            onPressed: () {
                              DatabaseService.deleteNoti(
                                  widget.currentUserId, noti.id);
                              Navigator.pop(context);
                            })
                      ],
                    );
                  }),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Billabong',
            fontStyle: FontStyle.italic,
            fontSize: 35.0,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: notisAsyncer,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return SizedBox.shrink();
            else {
              List<Noti> notis = snapshot.data;
              if (notis.length == 0)
                return Center(
                  child: Text('Bạn không có thông báo'),
                );
              return ListView.builder(
                itemCount: notis.length,
                itemBuilder: (BuildContext context, int index) =>
                    _buildNoti(notis[index]),
              );
            }
          }),
    );
  }
}
