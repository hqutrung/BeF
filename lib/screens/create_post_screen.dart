import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bef/models/post_model.dart';
import 'package:bef/models/user_data.dart';
import 'package:bef/services/database_service.dart';
import 'package:bef/services/storage_service.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  TextEditingController _captionController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Thêm ảnh mới'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Chụp ảnh'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Chọn từ thư viện'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Thêm ảnh mới'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Chụp ảnh'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text('Chọn từ thư viện'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
            SimpleDialogOption(
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      imageFile = await _cropImage(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  _submit() async {
    if (!_isLoading && _image != null) {
      setState(() {
        _isLoading = true;
      });

      // Create post
      String imageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        likeCount: 0,
        authorId: Provider.of<UserData>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );
      DatabaseService.createPost(post);

      // Reset data
      _captionController.clear();

      setState(() {
        _caption = '';
        _image = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: Text(
          'Thêm hình',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Billabong',
            fontStyle: FontStyle.italic,
            fontSize: 35.0,
          ),
        ),
        actions: (_image != null)
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () => _submit(),
                )
              ]
            : null,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              children: <Widget>[
                _isLoading
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.red[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      )
                    : SizedBox.shrink(),
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                    height: width,
                    width: width,
                    color: Colors.grey[300],
                    child: _image == null
                        ? Icon(
                            Icons.add_a_photo,
                            color: Colors.white70,
                            size: 150.0,
                          )
                        : Image(
                            image: FileImage(_image),
                            fit: BoxFit.scaleDown,
                          ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                  child: TextField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0),
                    decoration: InputDecoration(
                      labelText: 'Chia sẻ cảm xúc',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),

                    ),
                    onChanged: (input) => _caption = input,
                    cursorColor: Colors.black,
                    maxLines: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
