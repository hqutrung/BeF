import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
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
      body: Center(
        child: Text(
          'Activity',
        ),
      ),
    );
  }
}
