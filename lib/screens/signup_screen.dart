import 'package:flutter/material.dart';
import 'package:bef/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  static final String id = 'signup_screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name, _email, _password;

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      AuthService.signUpUser(context, _name, _email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[500],
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'BeF',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 120.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Billabong',
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (input) => input.trim().isEmpty
                            ? 'Vui lòng nhập tên của bạn'
                            : null,
                        onSaved: (input) => _name = input,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Billabong',
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (input) =>
                            !input.contains('@') ? 'Email không phù hợp' : null,
                        onSaved: (input) => _email = input,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Billabong',
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (input) => input.length < 6
                            ? 'Password phải ít nhất 6 kí tự'
                            : null,
                        onSaved: (input) => _password = input,
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: 120.0,
                      child: FlatButton(
                        onPressed: _submit,
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 250.0,
                      child: FlatButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Đã có tài khoản? Đăng nhập ngay',
                          style: TextStyle(
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
